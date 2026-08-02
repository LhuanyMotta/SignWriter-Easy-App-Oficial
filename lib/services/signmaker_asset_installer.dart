import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'signmaker_bridge_service.dart';

/// Copia o bundle SignMaker dos assets Flutter para um diretório local
/// (`file://`), necessário para scripts relativos na WebView.
class SignMakerAssetInstaller {
  SignMakerAssetInstaller._();

  /// Incrementar ao alterar host/index de integração para forçar re-cópia.
  static const _versionMarker = '1.2.1-colorize2';
  static Directory? _cachedDir;

  static Future<Directory> ensureBundleDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'SignMaker embutido ainda não é suportado no Flutter Web nesta fase.',
      );
    }

    if (_cachedDir != null && await _isInstalled(_cachedDir!)) {
      return _cachedDir!;
    }

    final support = await getApplicationSupportDirectory();
    final target = Directory('${support.path}/signmaker_$_versionMarker');
    if (!await _isInstalled(target)) {
      if (await target.exists()) {
        await target.delete(recursive: true);
      }
      await target.create(recursive: true);
      await _copyAssetTree(target);
      await File('${target.path}/.installed').writeAsString(_versionMarker);
    }

    _cachedDir = target;
    return target;
  }

  static Future<Uri> ensureIndexUri({
    String ui = SignMakerBridgeService.defaultUi,
    String alphabet = SignMakerBridgeService.defaultAlphabet,
    String? fsw,
    String? swu,
  }) async {
    final dir = await ensureBundleDirectory();
    final parts = <String>[
      'ui=${Uri.encodeComponent(ui)}',
      'alphabet=${Uri.encodeComponent(alphabet)}',
    ];
    final cleanFsw = fsw?.trim();
    final cleanSwu = swu?.trim();
    if (cleanFsw != null && cleanFsw.isNotEmpty) {
      parts.add('fsw=${Uri.encodeComponent(cleanFsw)}');
    }
    if (cleanSwu != null && cleanSwu.isNotEmpty) {
      parts.add('swu=${Uri.encodeComponent(cleanSwu)}');
    }

    // SignMaker lê parâmetros em `#?key=value`.
    return Uri.file('${dir.path}/index.html').replace(
      fragment: '?${parts.join('&')}',
    );
  }

  @Deprecated('Use ensureIndexUri')
  static Future<Uri> ensureHostUri() => ensureIndexUri();

  static Future<bool> _isInstalled(Directory dir) async {
    final marker = File('${dir.path}/.installed');
    final index = File('${dir.path}/index.html');
    if (!await marker.exists() || !await index.exists()) {
      return false;
    }
    final version = (await marker.readAsString()).trim();
    return version == _versionMarker;
  }

  static Future<void> _copyAssetTree(Directory target) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final keys = manifest
        .listAssets()
        .where((key) => key.startsWith('assets/signmaker/'))
        .toList();

    if (keys.isEmpty) {
      throw StateError(
        'Nenhum asset SignMaker encontrado. Verifique pubspec.yaml.',
      );
    }

    for (final key in keys) {
      final relative = key.substring('assets/signmaker/'.length);
      if (relative.isEmpty) continue;
      final out = File('${target.path}/$relative');
      await out.parent.create(recursive: true);
      final data = await rootBundle.load(key);
      await out.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }
  }
}
