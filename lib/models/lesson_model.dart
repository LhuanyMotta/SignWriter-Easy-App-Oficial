import 'lesson_block_model.dart';
import 'lesson_exercise_model.dart';
import 'lesson_source_model.dart';
import 'media_asset_model.dart';

class LessonModel {
  final String id;
  final String title;
  final String summary;
  final int estimatedMinutes;
  final String difficulty;
  final List<String> objectives;
  final List<LessonBlockModel> blocks;
  final List<LessonExerciseModel> exercises;
  final List<String> references;
  final List<String> relatedSignIds;
  final List<LessonSourceModel> sources;
  final List<MediaAssetModel> media;
  final String status;
  final int version;

  const LessonModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.estimatedMinutes,
    required this.difficulty,
    this.objectives = const [],
    this.blocks = const [],
    this.exercises = const [],
    this.references = const [],
    this.relatedSignIds = const [],
    this.sources = const [],
    this.media = const [],
    this.status = 'published',
    this.version = 1,
  });

  bool get hasExercises => exercises.isNotEmpty;
  bool get hasStructuredSources => sources.isNotEmpty;
  bool get isDraft => status.toLowerCase() == 'draft';
  bool get isPublished => status.toLowerCase() == 'published';

  LessonModel copyWith({
    String? id,
    String? title,
    String? summary,
    int? estimatedMinutes,
    String? difficulty,
    List<String>? objectives,
    List<LessonBlockModel>? blocks,
    List<LessonExerciseModel>? exercises,
    List<String>? references,
    List<String>? relatedSignIds,
    List<LessonSourceModel>? sources,
    List<MediaAssetModel>? media,
    String? status,
    int? version,
  }) {
    return LessonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      difficulty: difficulty ?? this.difficulty,
      objectives: objectives ?? this.objectives,
      blocks: blocks ?? this.blocks,
      exercises: exercises ?? this.exercises,
      references: references ?? this.references,
      relatedSignIds: relatedSignIds ?? this.relatedSignIds,
      sources: sources ?? this.sources,
      media: media ?? this.media,
      status: status ?? this.status,
      version: version ?? this.version,
    );
  }

  factory LessonModel.fromMap(Map<String, dynamic> map, {String lang = 'pt'}) {
    final isEn = lang.toLowerCase() == 'en';
    final rawBlocks = map['blocks'];
    final blocks = rawBlocks is List
        ? rawBlocks
            .whereType<Map>()
            .map(
              (item) => LessonBlockModel.fromMap(
                Map<String, dynamic>.from(item),
                lang: lang,
              ),
            )
            .toList()
        : <LessonBlockModel>[];
    blocks.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final rawExercises = map['exercises'];
    final exercises = rawExercises is List
        ? rawExercises
            .whereType<Map>()
            .map(
              (item) => LessonExerciseModel.fromMap(
                Map<String, dynamic>.from(item),
                lang: lang,
              ),
            )
            .toList()
        : <LessonExerciseModel>[];
    exercises.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final rawSources = map['sources'] ?? map['lesson_sources'];
    final sources = rawSources is List
        ? rawSources
            .whereType<Map>()
            .map(
              (item) => LessonSourceModel.fromMap(
                Map<String, dynamic>.from(item),
                lang: lang,
              ),
            )
            .toList()
        : <LessonSourceModel>[];

    final rawMedia = map['media'] ?? map['lesson_media'];
    final media = rawMedia is List
        ? rawMedia
            .whereType<Map>()
            .map(
              (item) {
                final nested = item['media_assets'] ?? item['media'];
                if (nested is Map) {
                  return MediaAssetModel.fromMap(
                    Map<String, dynamic>.from(nested),
                    lang: lang,
                  );
                }
                return MediaAssetModel.fromMap(
                  Map<String, dynamic>.from(item),
                  lang: lang,
                );
              },
            )
            .toList()
        : <MediaAssetModel>[];

    return LessonModel(
      id: map['id']?.toString() ?? '',
      title: _localized(map, 'title', isEn) ?? '',
      summary: _localized(map, 'summary', isEn) ?? '',
      estimatedMinutes: _asInt(map['estimated_minutes'] ?? map['estimatedMinutes']) ?? 5,
      difficulty: _localized(map, 'difficulty', isEn) ?? 'Iniciante',
      objectives: _localizedList(map, 'objectives', isEn),
      blocks: blocks,
      exercises: exercises,
      references: _localizedList(map, 'references', isEn),
      relatedSignIds: _stringList(map['related_sign_ids'] ?? map['relatedSignIds']),
      sources: sources,
      media: media,
      status: map['status']?.toString() ?? 'published',
      version: _asInt(map['version']) ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'estimatedMinutes': estimatedMinutes,
      'difficulty': difficulty,
      'objectives': objectives,
      'blocks': blocks.map((b) => b.toMap()).toList(),
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'references': references,
      'relatedSignIds': relatedSignIds,
      'sources': sources.map((s) => s.toMap()).toList(),
      'media': media.map((m) => m.toMap()).toList(),
      'status': status,
      'version': version,
    };
  }

  static String? _localized(Map<String, dynamic> map, String base, bool isEn) {
    final primary = map['${base}_${isEn ? "en" : "pt"}']?.toString();
    if (primary != null && primary.trim().isNotEmpty) return primary;
    final fallback = map['${base}_${isEn ? "pt" : "en"}']?.toString();
    if (fallback != null && fallback.trim().isNotEmpty) return fallback;
    return map[base]?.toString();
  }

  static List<String> _localizedList(
    Map<String, dynamic> map,
    String base,
    bool isEn,
  ) {
    final primary = map['${base}_${isEn ? "en" : "pt"}'];
    final fallback = map['${base}_${isEn ? "pt" : "en"}'];
    final plain = map[base];
    for (final candidate in [primary, fallback, plain]) {
      if (candidate is List && candidate.isNotEmpty) {
        return candidate.map((e) => e.toString()).toList();
      }
    }
    return const [];
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const [];
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
