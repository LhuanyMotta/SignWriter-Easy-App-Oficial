import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'export_format.dart';

/// Exporta [jsonData] no [format] escolhido e abre o menu de
/// compartilhamento do sistema (mobile/desktop).
Future<void> shareExportedUserData(
  String jsonData, {
  ExportFormat format = ExportFormat.json,
  required String shareText,
  required String shareSubject,
}) async {
  final bytes = await buildExportBytes(jsonData, format);
  final directory = await getTemporaryDirectory();
  final file = File(
      '${directory.path}/meus_dados_signwriter.${format.extension}');
  await file.writeAsBytes(bytes);
  await Share.shareXFiles(
    [XFile(file.path)],
    text: shareText,
    subject: shareSubject,
  );
}
