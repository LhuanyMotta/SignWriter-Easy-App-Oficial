class LessonProgressEntry {
  final String lessonId;
  final String categoryId;
  final bool completed;
  final int correctAnswers;
  final int totalQuestions;
  final int attempts;
  final DateTime? completedAt;
  final String status;
  final double bestScore;
  final String? lastBlockId;
  final DateTime? updatedAt;

  const LessonProgressEntry({
    required this.lessonId,
    required this.categoryId,
    required this.completed,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.attempts,
    this.completedAt,
    this.status = 'not_started',
    this.bestScore = 0,
    this.lastBlockId,
    this.updatedAt,
  });

  double get scoreRatio {
    // Leitura sem quiz: sem nota — distinto de pontuação perfeita.
    if (totalQuestions <= 0) return 0;
    // Preferir bestScore explícito (ex.: sync remoto só com best_score).
    if (bestScore > 0) return bestScore.clamp(0.0, 1.0);
    return (correctAnswers / totalQuestions).clamp(0.0, 1.0);
  }

  /// Conclusão por leitura (sem exercícios / sem questões avaliadas).
  bool get isReadingCompletion => completed && totalQuestions <= 0;

  factory LessonProgressEntry.fromMap(Map<String, dynamic> map) {
    final completed =
        map['completed'] == true || map['status']?.toString() == 'completed';
    final totalQuestions =
        _parseInt(map['totalQuestions'] ?? map['total_questions']);
    final correctAnswers =
        _parseInt(map['correctAnswers'] ?? map['correct_answers']);
    final bestScore = _parseDouble(map['bestScore'] ?? map['best_score']);
    // Leitura sem quiz: zera nota mesmo se legado salvou bestScore=1.0.
    final derivedBest = totalQuestions <= 0
        ? 0.0
        : bestScore > 0
            ? bestScore.clamp(0.0, 1.0)
            : (correctAnswers / totalQuestions).clamp(0.0, 1.0);

    return LessonProgressEntry(
      lessonId:
          map['lessonId']?.toString() ?? map['lesson_id']?.toString() ?? '',
      categoryId:
          map['categoryId']?.toString() ?? map['category_id']?.toString() ?? '',
      completed: completed,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      attempts: _parseInt(map['attempts']),
      completedAt: _parseDate(map['completedAt'] ?? map['completed_at']),
      status: map['status']?.toString() ??
          (completed ? 'completed' : 'not_started'),
      bestScore: derivedBest,
      lastBlockId:
          map['lastBlockId']?.toString() ?? map['last_block_id']?.toString(),
      updatedAt: _parseDate(map['updatedAt'] ?? map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'categoryId': categoryId,
      'completed': completed,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'attempts': attempts,
      'completedAt': completedAt?.toIso8601String(),
      'status': status,
      'bestScore': bestScore,
      'lastBlockId': lastBlockId,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  LessonProgressEntry copyWith({
    String? lessonId,
    String? categoryId,
    bool? completed,
    int? correctAnswers,
    int? totalQuestions,
    int? attempts,
    DateTime? completedAt,
    String? status,
    double? bestScore,
    String? lastBlockId,
    DateTime? updatedAt,
  }) {
    return LessonProgressEntry(
      lessonId: lessonId ?? this.lessonId,
      categoryId: categoryId ?? this.categoryId,
      completed: completed ?? this.completed,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      attempts: attempts ?? this.attempts,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      bestScore: bestScore ?? this.bestScore,
      lastBlockId: lastBlockId ?? this.lastBlockId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class LearningProgressModel {
  final Map<String, LessonProgressEntry> lessons;

  const LearningProgressModel({
    this.lessons = const {},
  });

  factory LearningProgressModel.empty() => const LearningProgressModel();

  factory LearningProgressModel.fromMap(Map<String, dynamic> map) {
    final rawLessons = map['lessons'];
    if (rawLessons is! Map) {
      return LearningProgressModel.empty();
    }

    final parsedLessons = <String, LessonProgressEntry>{};
    for (final entry in rawLessons.entries) {
      final value = entry.value;
      if (value is Map) {
        parsedLessons[entry.key.toString()] = LessonProgressEntry.fromMap(
          Map<String, dynamic>.from(value),
        );
      }
    }

    return LearningProgressModel(lessons: parsedLessons);
  }

  Map<String, dynamic> toMap() {
    return {
      'lessons': lessons.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
    };
  }

  LessonProgressEntry? lessonProgress(String lessonId) => lessons[lessonId];

  bool isLessonCompleted(String lessonId) =>
      lessons[lessonId]?.completed == true;

  int completedLessonsCount(Iterable<String> lessonIds) {
    return lessonIds.where(isLessonCompleted).length;
  }

  double completionRate(Iterable<String> lessonIds) {
    final ids = lessonIds.toList();
    if (ids.isEmpty) return 0;
    return completedLessonsCount(ids) / ids.length;
  }

  LearningProgressModel upsertLesson(LessonProgressEntry entry) {
    final updated = Map<String, LessonProgressEntry>.from(lessons);
    updated[entry.lessonId] = entry;
    return LearningProgressModel(lessons: updated);
  }

  int get completedLessons =>
      lessons.values.where((entry) => entry.completed).length;
}
