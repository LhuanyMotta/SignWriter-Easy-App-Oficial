import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signwriter_easy_app_oficial/models/lesson_category_model.dart';
import 'package:signwriter_easy_app_oficial/models/lesson_model.dart';
import 'package:signwriter_easy_app_oficial/services/learning_content_service.dart';
import 'package:signwriter_easy_app_oficial/services/learning_progress_repository.dart';
import 'package:signwriter_easy_app_oficial/services/learning_repository.dart';
import 'package:signwriter_easy_app_oficial/viewmodels/learn_practice_viewmodel.dart';

class _FakeLearningRepository implements LearningRepository {
  _FakeLearningRepository(this._categories);

  final List<LessonCategoryModel> _categories;

  @override
  LearningCourseSnapshot? get lastSnapshot => null;

  @override
  Future<List<LessonCategoryModel>> loadCategories(Locale locale) async {
    return _categories;
  }
}

LessonCategoryModel _category({
  required String id,
  required List<LessonModel> lessons,
}) {
  return LessonCategoryModel(
    id: id,
    title: 'Módulo $id',
    description: 'desc',
    iconKey: 'school',
    colorHex: '#2D78BB',
    lessons: lessons,
  );
}

LessonModel _simpleLesson({
  required String id,
  String status = 'published',
}) {
  return LessonModel(
    id: id,
    title: 'Lição $id',
    summary: 'Resumo',
    estimatedMinutes: 5,
    difficulty: 'Iniciante',
    status: status,
  );
}

LearnPracticeViewModel _buildVm(List<LessonCategoryModel> categories) {
  return LearnPracticeViewModel(
    repository: _FakeLearningRepository(categories),
    progressRepository: LearningProgressRepository(localOnly: true),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('nextLessonTarget', () {
    test('percurso só com rascunhos não sugere Continuar', () async {
      final vm = _buildVm([
        _category(
          id: 'cat-1',
          lessons: [
            _simpleLesson(id: 'd1', status: 'draft'),
            _simpleLesson(id: 'd2', status: 'draft'),
          ],
        ),
      ]);
      await vm.initialize(const Locale('pt'), includeDrafts: true);

      expect(vm.nextLessonTarget(), isNull);
      expect(vm.totalLessons, 0);
    });

    test('percurso misto sugere a primeira published incompleta', () async {
      final vm = _buildVm([
        _category(
          id: 'cat-1',
          lessons: [
            _simpleLesson(id: 'd1', status: 'draft'),
            _simpleLesson(id: 'p1', status: 'published'),
            _simpleLesson(id: 'p2', status: 'published'),
          ],
        ),
      ]);
      await vm.initialize(const Locale('pt'), includeDrafts: true);

      final target = vm.nextLessonTarget();
      expect(target, isNotNull);
      expect(target!.lesson.id, 'p1');
      expect(target.category.id, 'cat-1');
      expect(vm.totalLessons, 2);
    });

    test('pula published já concluída', () async {
      final vm = _buildVm([
        _category(
          id: 'cat-1',
          lessons: [
            _simpleLesson(id: 'p1', status: 'published'),
            _simpleLesson(id: 'p2', status: 'published'),
          ],
        ),
      ]);
      await vm.initialize(const Locale('pt'));
      await vm.completeLesson(
        categoryId: 'cat-1',
        lessonId: 'p1',
        correctAnswers: 0,
        totalQuestions: 0,
      );

      final target = vm.nextLessonTarget();
      expect(target?.lesson.id, 'p2');
      expect(vm.completedLessons, 1);
      expect(vm.totalLessons, 2);
    });

    test('totais ignoram rascunhos mesmo com includeDrafts', () async {
      final vm = _buildVm([
        _category(
          id: 'cat-1',
          lessons: [
            _simpleLesson(id: 'd1', status: 'draft'),
            _simpleLesson(id: 'p1', status: 'published'),
          ],
        ),
        _category(
          id: 'cat-2',
          lessons: [
            _simpleLesson(id: 'd2', status: 'draft'),
          ],
        ),
      ]);
      await vm.initialize(const Locale('pt'), includeDrafts: true);

      expect(vm.totalLessons, 1);
      expect(vm.nextLessonTarget()?.lesson.id, 'p1');
    });

    test('ignora status review e archived', () async {
      final vm = _buildVm([
        _category(
          id: 'cat-1',
          lessons: [
            _simpleLesson(id: 'r1', status: 'review'),
            _simpleLesson(id: 'a1', status: 'archived'),
            _simpleLesson(id: 'p1', status: 'published'),
          ],
        ),
      ]);
      await vm.initialize(const Locale('pt'), includeDrafts: true);

      final target = vm.nextLessonTarget();
      expect(target, isNotNull);
      expect(target!.lesson.id, 'p1');
      expect(vm.totalLessons, 1);
    });

    test('só review/archived não sugere Continuar', () async {
      final vm = _buildVm([
        _category(
          id: 'cat-1',
          lessons: [
            _simpleLesson(id: 'r1', status: 'review'),
            _simpleLesson(id: 'a1', status: 'archived'),
          ],
        ),
      ]);
      await vm.initialize(const Locale('pt'), includeDrafts: true);

      expect(vm.nextLessonTarget(), isNull);
      expect(vm.totalLessons, 0);
    });
  });
}
