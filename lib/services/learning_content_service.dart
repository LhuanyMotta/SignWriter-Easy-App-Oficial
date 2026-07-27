import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/content_source_model.dart';
import '../models/lesson_block_model.dart';
import '../models/lesson_category_model.dart';
import '../models/lesson_exercise_model.dart';
import '../models/lesson_model.dart';
import '../models/lesson_source_model.dart';
import '../models/media_asset_model.dart';
import 'learning_content_cache.dart';

enum LearningContentFailureKind {
  network,
  empty,
  unauthorized,
  invalid,
  unknown,
}

class LearningContentException implements Exception {
  final LearningContentFailureKind kind;
  final String message;
  final Object? cause;

  const LearningContentException(
    this.kind,
    this.message, {
    this.cause,
  });

  @override
  String toString() => 'LearningContentException($kind): $message';
}

class LearningCourseSnapshot {
  final List<LessonCategoryModel> categories;
  final bool fromCache;
  final DateTime? syncedAt;
  final String contentVersion;

  const LearningCourseSnapshot({
    required this.categories,
    this.fromCache = false,
    this.syncedAt,
    this.contentVersion = '0',
  });
}

/// Carrega o CMS pedagógico do Supabase (blocos, exercícios, fontes, mídias).
class LearningContentService {
  LearningContentService({
    SupabaseClient? supabase,
    LearningContentCache? cache,
  })  : _supabase = supabase ?? Supabase.instance.client,
        _cache = cache ?? LearningContentCache();

  final SupabaseClient _supabase;
  final LearningContentCache _cache;

  /// Resultado da última carga (útil para banners offline).
  LearningCourseSnapshot? lastSnapshot;

  Future<List<LessonCategoryModel>> loadCategories(
    Locale locale, {
    bool includeDrafts = false,
  }) async {
    final snapshot = await loadCourse(locale, includeDrafts: includeDrafts);
    return snapshot.categories;
  }

  Future<LearningCourseSnapshot> loadCourse(
    Locale locale, {
    bool includeDrafts = false,
  }) async {
    final lang = locale.languageCode.toLowerCase() == 'en' ? 'en' : 'pt';

    try {
      final remote = await _loadRemoteCourse(lang, includeDrafts: includeDrafts);
      final version = _computeVersion(remote);
      // Cache offline = visão do aluno (sem rascunhos).
      if (!includeDrafts) {
        try {
          if (remote.isEmpty) {
            await _cache.clear();
          } else {
            await _cache.save(
              categories: remote,
              localeCode: lang,
              contentVersion: version,
            );
          }
        } catch (error, stack) {
          debugPrint('Falha ao gravar cache do curso: $error\n$stack');
        }
      }

      final snapshot = LearningCourseSnapshot(
        categories: remote,
        fromCache: false,
        syncedAt: DateTime.now().toUtc(),
        contentVersion: version,
      );
      lastSnapshot = snapshot;
      return snapshot;
    } on LearningContentException catch (error) {
      final cached = await _cache.load();
      if (cached != null && cached.localeCode == lang) {
        final snapshot = LearningCourseSnapshot(
          categories: cached.categories,
          fromCache: true,
          syncedAt: cached.syncedAt,
          contentVersion: cached.contentVersion,
        );
        lastSnapshot = snapshot;
        debugPrint(
          'Usando cache offline após falha remota (${error.kind}): ${error.message}',
        );
        return snapshot;
      }
      rethrow;
    } on PostgrestException catch (error, stack) {
      debugPrint('PostgrestException no curso: $error\n$stack');
      final cached = await _cache.load();
      if (cached != null) {
        lastSnapshot = LearningCourseSnapshot(
          categories: cached.categories,
          fromCache: true,
          syncedAt: cached.syncedAt,
          contentVersion: cached.contentVersion,
        );
        return lastSnapshot!;
      }
      final kind = error.code == '42501'
          ? LearningContentFailureKind.unauthorized
          : LearningContentFailureKind.network;
      throw LearningContentException(kind, error.message, cause: error);
    } catch (error, stack) {
      debugPrint('Erro ao carregar curso: $error\n$stack');
      final cached = await _cache.load();
      if (cached != null) {
        lastSnapshot = LearningCourseSnapshot(
          categories: cached.categories,
          fromCache: true,
          syncedAt: cached.syncedAt,
          contentVersion: cached.contentVersion,
        );
        return lastSnapshot!;
      }
      throw LearningContentException(
        LearningContentFailureKind.unknown,
        'Não foi possível carregar o conteúdo pedagógico.',
        cause: error,
      );
    }
  }

