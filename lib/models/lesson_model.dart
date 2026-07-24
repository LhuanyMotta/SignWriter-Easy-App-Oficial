import 'lesson_block_model.dart';
import 'lesson_exercise_model.dart';
import 'lesson_section_model.dart';

class LessonModel {
  final String id;
  final String title;
  final String summary;
  final int estimatedMinutes;
  final String difficulty;
  final List<String> objectives;
  final List<LessonSectionModel> sections;
  final List<LessonExerciseModel> exercises;
  final List<String> references;
  final List<String> relatedSignIds;
  final List<LessonBlockModel> explicitBlocks;
  final String status;

  const LessonModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.estimatedMinutes,
    required this.difficulty,
    this.objectives = const [],
    this.sections = const [],
    this.exercises = const [],
    this.references = const [],
    this.relatedSignIds = const [],
    this.explicitBlocks = const [],
    this.status = 'published',
  });

  bool get hasExercises => exercises.isNotEmpty;

  /// Blocos explícitos ou derivados das seções legadas.
  List<LessonBlockModel> get blocks {
    if (explicitBlocks.isNotEmpty) return explicitBlocks;
    return LessonBlockModel.fromSections(sections);
  }

  LessonModel copyWith({
    String? id,
    String? title,
    String? summary,
    int? estimatedMinutes,
    String? difficulty,
    List<String>? objectives,
    List<LessonSectionModel>? sections,
    List<LessonExerciseModel>? exercises,
    List<String>? references,
    List<String>? relatedSignIds,
    List<LessonBlockModel>? explicitBlocks,
    String? status,
  }) {
    return LessonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      difficulty: difficulty ?? this.difficulty,
      objectives: objectives ?? this.objectives,
      sections: sections ?? this.sections,
      exercises: exercises ?? this.exercises,
      references: references ?? this.references,
      relatedSignIds: relatedSignIds ?? this.relatedSignIds,
      explicitBlocks: explicitBlocks ?? this.explicitBlocks,
      status: status ?? this.status,
    );
  }

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    final rawBlocks = map['blocks'];
    final explicitBlocks = rawBlocks is List
        ? rawBlocks
            .whereType<Map>()
            .map(
              (item) => LessonBlockModel.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : const <LessonBlockModel>[];

    return LessonModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      summary: map['summary']?.toString() ?? '',
      estimatedMinutes: _parseInt(map['estimatedMinutes']),
      difficulty: map['difficulty']?.toString() ?? '',
      objectives: _parseStringList(map['objectives']),
      sections: _parseSections(map['sections']),
      exercises: _parseExercises(map['exercises']),
      references: _parseStringList(map['references']),
      relatedSignIds: _parseStringList(map['relatedSignIds']),
      explicitBlocks: explicitBlocks,
      status: map['status']?.toString() ?? 'published',
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
      'sections': sections.map((section) => section.toMap()).toList(),
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
      'references': references,
      'relatedSignIds': relatedSignIds,
      'blocks': explicitBlocks.map((block) => block.toMap()).toList(),
      'status': status,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }

  static List<LessonSectionModel> _parseSections(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (item) => LessonSectionModel.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }
    return const [];
  }

  static List<LessonExerciseModel> _parseExercises(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (item) => LessonExerciseModel.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }
    return const [];
  }
}
