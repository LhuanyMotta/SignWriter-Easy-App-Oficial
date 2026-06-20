import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lesson_category_model.dart';
import '../models/lesson_exercise_model.dart';
import '../models/lesson_model.dart';
import '../models/lesson_section_model.dart';

class LearningContentService {
  static const String _ptPath = 'assets/learning/lessons_pt.json';
  static const String _enPath = 'assets/learning/lessons_en.json';

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<LessonCategoryModel>> loadCategories(Locale locale) async {
    try {
      final remoteCategories = await _loadRemoteCategories(locale);
      final hasRemoteLessons = remoteCategories.any(
        (category) => category.lessons.isNotEmpty,
      );
      // Quando o Supabase tem dados, usa SOMENTE o Supabase.
      // O merge com local foi removido pois causava categorias duplicadas.
      if (hasRemoteLessons) {
        return remoteCategories;
      }
    } catch (_) {
      // Mantém o conteúdo local disponível quando o Supabase está offline.
    }

    return _loadLocalCategories(locale);
  }

  List<LessonCategoryModel> _mergeLocalExpansion(
    List<LessonCategoryModel> remoteCategories,
    List<LessonCategoryModel> localCategories,
  ) {
    final localById = {
      for (final category in localCategories) category.id: category,
    };
    final remoteIds = <String>{};
    final merged = <LessonCategoryModel>[];

    for (final remoteCategory in remoteCategories) {
      remoteIds.add(remoteCategory.id);
      final localCategory = localById[remoteCategory.id];
      if (localCategory == null) {
        merged.add(remoteCategory);
        continue;
      }

      merged.add(
        LessonCategoryModel(
          id: remoteCategory.id,
          title: _preferRemoteText(remoteCategory.title, localCategory.title),
          description: _preferRemoteText(
            remoteCategory.description,
            localCategory.description,
          ),
          iconKey: _preferRemoteText(
            remoteCategory.iconKey,
            localCategory.iconKey,
          ),
          colorHex: _preferRemoteText(
            localCategory.colorHex,
            remoteCategory.colorHex,
          ),
          lessons: _mergeLessons(
            remoteCategory.lessons,
            localCategory.lessons,
          ),
        ),
      );
    }

    for (final localCategory in localCategories) {
      if (!remoteIds.contains(localCategory.id)) {
        merged.add(localCategory);
      }
    }

    return merged;
  }

  List<LessonModel> _mergeLessons(
    List<LessonModel> remoteLessons,
    List<LessonModel> localLessons,
  ) {
    final lessonIds = remoteLessons.map((lesson) => lesson.id).toSet();
    return [
      ...remoteLessons,
      ...localLessons.where((lesson) => !lessonIds.contains(lesson.id)),
    ];
  }

  String _preferRemoteText(String remote, String local) {
    return remote.trim().isNotEmpty ? remote : local;
  }

