import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Exporta [jsonData] como arquivo e abre o menu de compartilhamento do
/// sistema (mobile/desktop).
Future<void> shareExportedUserData(
  String jsonData, {
  required String shareText,
  required String shareSubject,
}) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/meus_dados_signwriter.json');
  await file.writeAsString(jsonData);
  await Share.shareXFiles(
    [XFile(file.path)],
    text: shareText,
    subject: shareSubject,
  );
}
