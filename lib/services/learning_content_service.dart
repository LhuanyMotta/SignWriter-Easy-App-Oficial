import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/lesson_category_model.dart';

class LearningContentService {
  static const String _ptPath = 'assets/learning/lessons_pt.json';
  static const String _enPath = 'assets/learning/lessons_en.json';

  Future<List<LessonCategoryModel>> loadCategories(Locale locale) async {
    final languageCode = locale.languageCode.toLowerCase();
    final path = languageCode == 'en' ? _enPath : _ptPath;

    try {
      return await _loadCategoriesFromPath(path);
    } catch (_) {
      if (path == _ptPath) rethrow;
      return _loadCategoriesFromPath(_ptPath);
    }
  }

  Future<List<LessonCategoryModel>> _loadCategoriesFromPath(String path) async {
    final jsonStr = await rootBundle.loadString(path);
    final decoded = json.decode(jsonStr);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Conteudo educacional invalido.');
    }

    final rawCategories = decoded['categories'];
    if (rawCategories is! List) {
      throw const FormatException('Categorias nao encontradas no asset.');
    }

    return rawCategories
        .whereType<Map>()
        .map(
          (item) => LessonCategoryModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}