  Future<List<LessonCategoryModel>> _loadRemoteCategories(Locale locale) async {
    final lang = locale.languageCode.toLowerCase() == 'en' ? 'en' : 'pt';

    final categoriesData =
        await _supabase.from('lesson_categories').select().order('order_index');

    if (categoriesData.isEmpty) {
      return const [];
    }

    final lessonsData =
        await _supabase.from('lessons').select().order('order_index');
    final sectionsData =
        await _supabase.from('lesson_sections').select().order('order_index');
    final exercisesData =
        await _supabase.from('lesson_exercises').select().order('order_index');
    final optionsData = await _supabase.from('exercise_options').select();

    List<dynamic> pairsData = const [];
    try {
      pairsData =
          await _supabase.from('exercise_pairs').select().order('order_index');
    } catch (_) {
      pairsData = const [];
    }

    final Map<String, List<ExerciseOptionModel>> optionsByExercise = {};
    for (final opt in optionsData) {
      final row = _asMap(opt);
      final exId = row['exercise_id']?.toString() ?? '';
      optionsByExercise.putIfAbsent(exId, () => []);
      optionsByExercise[exId]!.add(
        ExerciseOptionModel(
          id: row['id']?.toString() ?? '',
          label: _localizedText(row, 'label', lang),
        ),
      );
    }

    final Map<String, List<MatchingPairModel>> pairsByExercise = {};
    for (final pair in pairsData) {
      final row = _asMap(pair);
      final exId = row['exercise_id']?.toString() ?? '';
      pairsByExercise.putIfAbsent(exId, () => []);
      pairsByExercise[exId]!.add(
        MatchingPairModel(
          left: _localizedText(row, 'left', lang),
          right: _localizedText(row, 'right', lang),
        ),
      );
    }

    final Map<String, List<LessonExerciseModel>> exercisesByLesson = {};
    for (final ex in exercisesData) {
      final row = _asMap(ex);
      final lessonId = row['lesson_id']?.toString() ?? '';
      exercisesByLesson.putIfAbsent(lessonId, () => []);
      final exId = row['id']?.toString() ?? '';
      exercisesByLesson[lessonId]!.add(
        LessonExerciseModel(
          id: exId,
          type: _parseType(row['type']?.toString()),
          prompt: _localizedText(row, 'prompt', lang),
          options: optionsByExercise[exId] ?? [],
          correctOptionId: row['correct_option_id']?.toString() ??
              row['correctOptionId']?.toString(),
          pairs: pairsByExercise[exId] ?? [],
          explanation: _localizedNullableText(row, 'explanation', lang),
        ),
      );
    }

    final Map<String, List<LessonSectionModel>> sectionsByLesson = {};
    for (final sec in sectionsData) {
      final row = _asMap(sec);
      final lessonId = row['lesson_id']?.toString() ?? '';
      sectionsByLesson.putIfAbsent(lessonId, () => []);
      sectionsByLesson[lessonId]!.add(
        LessonSectionModel(
          title: _localizedText(row, 'title', lang),
          body: _localizedText(row, 'body', lang),
          bullets: _localizedStringList(row, 'bullets', lang),
          highlight: _localizedNullableText(row, 'highlight', lang),
        ),
      );
    }

    final Map<String, List<LessonModel>> lessonsByCategory = {};
    for (final lesson in lessonsData) {
      final row = _asMap(lesson);
      final catId = row['category_id']?.toString() ?? '';
      lessonsByCategory.putIfAbsent(catId, () => []);
      final lessonId = row['id']?.toString() ?? '';
      lessonsByCategory[catId]!.add(
        LessonModel(
          id: lessonId,
          title: _localizedText(row, 'title', lang),
          summary: _localizedText(row, 'summary', lang),
          estimatedMinutes: _parseInt(
            row['estimated_minutes'] ?? row['estimatedMinutes'],
            fallback: 5,
          ),
          difficulty: _localizedText(row, 'difficulty', lang).isEmpty
              ? 'iniciante'
              : _localizedText(row, 'difficulty', lang),
          objectives: _localizedStringList(row, 'objectives', lang),
          sections: sectionsByLesson[lessonId] ?? [],
          exercises: exercisesByLesson[lessonId] ?? [],
          references: _localizedStringList(row, 'references', lang),
          relatedSignIds: _parseStringList(
              row['related_sign_ids'] ?? row['relatedSignIds']),
        ),
      );
    }

    return categoriesData.map((cat) {
      final row = _asMap(cat);
      final catId = row['id']?.toString() ?? '';
      return LessonCategoryModel(
        id: catId,
        title: _localizedText(row, 'title', lang),
        description: _localizedText(row, 'description', lang),
        iconKey: row['icon']?.toString() ?? 'school',
        colorHex: row['color']?.toString() ?? '#2D78BB',
        lessons: lessonsByCategory[catId] ?? [],
      );
    }).toList();
  }

  Future<List<LessonCategoryModel>> _loadLocalCategories(Locale locale) async {
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

  LessonExerciseType _parseType(String? type) {
    switch (type?.trim()) {
      case 'trueFalse':
      case 'true_false':
      case 'truefalse':
        return LessonExerciseType.trueFalse;
      case 'matching':
      case 'match':
        return LessonExerciseType.matching;
      case 'multipleChoice':
      case 'multiple_choice':
      default:
        return LessonExerciseType.multipleChoice;
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  String _localizedText(Map<String, dynamic> row, String key, String lang) {
    final candidates = [
      '${key}_$lang',
      if (lang != 'pt') '${key}_pt',
      key,
    ];

    for (final candidate in candidates) {
      final value = row[candidate];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  String? _localizedNullableText(
    Map<String, dynamic> row,
    String key,
    String lang,
  ) {
    final text = _localizedText(row, key, lang);
    return text.trim().isEmpty ? null : text;
  }

  List<String> _localizedStringList(
    Map<String, dynamic> row,
    String key,
    String lang,
  ) {
    final candidates = [
      '${key}_$lang',
      if (lang != 'pt') '${key}_pt',
      key,
    ];

    for (final candidate in candidates) {
      final parsed = _parseStringList(row[candidate]);
      if (parsed.isNotEmpty) return parsed;
    }
    return const [];
  }

  List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = json.decode(value);
        if (decoded is List) {
          return decoded.map((item) => item.toString()).toList();
        }
      } catch (_) {
        return [value];
      }
    }
    return const [];
  }

  int _parseInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
