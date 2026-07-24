import 'dart:convert';
import 'dart:typed_data';

/// Resultado tipado devolvido pelo editor SignMaker embutido.
///
/// [fsw] é a fonte da verdade. [previewPngBase64] é cache visual (PNG),
/// independente das fontes tipográficas do SVG do SignMaker.
class SignMakerResult {
  final String fsw;
  final String swu;

  /// PNG em Base64 (sem prefixo `data:`), gerado via `ssw.png` no WebView.
  final String? previewPngBase64;

  const SignMakerResult({
    required this.fsw,
    this.swu = '',
    this.previewPngBase64,
  });

  bool get hasPreviewPng =>
      previewPngBase64 != null && previewPngBase64!.trim().isNotEmpty;

  Uint8List? get previewPngBytes => decodePngBase64(previewPngBase64);

  Map<String, dynamic> toMap() {
    return {
      'fsw': fsw,
      'swu': swu,
      'preview_png_base64': previewPngBase64,
    };
  }

  /// Aceita data URL (`data:image/png;base64,...`) ou Base64 puro.
  static String? normalizePngBase64(String? raw) {
    if (raw == null) return null;
    var value = raw.trim();
    if (value.isEmpty) return null;

    // Rejeita SVG tipográfico antigo — não é PNG.
    if (value.startsWith('<svg') || value.startsWith('<?xml')) {
      return null;
    }

    final dataIdx = value.indexOf('base64,');
    if (value.startsWith('data:')) {
      if (!value.startsWith('data:image/png') || dataIdx < 0) {
        return null;
      }
      value = value.substring(dataIdx + 7).trim();
    }
    if (value.isEmpty) return null;
    return value;
  }

  static Uint8List? decodePngBase64(String? raw) {
    final normalized = normalizePngBase64(raw);
    if (normalized == null) return null;
    try {
      return base64Decode(normalized);
    } catch (_) {
      return null;
    }
  }
}
