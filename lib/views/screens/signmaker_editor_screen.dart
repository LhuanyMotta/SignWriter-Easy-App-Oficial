import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../models/signmaker_result.dart';
import '../../services/signmaker_asset_installer.dart';
import '../../services/signmaker_bridge_service.dart';

/// WebView em tela cheia com SignMaker local (assets versionados).
class SignMakerEditorScreen extends StatefulWidget {
  final String? initialFsw;
  final String? initialSwu;

  const SignMakerEditorScreen({
    super.key,
    this.initialFsw,
    this.initialSwu,
  });

  @override
  State<SignMakerEditorScreen> createState() => _SignMakerEditorScreenState();
}

class _SignMakerEditorScreenState extends State<SignMakerEditorScreen> {
  final SignMakerBridgeService _bridge = SignMakerBridgeService();

  WebViewController? _controller;
  bool _loading = true;
  bool _saving = false;
  String? _errorMessage;

  /// Ponte injetada na página do SignMaker (mesmo documento — sem iframe).
  /// Prévia = PNG via `ssw.png` (raster com fontes do WebView), não SVG tipográfico.
  static const _collectBridgeJs = r'''
(function () {
  window.__SignWriterBridge = {
    collect: function () {
      try {
        if (typeof signmaker === 'undefined' || !signmaker || !signmaker.vm) {
          return JSON.stringify({
            signmaker: 'error',
            error: 'editor_not_ready'
          });
        }
        var fsw = '';
        var swu = '';
        var png = null;
        try {
          fsw = signmaker.vm.fswnorm() || '';
        } catch (e1) {
          return JSON.stringify({
            signmaker: 'error',
            error: 'collect_failed',
            detail: String(e1)
          });
        }
        try {
          swu = signmaker.vm.swunorm() || '';
        } catch (e2) {
          swu = '';
        }
        try {
          if (fsw && typeof ssw !== 'undefined' && typeof ssw.png === 'function') {
            var styling = '';
            try {
              styling = signmaker.vm.styling() || '';
            } catch (eStyle) {
              styling = '';
            }
            png = ssw.png(fsw + styling, {
              size: 1,
              pad: 8,
              line: 'black',
              fill: 'white',
              back: 'white',
              colorize: true
            }) || null;
            // Limite ~400KB de data URL para o bridge JS ↔ Flutter.
            if (png && png.length > 400000) png = null;
          }
        } catch (e3) {
          png = null;
        }
        return JSON.stringify({
          signmaker: 'save',
          fsw: fsw,
          swu: swu,
          png: png
        });
      } catch (e) {
        return JSON.stringify({
          signmaker: 'error',
          error: 'collect_failed',
          detail: String(e)
        });
      }
    }
  };
  return true;
})();
''';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final initialFsw = widget.initialFsw;
      final indexUri = await SignMakerAssetInstaller.ensureIndexUri(
        fsw: (initialFsw != null && _bridge.isValidFsw(initialFsw))
            ? initialFsw
            : null,
        swu: widget.initialSwu,
      );

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFF5F5F5))
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (request) {
              final url = request.url;
              // Bloqueia a página demo (URL Parameters) e destinos externos.
              if (url.contains('demo.html')) {
                return NavigationDecision.prevent;
              }
              if (url.startsWith('file://') ||
                  url == 'about:blank' ||
                  url.startsWith('data:')) {
                return NavigationDecision.navigate;
              }
              return NavigationDecision.prevent;
            },
            onWebResourceError: (error) {
              if (!mounted) return;
              setState(() {
                _errorMessage =
                    'Falha ao carregar o editor: ${error.description}';
                _loading = false;
              });
            },
            onPageFinished: (_) {
              unawaited(_onPageFinished());
            },
          ),
        );

      final platform = controller.platform;
      if (platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(kDebugMode);
        await platform.setAllowFileAccess(true);
      }

      await controller.loadRequest(indexUri);

      if (!mounted) return;
      setState(() {
        _controller = controller;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Não foi possível preparar o SignMaker.\n$e';
      });
    }
  }

  Future<void> _onPageFinished() async {
    final controller = _controller;
    if (controller == null || !mounted) return;

    try {
      await controller.runJavaScript(_collectBridgeJs);
      // Pequena espera para o Mithril/SignMaker inicializar.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  String _normalizeJsResult(Object? raw) {
    if (raw == null) return '';
    var text = raw.toString().trim();
    if (text.isEmpty || text == 'null' || text == 'undefined') return '';

    // WKWebView às vezes devolve a string JSON já entre aspas.
    if (text.startsWith('"') && text.endsWith('"')) {
      try {
        final decoded = jsonDecode(text);
        if (decoded is String) return decoded;
      } catch (_) {
        text = text.substring(1, text.length - 1)
            .replaceAll(r'\"', '"')
            .replaceAll(r'\\', r'\');
      }
    }
    return text;
  }

  void _handleHostEvent(SignMakerHostEvent event) {
    switch (event.kind) {
      case SignMakerHostEventKind.save:
        if (event.result != null && mounted) {
          Navigator.of(context).pop(event.result);
        } else if (mounted) {
          setState(() {
            _saving = false;
            _errorMessage = _mapError('invalid_fsw', null);
          });
        }
        break;
      case SignMakerHostEventKind.error:
        if (!mounted) return;
        setState(() {
          _saving = false;
          _errorMessage = _mapError(event.errorCode, event.errorDetail);
        });
        break;
      case SignMakerHostEventKind.cancel:
        if (mounted) Navigator.of(context).pop();
        break;
      case SignMakerHostEventKind.ready:
      case SignMakerHostEventKind.loaded:
      case SignMakerHostEventKind.ignored:
        if (mounted) setState(() => _saving = false);
        break;
    }
  }

  String _mapError(String? code, String? detail) {
    switch (code) {
      case 'invalid_fsw':
        return 'Monte um sinal válido no editor antes de concluir.';
      case 'editor_not_ready':
        return 'O editor ainda está carregando. Aguarde um instante e tente de novo.';
      case 'collect_failed':
        return 'Não foi possível ler o sinal.${detail != null ? '\n$detail' : ''}';
      case 'timeout':
        return 'O editor demorou para responder. Tente concluir novamente.';
      default:
        return 'Erro no editor SignMaker (${code ?? 'desconhecido'}).';
    }
  }

  Future<void> _requestSave() async {
    final controller = _controller;
    if (controller == null) {
      setState(() {
        _errorMessage = 'O editor ainda não está pronto.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      await controller.runJavaScript(_collectBridgeJs);
      // Espera as fontes Sutton no WebView (ssw.png desenha no canvas com elas).
      try {
        await controller
            .runJavaScriptReturningResult(r'''
(function () {
  if (!document.fonts || !document.fonts.ready) return 'skip';
  return document.fonts.ready.then(function () { return 'ready'; });
})()
''')
            .timeout(const Duration(seconds: 4));
      } catch (_) {
        // Segue mesmo sem confirmação de fontes (iOS pode não await Promise).
      }

      final raw = await controller
          .runJavaScriptReturningResult('__SignWriterBridge.collect();')
          .timeout(const Duration(seconds: 8));

      final jsonPayload = _normalizeJsResult(raw);
      if (jsonPayload.isEmpty) {
        if (!mounted) return;
        setState(() {
          _saving = false;
          _errorMessage = _mapError('collect_failed', 'resposta vazia');
        });
        return;
      }

      final event = _bridge.parseHostMessage(jsonPayload);
      _handleHostEvent(event);
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorMessage = _mapError('timeout', null);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorMessage =
            'Não foi possível concluir o sinal.\n${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor SignWriting'),
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: 'Cancelar',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: (_loading || _saving || _controller == null)
                ? null
                : _requestSave,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white54,
            ),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Concluir',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_controller != null)
            WebViewWidget(controller: _controller!)
          else if (_errorMessage == null)
            const Center(child: CircularProgressIndicator()),
          if (_loading && _controller != null)
            const ColoredBox(
              color: Color(0x88FFFFFF),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_errorMessage != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _errorMessage = null);
                          if (_controller == null) {
                            _bootstrap();
                          }
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Atalho de navegação tipado.
Future<SignMakerResult?> openSignMakerEditor(
  BuildContext context, {
  String? initialFsw,
  String? initialSwu,
}) {
  return Navigator.of(context).push<SignMakerResult>(
    MaterialPageRoute(
      builder: (_) => SignMakerEditorScreen(
        initialFsw: initialFsw,
        initialSwu: initialSwu,
      ),
    ),
  );
}