  Future<List<LessonCategoryModel>> _loadRemoteCourse(
    String lang, {
    required bool includeDrafts,
  }) async {
    final categoriesData = await _supabase
        .from('lesson_categories')
        .select()
        .order('order_index');

    final lessonsRaw =
        await _supabase.from('lessons').select().order('order_index');

    final blocksData =
        await _supabase.from('lesson_blocks').select().order('order_index');

    final exercisesData =
        await _supabase.from('lesson_exercises').select().order('order_index');

    final optionsData = await _supabase
        .from('exercise_options')
        .select()
        .order('order_index');

    final pairsData =
        await _supabase.from('exercise_pairs').select().order('order_index');

    final sourcesData = await _supabase.from('content_sources').select();
    final lessonSourcesData = await _supabase.from('lesson_sources').select();
    final mediaAssetsData = await _supabase.from('media_assets').select();
    final lessonMediaData =
        await _supabase.from('lesson_media').select().order('order_index');

    // Curso vazio é válido (admin a criar do zero / aluno sem conteúdo).
    if (categoriesData.isEmpty && lessonsRaw.isEmpty) {
      return const <LessonCategoryModel>[];
    }

    final mediaById = <String, MediaAssetModel>{};
    for (final raw in mediaAssetsData) {
      final row = _asMap(raw);
      final asset = MediaAssetModel.fromMap(row, lang: lang);
      final resolved = _resolveStorageUrl(asset);
      mediaById[asset.id] = resolved;
    }

    final sourcesById = <String, ContentSourceModel>{};
    for (final raw in sourcesData) {
      final row = _asMap(raw);
      final source = ContentSourceModel.fromMap(row, lang: lang);
      sourcesById[source.id] = source;
    }

    final optionsByExercise = <String, List<ExerciseOptionModel>>{};
    for (final raw in optionsData) {
      final row = _asMap(raw);
      final exerciseId = row['exercise_id']?.toString() ?? '';
      optionsByExercise.putIfAbsent(exerciseId, () => []);
      optionsByExercise[exerciseId]!.add(
        ExerciseOptionModel.fromMap(row, lang: lang),
      );
    }
    for (final list in optionsByExercise.values) {
      list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    }

    final pairsByExercise = <String, List<MatchingPairModel>>{};
    for (final raw in pairsData) {
      final row = _asMap(raw);
      final exerciseId = row['exercise_id']?.toString() ?? '';
      pairsByExercise.putIfAbsent(exerciseId, () => []);
      pairsByExercise[exerciseId]!.add(
        MatchingPairModel.fromMap(row, lang: lang),
      );
    }
    for (final list in pairsByExercise.values) {
      list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    }

    final exercisesByLesson = <String, List<LessonExerciseModel>>{};
    for (final raw in exercisesData) {
      final row = _asMap(raw);
      final lessonId = row['lesson_id']?.toString() ?? '';
      final exerciseId = row['id']?.toString() ?? '';
      exercisesByLesson.putIfAbsent(lessonId, () => []);
      exercisesByLesson[lessonId]!.add(
        LessonExerciseModel.fromMap({
          ...row,
          'options': optionsByExercise[exerciseId] ?? const [],
          'pairs': pairsByExercise[exerciseId] ?? const [],
        }, lang: lang),
      );
    }
    for (final list in exercisesByLesson.values) {
      list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    }

    final blocksByLesson = <String, List<LessonBlockModel>>{};
    for (final raw in blocksData) {
      final row = _asMap(raw);
      final lessonId = row['lesson_id']?.toString() ?? '';
      final mediaId = row['media_id']?.toString();
      final media = mediaId == null ? null : mediaById[mediaId];
      blocksByLesson.putIfAbsent(lessonId, () => []);
      blocksByLesson[lessonId]!.add(
        LessonBlockModel.fromMap(row, lang: lang, media: media),
      );
    }
    for (final list in blocksByLesson.values) {
      list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    }

    final sourcesByLesson = <String, List<LessonSourceModel>>{};
    for (final raw in lessonSourcesData) {
      final row = _asMap(raw);
      final lessonId = row['lesson_id']?.toString() ?? '';
      final sourceId = row['source_id']?.toString() ?? '';
      sourcesByLesson.putIfAbsent(lessonId, () => []);
      sourcesByLesson[lessonId]!.add(
        LessonSourceModel.fromMap(
          row,
          lang: lang,
          source: sourcesById[sourceId],
        ),
      );
    }

    final mediaByLesson = <String, List<MediaAssetModel>>{};
    for (final raw in lessonMediaData) {
      final row = _asMap(raw);
      final lessonId = row['lesson_id']?.toString() ?? '';
      final mediaId = row['media_id']?.toString() ?? '';
      final asset = mediaById[mediaId];
      if (asset == null) continue;
      mediaByLesson.putIfAbsent(lessonId, () => []);
      mediaByLesson[lessonId]!.add(asset);
    }

    final lessonsByCategory = <String, List<LessonModel>>{};
    for (final raw in lessonsRaw) {
      final row = _asMap(raw);
      final status = (row['status']?.toString() ?? 'published').toLowerCase();
      final isPublished = status == 'published';
      if (!isPublished && !includeDrafts) continue;

      final lessonId = row['id']?.toString() ?? '';
      final categoryId = row['category_id']?.toString() ?? '';
      lessonsByCategory.putIfAbsent(categoryId, () => []);
      lessonsByCategory[categoryId]!.add(
        LessonModel(
          id: lessonId,
          title: _localizedText(row, 'title', lang),
          summary: _localizedText(row, 'summary', lang),
          estimatedMinutes: _parseInt(
            row['estimated_minutes'] ?? row['estimatedMinutes'],
            fallback: 5,
          ),
          difficulty: () {
            final value = _localizedText(row, 'difficulty', lang);
            return value.isEmpty ? 'Iniciante' : value;
          }(),
          objectives: _localizedStringList(row, 'objectives', lang),
          blocks: blocksByLesson[lessonId] ?? const [],
          exercises: exercisesByLesson[lessonId] ?? const [],
          references: _localizedStringList(row, 'references', lang),
          relatedSignIds: _parseStringList(
            row['related_sign_ids'] ?? row['relatedSignIds'],
          ),
          sources: sourcesByLesson[lessonId] ?? const [],
          media: mediaByLesson[lessonId] ?? const [],
          status: status,
          version: _parseInt(row['version'], fallback: 1),
        ),
      );
    }

    final categories = <LessonCategoryModel>[];
    for (final raw in categoriesData) {
      final row = _asMap(raw);
      final categoryStatus =
          (row['status']?.toString() ?? 'published').toLowerCase();
      if (categoryStatus != 'published' && !includeDrafts) continue;

      final categoryId = row['id']?.toString() ?? '';
      final lessons = List<LessonModel>.from(
        lessonsByCategory[categoryId] ?? const [],
      )..sort((a, b) {
          // Mantém ordem já trazida do banco; fallback por id.
          return a.id.compareTo(b.id);
        });

      // Aluno só vê categorias com ao menos uma lição publicada.
      if (!includeDrafts && lessons.isEmpty) continue;

      categories.add(
        LessonCategoryModel(
          id: categoryId,
          title: _localizedText(row, 'title', lang),
          description: _localizedText(row, 'description', lang),
          iconKey: row['icon']?.toString() ?? 'school',
          colorHex: row['color']?.toString() ?? '#2D78BB',
          lessons: lessons,
          status: categoryStatus,
        ),
      );
    }

    // Curso vazio é válido (ex.: autor apagou tudo / aluno sem conteúdo).
    return categories;
  }

