import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_progress_model.dart';

class LearningProgressService {
  static const String _progressKey = 'learning_progress_v1';

  Future<LearningProgressModel> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);

    if (raw == null || raw.isEmpty) {
      return LearningProgressModel.empty();
    }

    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        return LearningProgressModel.fromMap(decoded);
      }
    } catch (_) {
      return LearningProgressModel.empty();
    }

    return LearningProgressModel.empty();
  }

  Future<LearningProgressModel> completeLesson({
    required String categoryId,
    required String lessonId,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadProgress();
    final previous = current.lessonProgress(lessonId);

    final updated = current.upsertLesson(
      LessonProgressEntry(
        lessonId: lessonId,
        categoryId: categoryId,
        completed: true,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        attempts: (previous?.attempts ?? 0) + 1,
        completedAt: DateTime.now(),
      ),
    );

    await prefs.setString(_progressKey, json.encode(updated.toMap()));
    return updated;
  }

  Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
  }
}
