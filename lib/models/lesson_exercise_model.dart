enum LessonExerciseType {
  multipleChoice,
  trueFalse,
  matching,
}

class ExerciseOptionModel {
  final String id;
  final String label;

  const ExerciseOptionModel({
    required this.id,
    required this.label,
  });

  factory ExerciseOptionModel.fromMap(Map<String, dynamic> map) {
    return ExerciseOptionModel(
      id: map['id']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
    };
  }
}

class MatchingPairModel {
  final String left;
  final String right;

  const MatchingPairModel({
    required this.left,
    required this.right,
  });

  factory MatchingPairModel.fromMap(Map<String, dynamic> map) {
    return MatchingPairModel(
      left: map['left']?.toString() ?? '',
      right: map['right']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'left': left,
      'right': right,
    };
  }
}

class LessonExerciseModel {
  final String id;
  final LessonExerciseType type;
  final String prompt;
  final List<ExerciseOptionModel> options;
  final String? correctOptionId;
  final List<MatchingPairModel> pairs;
  final String? explanation;

  const LessonExerciseModel({
    required this.id,
    required this.type,
    required this.prompt,
    this.options = const [],
    this.correctOptionId,
    this.pairs = const [],
    this.explanation,
  });

  bool get isMultipleChoice => type == LessonExerciseType.multipleChoice;
  bool get isTrueFalse => type == LessonExerciseType.trueFalse;
  bool get isMatching => type == LessonExerciseType.matching;

  factory LessonExerciseModel.fromMap(Map<String, dynamic> map) {
    return LessonExerciseModel(
      id: map['id']?.toString() ?? '',
      type: _parseExerciseType(map['type']?.toString()),
      prompt: map['prompt']?.toString() ?? '',
      options: _parseOptions(map['options']),
      correctOptionId: map['correctOptionId']?.toString(),
      pairs: _parsePairs(map['pairs']),
      explanation: map['explanation']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'prompt': prompt,
      'options': options.map((option) => option.toMap()).toList(),
      'correctOptionId': correctOptionId,
      'pairs': pairs.map((pair) => pair.toMap()).toList(),
      'explanation': explanation,
    };
  }

  static LessonExerciseType _parseExerciseType(String? rawType) {
    switch (rawType) {
      case 'trueFalse':
        return LessonExerciseType.trueFalse;
      case 'matching':
        return LessonExerciseType.matching;
      case 'multipleChoice':
      default:
        return LessonExerciseType.multipleChoice;
    }
  }

  static List<ExerciseOptionModel> _parseOptions(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (item) => ExerciseOptionModel.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }
    return const [];
  }

  static List<MatchingPairModel> _parsePairs(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (item) => MatchingPairModel.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }
    return const [];
  }
}
