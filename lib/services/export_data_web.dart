import 'dart:html' as html;

/// Exporta [jsonData] disparando o download do arquivo direto no navegador
/// (não existe sistema de arquivos nem app de compartilhamento na Web, então
/// a melhor experiência aqui é simplesmente baixar o .json).
Future<void> shareExportedUserData(
  String jsonData, {
  required String shareText,
  required String shareSubject,
}) async {
  final bytes = html.Blob([jsonData], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(bytes);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'meus_dados_signwriter.json')
    ..click();
  html.Url.revokeObjectUrl(url);
  anchor.remove();
}
