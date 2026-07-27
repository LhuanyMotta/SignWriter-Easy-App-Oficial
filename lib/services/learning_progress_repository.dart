import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/learning_progress_model.dart';
import 'learning_progress_service.dart';

/// Progresso local + sync remoto (`user_lesson_progress`).
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
    } on PostgrestException catch (error, stack) {
      debugPrint('Falha ao carregar progresso remoto: $error\n$stack');
      return local;
    } catch (error, stack) {
      debugPrint('Erro inesperado no progresso remoto: $error\n$stack');
      return local;
    }
  }

  Future<LearningProgressModel> completeLesson({
    required String categoryId,
    required String lessonId,
    required int correctAnswers,
    required int totalQuestions,
    String? lastBlockId,
  }) async {
    final updated = await _local.completeLesson(
      categoryId: categoryId,
      lessonId: lessonId,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      lastBlockId: lastBlockId,
    );

    final entry = updated.lessonProgress(lessonId);
    if (entry != null) {
      await syncRemote(entry);
    }
    return updated;
  }

  Future<void> syncRemote(LessonProgressEntry entry) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final score = totalScore(entry);
    try {
      await _supabase.from('user_lesson_progress').upsert({
        'user_id': user.id,
        'lesson_id': entry.lessonId,
        'category_id': entry.categoryId.isEmpty ? null : entry.categoryId,
        'status': entry.status.isNotEmpty
            ? entry.status
            : (entry.completed ? 'completed' : 'in_progress'),
        'best_score': score,
        'attempts': entry.attempts,
        'last_block_id': entry.lastBlockId,
        'completed_at': entry.completedAt?.toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        // Campos legados ainda presentes no schema.
        'completed': entry.completed,
        'score': (score * 100).round(),
      });
    } on PostgrestException catch (error, stack) {
      debugPrint('RLS/sync progresso falhou: $error\n$stack');
    } catch (error, stack) {
      debugPrint('Erro ao sincronizar progresso: $error\n$stack');
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
      final completed = status == 'completed' || row['completed'] == true;

      lessons[lessonId] = LessonProgressEntry(
        lessonId: lessonId,
        categoryId: row['category_id']?.toString() ?? '',
        completed: completed,
        correctAnswers: (bestScore * 100).round(),
        totalQuestions: 100,
        attempts: _asInt(row['attempts']),
        completedAt: row['completed_at'] != null
            ? DateTime.tryParse(row['completed_at'].toString())
            : null,
        status: status,
        bestScore: bestScore,
        lastBlockId: row['last_block_id']?.toString(),
        updatedAt: row['updated_at'] != null
            ? DateTime.tryParse(row['updated_at'].toString())
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
          lastBlockId: entry.value.lastBlockId ?? existing.lastBlockId,
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
