import 'dart:convert';
import 'dart:typed_data';

import '../models/signmaker_result.dart';

/// Limites para preview PNG persistido em `written_signs.preview_png_base64`.
class WrittenSignPreviewPolicy {
  static const int maxEdgePx = 512;
  static const int maxDecodedBytes = 400 * 1024; // 400 KB pré-Base64

  /// Normaliza e valida o preview. Retorna Base64 puro ou `null` se vazio.
  /// Lança [WrittenSignPreviewException] se inválido ou acima do limite.
  static String? normalizeAndValidate(String? raw) {
    final normalized = SignMakerResult.normalizePngBase64(raw);
    if (normalized == null) return null;

    late final Uint8List bytes;
    try {
      bytes = base64Decode(normalized);
    } catch (_) {
      throw const WrittenSignPreviewException(
        'Preview PNG inválido (Base64 corrompido).',
      );
    }

    if (bytes.length > maxDecodedBytes) {
      throw WrittenSignPreviewException(
        'Preview PNG excede o limite de '
        '${maxDecodedBytes ~/ 1024} KB '
        '(recebido: ${(bytes.length / 1024).toStringAsFixed(1)} KB).',
      );
    }

    final size = readPngSize(bytes);
    if (size == null) {
      throw const WrittenSignPreviewException(
        'Preview não é um PNG válido.',
      );
    }
    if (size.width > maxEdgePx || size.height > maxEdgePx) {
      throw WrittenSignPreviewException(
        'Preview PNG deve ter no máximo ${maxEdgePx}x$maxEdgePx '
        '(recebido: ${size.width}x${size.height}).',
      );
    }

    return normalized;
  }

  /// Lê largura/altura do chunk IHDR. Retorna null se não for PNG.
  static ({int width, int height})? readPngSize(Uint8List bytes) {
    if (bytes.length < 24) return null;
    const signature = [137, 80, 78, 71, 13, 10, 26, 10];
    for (var i = 0; i < signature.length; i++) {
      if (bytes[i] != signature[i]) return null;
    }
    // bytes 12-15 = "IHDR"
    if (bytes[12] != 0x49 ||
        bytes[13] != 0x48 ||
        bytes[14] != 0x44 ||
        bytes[15] != 0x52) {
      return null;
    }
    final width = (bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19];
    final height =
        (bytes[20] << 24) | (bytes[21] << 16) | (bytes[22] << 8) | bytes[23];
    if (width <= 0 || height <= 0) return null;
    return (width: width, height: height);
  }
}

class WrittenSignPreviewException implements Exception {
  final String message;
  const WrittenSignPreviewException(this.message);

  @override
  String toString() => message;
}
