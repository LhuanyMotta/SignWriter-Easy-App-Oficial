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
  final String? fsw;
  final int orderIndex;

  const ExerciseOptionModel({
    required this.id,
    required this.label,
    this.mediaUrl,
    this.mediaAsset,
    this.fsw,
    this.orderIndex = 0,
  });

  bool get hasMedia =>
      (mediaUrl != null && mediaUrl!.trim().isNotEmpty) ||
      (mediaAsset != null && mediaAsset!.trim().isNotEmpty);

  bool get hasFsw => fsw != null && fsw!.trim().isNotEmpty;

  factory ExerciseOptionModel.fromMap(Map<String, dynamic> map, {String lang = 'pt'}) {
    final isEn = lang.toLowerCase() == 'en';
    return ExerciseOptionModel(
      id: map['id']?.toString() ?? '',
      label: _localized(map, 'label', isEn) ?? map['label']?.toString() ?? '',
      mediaUrl: map['mediaUrl']?.toString() ?? map['media_url']?.toString(),
      mediaAsset:
          map['mediaAsset']?.toString() ?? map['media_asset']?.toString(),
      fsw: map['fsw']?.toString(),
      orderIndex: _asInt(map['order_index'] ?? map['orderIndex']) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'mediaUrl': mediaUrl,
      'mediaAsset': mediaAsset,
      'fsw': fsw,
      'orderIndex': orderIndex,
    };
  }

  static String? _localized(Map<String, dynamic> map, String base, bool isEn) {
    final primary = map['${base}_${isEn ? "en" : "pt"}']?.toString();
    if (primary != null && primary.trim().isNotEmpty) return primary;
    final fallback = map['${base}_${isEn ? "pt" : "en"}']?.toString();
    if (fallback != null && fallback.trim().isNotEmpty) return fallback;
    return map[base]?.toString();
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class MatchingPairModel {
  final String left;
  final String right;
  final String? leftMediaUrl;
  final String? rightMediaUrl;
  final String? leftFsw;
  final String? rightFsw;
  final int orderIndex;

  const MatchingPairModel({
    required this.left,
    required this.right,
    this.leftMediaUrl,
    this.rightMediaUrl,
    this.leftFsw,
    this.rightFsw,
    this.orderIndex = 0,
  });

  bool get hasLeftVisual =>
      (leftMediaUrl != null && leftMediaUrl!.trim().isNotEmpty) ||
      (leftFsw != null && leftFsw!.trim().isNotEmpty);

  bool get hasRightVisual =>
      (rightMediaUrl != null && rightMediaUrl!.trim().isNotEmpty) ||
      (rightFsw != null && rightFsw!.trim().isNotEmpty);

  factory MatchingPairModel.fromMap(Map<String, dynamic> map, {String lang = 'pt'}) {
    final isEn = lang.toLowerCase() == 'en';
    return MatchingPairModel(
      left: _localized(map, 'left', isEn) ?? map['left']?.toString() ?? '',
      right: _localized(map, 'right', isEn) ?? map['right']?.toString() ?? '',
      leftMediaUrl:
          map['left_media_url']?.toString() ?? map['leftMediaUrl']?.toString(),
      rightMediaUrl:
          map['right_media_url']?.toString() ?? map['rightMediaUrl']?.toString(),
      leftFsw: map['left_fsw']?.toString() ?? map['leftFsw']?.toString(),
      rightFsw: map['right_fsw']?.toString() ?? map['rightFsw']?.toString(),
      orderIndex: _asInt(map['order_index'] ?? map['orderIndex']) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'left': left,
      'right': right,
      'leftMediaUrl': leftMediaUrl,
      'rightMediaUrl': rightMediaUrl,
      'leftFsw': leftFsw,
      'rightFsw': rightFsw,
      'orderIndex': orderIndex,
    };
  }

  static String? _localized(Map<String, dynamic> map, String base, bool isEn) {
    final primary = map['${base}_${isEn ? "en" : "pt"}']?.toString();
    if (primary != null && primary.trim().isNotEmpty) return primary;
    final fallback = map['${base}_${isEn ? "pt" : "en"}']?.toString();
    if (fallback != null && fallback.trim().isNotEmpty) return fallback;
    return map[base]?.toString();
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
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
  final String? fsw;
  final int orderIndex;

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
    this.fsw,
    this.orderIndex = 0,
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

  bool get hasFsw => fsw != null && fsw!.trim().isNotEmpty;

  factory LessonExerciseModel.fromMap(
    Map<String, dynamic> map, {
    String lang = 'pt',
  }) {
    final isEn = lang.toLowerCase() == 'en';
    final options = _parseOptions(map['options'], lang: lang)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final pairs = _parsePairs(map['pairs'], lang: lang)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    return LessonExerciseModel(
      id: map['id']?.toString() ?? '',
      type: parseExerciseType(map['type']?.toString()),
      prompt: _localized(map, 'prompt', isEn) ?? map['prompt']?.toString() ?? '',
      options: options,
      correctOptionId: map['correctOptionId']?.toString() ??
          map['correct_option_id']?.toString(),
      pairs: pairs,
      explanation: _localized(map, 'explanation', isEn),
      mediaUrl: map['mediaUrl']?.toString() ?? map['media_url']?.toString(),
      mediaAsset:
          map['mediaAsset']?.toString() ?? map['media_asset']?.toString(),
      fsw: map['fsw']?.toString(),
      orderIndex: _asInt(map['order_index'] ?? map['orderIndex']) ?? 0,
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
      'fsw': fsw,
      'orderIndex': orderIndex,
    };
  }

  static LessonExerciseType parseExerciseType(String? rawType) {
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

  static List<ExerciseOptionModel> _parseOptions(
    dynamic value, {
    required String lang,
  }) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (item) => ExerciseOptionModel.fromMap(
              Map<String, dynamic>.from(item),
              lang: lang,
            ),
          )
          .toList();
    }
    return [];
  }

  static List<MatchingPairModel> _parsePairs(
    dynamic value, {
    required String lang,
  }) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (item) => MatchingPairModel.fromMap(
              Map<String, dynamic>.from(item),
              lang: lang,
            ),
          )
          .toList();
    }
    return [];
  }

  static String? _localized(Map<String, dynamic> map, String base, bool isEn) {
    final primary = map['${base}_${isEn ? "en" : "pt"}']?.toString();
    if (primary != null && primary.trim().isNotEmpty) return primary;
    final fallback = map['${base}_${isEn ? "pt" : "en"}']?.toString();
    if (fallback != null && fallback.trim().isNotEmpty) return fallback;
    return map[base]?.toString();
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
