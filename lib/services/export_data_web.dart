import 'dart:html' as html;

import 'export_format.dart';

/// Exporta [jsonData] no [format] escolhido, disparando o download do
/// arquivo direto no navegador (não existe sistema de arquivos nem app de
/// compartilhamento na Web).
Future<void> shareExportedUserData(
  String jsonData, {
  ExportFormat format = ExportFormat.json,
  required String shareText,
  required String shareSubject,
}) async {
  final bytes = await buildExportBytes(jsonData, format);
  final blob = html.Blob([bytes], format.mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'meus_dados_signwriter.${format.extension}')
    ..click();
  html.Url.revokeObjectUrl(url);
  anchor.remove();
}