  MediaAssetModel _resolveStorageUrl(MediaAssetModel asset) {
    if (asset.externalUrl != null && asset.externalUrl!.trim().isNotEmpty) {
      return asset;
    }
    final bucket = asset.storageBucket?.trim();
    final path = asset.storagePath?.trim();
    if (bucket == null || bucket.isEmpty || path == null || path.isEmpty) {
      return asset;
    }
    try {
      final url = _supabase.storage.from(bucket).getPublicUrl(path);
      return asset.copyWith(externalUrl: url);
    } catch (error, stack) {
      debugPrint('Falha ao resolver URL de mídia ${asset.id}: $error\n$stack');
      return asset;
    }
  }

  String _computeVersion(List<LessonCategoryModel> categories) {
    var lessonCount = 0;
    var blockCount = 0;
    var versionSum = 0;
    for (final category in categories) {
      for (final lesson in category.lessons) {
        lessonCount += 1;
        blockCount += lesson.blocks.length;
        versionSum += lesson.version;
      }
    }
    return '$lessonCount-$blockCount-$versionSum';
  }

  Map<String, dynamic> _asMap(dynamic item) {
    if (item is Map<String, dynamic>) return item;
    if (item is Map) return Map<String, dynamic>.from(item);
    return <String, dynamic>{};
  }

  String _localizedText(Map<String, dynamic> row, String base, String lang) {
    final isEn = lang == 'en';
    final primary = row['${base}_${isEn ? "en" : "pt"}']?.toString();
    if (primary != null && primary.trim().isNotEmpty) return primary;
    final fallback = row['${base}_${isEn ? "pt" : "en"}']?.toString();
    if (fallback != null && fallback.trim().isNotEmpty) return fallback;
    return row[base]?.toString() ?? '';
  }

  List<String> _localizedStringList(
    Map<String, dynamic> row,
    String base,
    String lang,
  ) {
    final isEn = lang == 'en';
    for (final key in [
      '${base}_${isEn ? "en" : "pt"}',
      '${base}_${isEn ? "pt" : "en"}',
      base,
    ]) {
      final value = row[key];
      if (value is List && value.isNotEmpty) {
        return value.map((e) => e.toString()).toList();
      }
    }
    return const [];
  }

  List<String> _parseStringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return const [];
  }

  int _parseInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
