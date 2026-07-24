import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/learning_progress_model.dart';
import 'learning_progress_service.dart';

/// Progresso local + gancho para sync remoto (`user_lesson_progress`).
class LearningProgressRepository {
  LearningProgressRepository({
    LearningProgressService? localService,
    SupabaseClient? supabase,
  })  : _local = localService ?? LearningProgressService(),
        _supabase = supabase ?? Supabase.instance.client;

  final LearningProgressService _local;
  final SupabaseClient _supabase;

  Future<LearningProgressModel> loadProgress() async {
    final local = await _local.loadProgress();
    try {
      final remote = await _loadRemote();
      if (remote == null) return local;
      return _mergePreferBest(local, remote);
    } catch (_) {
      return local;
    }
  }

  Future<LearningProgressModel> completeLesson({
    required String categoryId,
    required String lessonId,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    final updated = await _local.completeLesson(
      categoryId: categoryId,
      lessonId: lessonId,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
    );

    final entry = updated.lessonProgress(lessonId);
    if (entry != null) {
      await syncRemote(entry);
    }
    return updated;
  }

  /// Envia uma entrada para `user_lesson_progress`. No-op se tabela/RLS ausentes.
  Future<void> syncRemote(LessonProgressEntry entry) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final score = totalScore(entry);
    try {
      await _supabase.from('user_lesson_progress').upsert({
        'user_id': user.id,
        'lesson_id': entry.lessonId,
        'status': entry.completed ? 'completed' : 'in_progress',
        'best_score': score,
        'attempts': entry.attempts,
        'completed_at': entry.completedAt?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Tabela ou RLS ainda não disponíveis — progresso local permanece.
    }
  }

  Future<void> syncAllRemote(LearningProgressModel progress) async {
    for (final entry in progress.lessons.values) {
      await syncRemote(entry);
    }
  }

  Future<LearningProgressModel?> _loadRemote() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final rows = await _supabase
        .from('user_lesson_progress')
        .select()
        .eq('user_id', user.id);

    if (rows.isEmpty) return null;

    final lessons = <String, LessonProgressEntry>{};
    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      final lessonId = row['lesson_id']?.toString() ?? '';
      if (lessonId.isEmpty) continue;

      final status = row['status']?.toString() ?? 'not_started';
      final bestScore = _asDouble(row['best_score']);
      lessons[lessonId] = LessonProgressEntry(
        lessonId: lessonId,
        categoryId: row['category_id']?.toString() ?? '',
        completed: status == 'completed',
        correctAnswers: (bestScore * 100).round(),
        totalQuestions: 100,
        attempts: _asInt(row['attempts']),
        completedAt: row['completed_at'] != null
            ? DateTime.tryParse(row['completed_at'].toString())
            : null,
      );
    }

    return LearningProgressModel(lessons: lessons);
  }

  LearningProgressModel _mergePreferBest(
    LearningProgressModel local,
    LearningProgressModel remote,
  ) {
    final merged = Map<String, LessonProgressEntry>.from(local.lessons);
    for (final entry in remote.lessons.entries) {
      final existing = merged[entry.key];
      if (existing == null) {
        merged[entry.key] = entry.value;
        continue;
      }
      final preferRemote = entry.value.scoreRatio > existing.scoreRatio ||
          (entry.value.completed && !existing.completed);
      if (preferRemote) {
        merged[entry.key] = entry.value.copyWith(
          categoryId: existing.categoryId.isNotEmpty
              ? existing.categoryId
              : entry.value.categoryId,
          attempts: existing.attempts > entry.value.attempts
              ? existing.attempts
              : entry.value.attempts,
        );
      }
    }
    return LearningProgressModel(lessons: merged);
  }

  double totalScore(LessonProgressEntry entry) => entry.scoreRatio;

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
