import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Formatos de arquivo disponíveis para exportação dos dados do usuário.
enum ExportFormat { json, csv, txt, pdf }

extension ExportFormatX on ExportFormat {
  /// Extensão de arquivo (sem o ponto).
  String get extension {
    switch (this) {
      case ExportFormat.json:
        return 'json';
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.txt:
        return 'txt';
      case ExportFormat.pdf:
        return 'pdf';
    }
  }

  /// MIME type usado no download da Web.
  String get mimeType {
    switch (this) {
      case ExportFormat.json:
        return 'application/json';
      case ExportFormat.csv:
        return 'text/csv';
      case ExportFormat.txt:
        return 'text/plain';
      case ExportFormat.pdf:
        return 'application/pdf';
    }
  }

  /// Nome amigável, usado em UI (ex: bottom sheet de seleção de formato).
  String get label {
    switch (this) {
      case ExportFormat.json:
        return 'JSON';
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.txt:
        return 'TXT';
      case ExportFormat.pdf:
        return 'PDF';
    }
  }
}

/// Converte o [jsonData] (String já em formato JSON, como devolvido por
/// `ProfileViewModel.exportUserData()`) para os bytes do [format] escolhido.
///
/// Compartilhado entre as implementações io e web — não usa `dart:io` nem
/// `dart:html`.
Future<Uint8List> buildExportBytes(String jsonData, ExportFormat format) async {
  switch (format) {
    case ExportFormat.json:
      return Uint8List.fromList(utf8.encode(jsonData));

    case ExportFormat.csv:
      return Uint8List.fromList(utf8.encode(_toCsv(jsonData)));

    case ExportFormat.txt:
      return Uint8List.fromList(utf8.encode(_toTxt(jsonData)));

    case ExportFormat.pdf:
      return _toPdf(jsonData);
  }
}

/// Achata o JSON em pares "chave: valor", inclusive dentro de mapas/listas
/// aninhadas, usando notação de caminho (ex: `endereco.cidade`).
Map<String, String> _flatten(dynamic data) {
  final result = <String, String>{};

  void walk(String prefix, dynamic value) {
    if (value is Map) {
      value.forEach((k, v) => walk(prefix.isEmpty ? '$k' : '$prefix.$k', v));
    } else if (value is List) {
      for (var i = 0; i < value.length; i++) {
        walk('$prefix[$i]', value[i]);
      }
    } else {
      result[prefix] = value?.toString() ?? '';
    }
  }

  walk('', data);
  return result;
}

String _toCsv(String jsonData) {
  final decoded = jsonDecode(jsonData);
  final flat = _flatten(decoded);
  final rows = <List<dynamic>>[
    ['Campo', 'Valor'],
    ...flat.entries.map((e) => [e.key, e.value]),
  ];
  return const ListToCsvConverter().convert(rows);
}

String _toTxt(String jsonData) {
  final decoded = jsonDecode(jsonData);
  final flat = _flatten(decoded);
  final buffer = StringBuffer('Meus dados - SignWriter Fácil\n');
  buffer.writeln('=' * 32);
  flat.forEach((k, v) => buffer.writeln('$k: $v'));
  return buffer.toString();
}

Future<Uint8List> _toPdf(String jsonData) async {
  final decoded = jsonDecode(jsonData);
  final flat = _flatten(decoded);

  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text(
          'Meus dados - SignWriter Fácil',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(3),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text('Campo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text('Valor', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            ...flat.entries.map(
              (e) => pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(e.key)),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(e.value)),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );

  return doc.save();
}
