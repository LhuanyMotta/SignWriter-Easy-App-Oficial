import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:signwriter_easy_app_oficial/services/export_format.dart';

void main() {
  const jsonData = '''{
    "profile": {"name": "Maria"},
    "settings": {"font_size": 16}
  }''';

  test('gera bytes para todos os formatos de exportacao', () async {
    final json = await buildExportBytes(jsonData, ExportFormat.json);
    final csv = await buildExportBytes(jsonData, ExportFormat.csv);
    final txt = await buildExportBytes(jsonData, ExportFormat.txt);
    final pdf = await buildExportBytes(jsonData, ExportFormat.pdf);

    expect(utf8.decode(json), contains('"name": "Maria"'));
    expect(utf8.decode(csv), contains('Campo,Valor'));
    expect(utf8.decode(csv), contains('profile.name,Maria'));
    expect(utf8.decode(txt), contains('profile.name: Maria'));
    expect(utf8.decode(txt), contains('settings.font_size: 16'));
    expect(pdf, isNotEmpty);
    expect(utf8.decode(pdf.sublist(0, 5)), '%PDF-');
  });
}
