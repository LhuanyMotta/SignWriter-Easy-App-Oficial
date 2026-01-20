import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/sign_model.dart';

/// Serviço para importar sinais do catálogo JSON
class SignImportService {
  static const String _catalogPath = 'assets/signs_catalog.json';
  static const String _defaultImagePath = 'assets/images/signwriter_logo.png';

  /// Carrega e converte o catálogo em lista de SignModel
  Future<List<SignModel>> loadSignsFromCatalog() async {
    final jsonStr = await rootBundle.loadString(_catalogPath);
    final decoded = json.decode(jsonStr);

    if (decoded is! List) {
      throw const FormatException('Catálogo inválido: esperado array');
    }

    return decoded.map<SignModel>((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Item inválido no catálogo');
      }
      return _mapToSign(item);
    }).toList();
  }

  SignModel _mapToSign(Map<String, dynamic> map) {
    final id = map['id']?.toString();
    final name = map['name']?.toString();
    final category = map['category']?.toString();

    if (id == null || id.isEmpty || name == null || name.isEmpty || category == null || category.isEmpty) {
      throw const FormatException('Sinal inválido: id/nome/categoria obrigatórios');
    }

    final tagsRaw = map['tags'];
    final tags = _parseTags(tagsRaw);

    return SignModel(
      id: id,
      name: name,
      description: map['description']?.toString(),
      signImagePath: map['assetPath']?.toString() ?? _defaultImagePath,
      videoPath: map['videoPath']?.toString(),
      category: category,
      tags: tags,
      signWritingCode: map['signWritingCode']?.toString(),
      portugueseText: map['portugueseText']?.toString(),
      createdAt: DateTime.now(),
    );
  }

  List<String> _parseTags(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }
}
