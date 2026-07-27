import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/lesson_category_model.dart';

/// Cache local versionado do curso pedagógico (alimentado pelo Supabase).
class LearningContentCache {
  static const _payloadKey = 'learning_course_cache_v1';
  static const _metaKey = 'learning_course_cache_meta_v1';

  Future<CachedCourse?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_payloadKey);
    final metaRaw = prefs.getString(_metaKey);
    if (raw == null || raw.isEmpty || metaRaw == null) return null;

    try {
      final decoded = json.decode(raw);
      final meta = json.decode(metaRaw);
      if (decoded is! Map || meta is! Map) return null;

      final categoriesRaw = decoded['categories'];
      if (categoriesRaw is! List || categoriesRaw.isEmpty) return null;

      final categories = categoriesRaw
          .whereType<Map>()
          .map((item) => LessonCategoryModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
      if (categories.isEmpty) return null;

      return CachedCourse(
        categories: categories,
        syncedAt: DateTime.tryParse(meta['syncedAt']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        contentVersion: meta['contentVersion']?.toString() ?? '0',
        localeCode: meta['locale']?.toString() ?? 'pt',
      );
    } catch (error, stack) {
      debugPrint('LearningContentCache.load failed: $error\n$stack');
      return null;
    }
  }

  /// Só grava após carga remota completa e válida.
  Future<void> save({
    required List<LessonCategoryModel> categories,
    required String localeCode,
    required String contentVersion,
  }) async {
    if (categories.isEmpty) {
      throw StateError('Recusando gravar cache vazio.');
    }
    final hasLesson = categories.any((c) => c.lessons.isNotEmpty);
    if (!hasLesson) {
      throw StateError('Recusando gravar cache sem lições.');
    }

    final prefs = await SharedPreferences.getInstance();
    final payload = json.encode({
      'categories': categories.map((c) => c.toMap()).toList(),
    });
    final meta = json.encode({
      'syncedAt': DateTime.now().toUtc().toIso8601String(),
      'contentVersion': contentVersion,
      'locale': localeCode,
    });

    await prefs.setString(_payloadKey, payload);
    await prefs.setString(_metaKey, meta);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_payloadKey);
    await prefs.remove(_metaKey);
  }
}

class CachedCourse {
  final List<LessonCategoryModel> categories;
  final DateTime syncedAt;
  final String contentVersion;
  final String localeCode;

  const CachedCourse({
    required this.categories,
    required this.syncedAt,
    required this.contentVersion,
    required this.localeCode,
  });
}
