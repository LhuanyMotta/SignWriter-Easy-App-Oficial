import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signwriter_easy_app_oficial/models/learning_progress_model.dart';
import 'package:signwriter_easy_app_oficial/services/learning_progress_service.dart';

void main() {
  group('LearningProgressService.completeLesson', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('conclusão sem exercícios usa 0/0 sem nota 100%', () async {
      final service = LearningProgressService();
      final progress = await service.completeLesson(
        categoryId: 'cat-1',
        lessonId: 'les-1',
        correctAnswers: 0,
        totalQuestions: 0,
      );

      final entry = progress.lessonProgress('les-1');
      expect(entry, isNotNull);
      expect(entry!.completed, isTrue);
      expect(entry.correctAnswers, 0);
      expect(entry.totalQuestions, 0);
      expect(entry.bestScore, 0.0);
      expect(entry.scoreRatio, 0.0);
      expect(entry.isReadingCompletion, isTrue);
    });

    test('conclusão com exercícios registra score real', () async {
      final service = LearningProgressService();
      final progress = await service.completeLesson(
        categoryId: 'cat-1',
        lessonId: 'les-2',
        correctAnswers: 2,
        totalQuestions: 4,
      );

      final entry = progress.lessonProgress('les-2');
      expect(entry, isNotNull);
      expect(entry!.completed, isTrue);
      expect(entry.correctAnswers, 2);
      expect(entry.totalQuestions, 4);
      expect(entry.bestScore, 0.5);
      expect(entry.isReadingCompletion, isFalse);
    });

    test('melhor score anterior é preservado', () async {
      final service = LearningProgressService();
      await service.completeLesson(
        categoryId: 'cat-1',
        lessonId: 'les-3',
        correctAnswers: 3,
        totalQuestions: 3,
      );
      final second = await service.completeLesson(
        categoryId: 'cat-1',
        lessonId: 'les-3',
        correctAnswers: 1,
        totalQuestions: 3,
      );

      final entry = second.lessonProgress('les-3');
      expect(entry!.bestScore, 1.0);
      expect(entry.correctAnswers, 1);
      expect(entry.totalQuestions, 3);
      expect(entry.attempts, 2);
    });

    test('persistência: progresso fica disponível após reload', () async {
      final service = LearningProgressService();
      await service.completeLesson(
        categoryId: 'cat-1',
        lessonId: 'les-persist',
        correctAnswers: 0,
        totalQuestions: 0,
      );

      final reloaded = await LearningProgressService().loadProgress();
      final entry = reloaded.lessonProgress('les-persist');
      expect(entry, isNotNull);
      expect(entry!.completed, isTrue);
      expect(entry.bestScore, 0.0);
    });
  });

  group('LessonProgressEntry scoreRatio', () {
    test('leitura concluída não reporta 100%', () {
      const entry = LessonProgressEntry(
        lessonId: 'r1',
        categoryId: 'c1',
        completed: true,
        correctAnswers: 0,
        totalQuestions: 0,
        attempts: 1,
        bestScore: 0,
      );
      expect(entry.scoreRatio, 0.0);
      expect(entry.isReadingCompletion, isTrue);
    });

    test('quiz perfeito reporta 100%', () {
      const entry = LessonProgressEntry(
        lessonId: 'q1',
        categoryId: 'c1',
        completed: true,
        correctAnswers: 4,
        totalQuestions: 4,
        attempts: 1,
        bestScore: 1.0,
      );
      expect(entry.scoreRatio, 1.0);
      expect(entry.isReadingCompletion, isFalse);
    });
  });
}
