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
  });

  bool get hasExercises => exercises.isNotEmpty;

  factory LessonModel.fromMap(Map<String, dynamic> map) {
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
