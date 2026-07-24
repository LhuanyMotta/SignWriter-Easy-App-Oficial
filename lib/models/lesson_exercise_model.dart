enum LessonExerciseType {
  multipleChoice,
  trueFalse,
  matching,
  recognizeSymbol,
  chooseCorrectWriting,
}

class ExerciseOptionModel {
  final String id;
  final String label;
  final String? mediaUrl;
  final String? mediaAsset;

  const ExerciseOptionModel({
    required this.id,
    required this.label,
    this.mediaUrl,
    this.mediaAsset,
  });

  bool get hasMedia =>
      (mediaUrl != null && mediaUrl!.trim().isNotEmpty) ||
      (mediaAsset != null && mediaAsset!.trim().isNotEmpty);

  factory ExerciseOptionModel.fromMap(Map<String, dynamic> map) {
    return ExerciseOptionModel(
      id: map['id']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      mediaUrl: map['mediaUrl']?.toString() ?? map['media_url']?.toString(),
      mediaAsset:
          map['mediaAsset']?.toString() ?? map['media_asset']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'mediaUrl': mediaUrl,
      'mediaAsset': mediaAsset,
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
  final String? mediaUrl;
  final String? mediaAsset;

  const LessonExerciseModel({
    required this.id,
    required this.type,
    required this.prompt,
    this.options = const [],
    this.correctOptionId,
    this.pairs = const [],
    this.explanation,
    this.mediaUrl,
    this.mediaAsset,
  });

  bool get isMultipleChoice => type == LessonExerciseType.multipleChoice;
  bool get isTrueFalse => type == LessonExerciseType.trueFalse;
  bool get isMatching => type == LessonExerciseType.matching;
  bool get isRecognizeSymbol => type == LessonExerciseType.recognizeSymbol;
  bool get isChooseCorrectWriting =>
      type == LessonExerciseType.chooseCorrectWriting;
  bool get usesOptionSelection =>
      isMultipleChoice ||
      isTrueFalse ||
      isRecognizeSymbol ||
      isChooseCorrectWriting;

  bool get hasMedia =>
      (mediaUrl != null && mediaUrl!.trim().isNotEmpty) ||
      (mediaAsset != null && mediaAsset!.trim().isNotEmpty);

  factory LessonExerciseModel.fromMap(Map<String, dynamic> map) {
    return LessonExerciseModel(
      id: map['id']?.toString() ?? '',
      type: _parseExerciseType(map['type']?.toString()),
      prompt: map['prompt']?.toString() ?? '',
      options: _parseOptions(map['options']),
      correctOptionId: map['correctOptionId']?.toString() ??
          map['correct_option_id']?.toString(),
      pairs: _parsePairs(map['pairs']),
      explanation: map['explanation']?.toString(),
      mediaUrl: map['mediaUrl']?.toString() ?? map['media_url']?.toString(),
      mediaAsset:
          map['mediaAsset']?.toString() ?? map['media_asset']?.toString(),
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
      'mediaUrl': mediaUrl,
      'mediaAsset': mediaAsset,
    };
  }

  static LessonExerciseType _parseExerciseType(String? rawType) {
    switch (rawType) {
      case 'trueFalse':
      case 'true_false':
        return LessonExerciseType.trueFalse;
      case 'matching':
      case 'match':
        return LessonExerciseType.matching;
      case 'recognizeSymbol':
      case 'recognize_symbol':
        return LessonExerciseType.recognizeSymbol;
      case 'chooseCorrectWriting':
      case 'choose_correct_writing':
        return LessonExerciseType.chooseCorrectWriting;
      case 'multipleChoice':
      case 'multiple_choice':
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
