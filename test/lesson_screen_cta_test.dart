import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signwriter_easy_app_oficial/models/lesson_category_model.dart';
import 'package:signwriter_easy_app_oficial/models/lesson_exercise_model.dart';
import 'package:signwriter_easy_app_oficial/models/lesson_model.dart';
import 'package:signwriter_easy_app_oficial/services/learning_content_service.dart';
import 'package:signwriter_easy_app_oficial/services/learning_progress_repository.dart';
import 'package:signwriter_easy_app_oficial/services/learning_repository.dart';
import 'package:signwriter_easy_app_oficial/viewmodels/learn_practice_viewmodel.dart';
import 'package:signwriter_easy_app_oficial/views/screens/lesson_screen.dart';

class _FakeLearningRepository implements LearningRepository {
  @override
  LearningCourseSnapshot? get lastSnapshot => null;

  @override
  Future<List<LessonCategoryModel>> loadCategories(Locale locale) async {
    return const [];
  }
}

LessonCategoryModel _category() {
  return const LessonCategoryModel(
    id: 'cat-1',
    title: 'Módulo teste',
    description: 'desc',
    iconKey: 'school',
    colorHex: '#2D78BB',
  );
}

LessonModel _lesson({List<LessonExerciseModel> exercises = const []}) {
  return LessonModel(
    id: 'les-1',
    title: 'Lição de teste',
    summary: 'Objetivo da lição para o aluno ler.',
    estimatedMinutes: 5,
    difficulty: 'Iniciante',
    objectives: const ['Objetivo 1'],
    exercises: exercises,
  );
}

LessonExerciseModel _exercise() {
  return const LessonExerciseModel(
    id: 'ex-1',
    type: LessonExerciseType.multipleChoice,
    prompt: 'Qual a resposta?',
    options: [
      ExerciseOptionModel(id: 'a', label: 'A'),
      ExerciseOptionModel(id: 'b', label: 'B'),
    ],
    correctOptionId: 'a',
  );
}

LearnPracticeViewModel _vm() {
  return LearnPracticeViewModel(
    repository: _FakeLearningRepository(),
    progressRepository: LearningProgressRepository(localOnly: true),
  );
}

Widget _wrap(LessonModel lesson, {LearnPracticeViewModel? vm}) {
  return ChangeNotifierProvider(
    create: (_) => vm ?? _vm(),
    child: MaterialApp(
      home: LessonScreen(
        lesson: lesson,
        category: _category(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LessonScreen CTAs', () {
    testWidgets('sem exercícios mostra Concluir leitura e não Praticar',
        (tester) async {
      await tester.pumpWidget(_wrap(_lesson()));
      await tester.pumpAndSettle();

      expect(find.text('Concluir leitura'), findsOneWidget);
      expect(find.text('Praticar agora'), findsNothing);
    });

    testWidgets('com exercícios mostra Praticar e não Concluir leitura',
        (tester) async {
      await tester.pumpWidget(
        _wrap(_lesson(exercises: [_exercise()])),
      );
      await tester.pumpAndSettle();

      expect(find.text('Praticar agora'), findsOneWidget);
      expect(find.text('Concluir leitura'), findsNothing);
    });

    testWidgets('Concluir leitura grava progresso e fecha a tela',
        (tester) async {
      final vm = _vm();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => LessonScreen(
                            lesson: _lesson(),
                            category: _category(),
                          ),
                        ),
                      );
                    },
                    child: const Text('Abrir aula'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Abrir aula'));
      await tester.pumpAndSettle();

      expect(find.byType(LessonScreen), findsOneWidget);

      await tester.ensureVisible(find.text('Concluir leitura'));
      await tester.tap(find.text('Concluir leitura'));
      await tester.pumpAndSettle();

      expect(find.byType(LessonScreen), findsNothing);
      expect(find.text('Abrir aula'), findsOneWidget);
      expect(vm.isLessonCompleted('les-1'), isTrue);
      final entry = vm.progressForLesson('les-1');
      expect(entry?.correctAnswers, 0);
      expect(entry?.totalQuestions, 0);
    });
  });
}
