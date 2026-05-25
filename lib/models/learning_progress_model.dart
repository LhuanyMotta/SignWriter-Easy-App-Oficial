class LessonProgressEntry {
  final String lessonId;
  final String categoryId;
  final bool completed;
  final int correctAnswers;
  final int totalQuestions;
  final int attempts;
  final DateTime? completedAt;

  const LessonProgressEntry({
    required this.lessonId,
    required this.categoryId,
    required this.completed,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.attempts,
    this.completedAt,
  });

  double get scoreRatio {
    if (totalQuestions <= 0) return completed ? 1 : 0;
    return correctAnswers / totalQuestions;
  }

  factory LessonProgressEntry.fromMap(Map<String, dynamic> map) {
    return LessonProgressEntry(
      lessonId: map['lessonId']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? '',
      completed: map['completed'] == true,
      correctAnswers: _parseInt(map['correctAnswers']),
      totalQuestions: _parseInt(map['totalQuestions']),
      attempts: _parseInt(map['attempts']),
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'].toString())
          : null,
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
  }) {
    return LessonProgressEntry(
      lessonId: lessonId ?? this.lessonId,
      categoryId: categoryId ?? this.categoryId,
      completed: completed ?? this.completed,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      attempts: attempts ?? this.attempts,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
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
