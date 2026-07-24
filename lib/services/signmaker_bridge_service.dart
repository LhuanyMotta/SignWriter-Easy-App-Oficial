import 'dart:convert';

import '../models/signmaker_result.dart';

/// Contrato e validação da comunicação Flutter ↔ SignMaker (assets locais).
///
/// O host devolve `{ signmaker: 'save', fsw, swu, png }` onde `png` é
/// data URL gerada por `ssw.png` (raster, sem depender de fontes no Flutter).
class SignMakerBridgeService {
  static const String channelName = 'FlutterSignMaker';
  static const String contractVersion = '1';

  /// UI Português Brasileiro e alfabeto Libras (ISO 639-3: bzs).
  static const String defaultUi = 'ptBR';
  static const String defaultAlphabet = 'bzs';

  static const String assetHostPath = 'assets/signmaker/host.html';

  /// Serializa mensagem de carga para o host (`SignMakerHost.load`).
  String encodeLoadMessage({
    String? fsw,
    String? swu,
    String ui = defaultUi,
    String alphabet = defaultAlphabet,
  }) {
    final payload = <String, dynamic>{
      'ui': ui,
      'alphabet': alphabet,
      'contractVersion': contractVersion,
    };
    final cleanFsw = fsw?.trim();
    final cleanSwu = swu?.trim();
    if (cleanFsw != null &&
        cleanFsw.isNotEmpty &&
        isValidFsw(cleanFsw)) {
      payload['fsw'] = cleanFsw;
    }
    if (cleanSwu != null && cleanSwu.isNotEmpty) {
      payload['swu'] = cleanSwu;
    }
    return jsonEncode(payload);
  }

  /// Interpreta mensagens recebidas pelo JavaScriptChannel / evaluateJS.
  SignMakerHostEvent parseHostMessage(String raw) {
    Map<String, dynamic> map;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const SignMakerHostEvent.ignored();
      }
      map = Map<String, dynamic>.from(decoded);
    } catch (_) {
      return const SignMakerHostEvent.ignored();
    }

    final type = map['signmaker']?.toString();
    if (type == null || type.isEmpty) {
      return const SignMakerHostEvent.ignored();
    }

    switch (type) {
      case 'ready':
        return const SignMakerHostEvent.ready();
      case 'loaded':
        return const SignMakerHostEvent.loaded();
      case 'cancel':
        return const SignMakerHostEvent.cancel();
      case 'error':
        return SignMakerHostEvent.error(
          map['error']?.toString() ?? 'unknown',
          detail: map['detail']?.toString(),
        );
      case 'save':
        final fsw = (map['fsw'] ?? '').toString().trim();
        final swu = (map['swu'] ?? '').toString().trim();
        final pngRaw = (map['png'] ?? map['previewPngDataUrl'])?.toString();
        final previewPngBase64 = SignMakerResult.normalizePngBase64(pngRaw);
        if (!isValidFsw(fsw)) {
          return const SignMakerHostEvent.error('invalid_fsw');
        }
        return SignMakerHostEvent.save(
          SignMakerResult(
            fsw: fsw,
            swu: swu,
            previewPngBase64: previewPngBase64,
          ),
        );
      default:
        // Rejeita comandos arbitrários.
        return const SignMakerHostEvent.ignored();
    }
  }

  /// FSW Formal SignWriting básico (rejeita protótipo SW-MVP e vazio).
  bool isValidFsw(String value) {
    final fsw = value.trim();
    if (fsw.isEmpty) return false;
    if (fsw.startsWith('SW-MVP:')) return false;
    // Assinatura mínima: caixa BLMR + coordenadas, opcionalmente com sequência A…
    final pattern = RegExp(
      r'^(A(S[123][0-9a-fA-F]{2}[0-5][0-9a-fA-F])+)?[BLMR][0-9]{3}x[0-9]{3}'
      r'(S[123][0-9a-fA-F]{2}[0-5][0-9a-fA-F][0-9]{3}x[0-9]{3})*$',
    );
    return pattern.hasMatch(fsw);
  }
}

/// Eventos tipados vindos do host.html.
class SignMakerHostEvent {
  final SignMakerHostEventKind kind;
  final SignMakerResult? result;
  final String? errorCode;
  final String? errorDetail;

  const SignMakerHostEvent._({
    required this.kind,
    this.result,
    this.errorCode,
    this.errorDetail,
  });

  const SignMakerHostEvent.ready()
      : this._(kind: SignMakerHostEventKind.ready);

  const SignMakerHostEvent.loaded()
      : this._(kind: SignMakerHostEventKind.loaded);

  const SignMakerHostEvent.cancel()
      : this._(kind: SignMakerHostEventKind.cancel);

  const SignMakerHostEvent.ignored()
      : this._(kind: SignMakerHostEventKind.ignored);

  const SignMakerHostEvent.save(SignMakerResult result)
      : this._(kind: SignMakerHostEventKind.save, result: result);

  const SignMakerHostEvent.error(String code, {String? detail})
      : this._(
          kind: SignMakerHostEventKind.error,
          errorCode: code,
          errorDetail: detail,
        );
}

enum SignMakerHostEventKind {
  ready,
  loaded,
  save,
  cancel,
  error,
  ignored,
}
