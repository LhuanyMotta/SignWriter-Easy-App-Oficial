import 'package:flutter/material.dart';

import '../models/learning_progress_model.dart';
import '../models/lesson_category_model.dart';
import '../models/lesson_model.dart';
import '../services/learning_progress_repository.dart';
import '../services/learning_repository.dart';
import '../utils/friendly_error.dart';

class LearnPracticeViewModel extends ChangeNotifier {
  LearnPracticeViewModel({
    LearningRepository? repository,
    LearningProgressRepository? progressRepository,
  })  : _repository = repository ?? DefaultLearningRepository(),
        _progressRepository =
            progressRepository ?? LearningProgressRepository();

  final LearningRepository _repository;
  final LearningProgressRepository _progressRepository;

  List<LessonCategoryModel> _categories = [];
  LearningProgressModel _progress = LearningProgressModel.empty();
  bool _isLoading = false;
  bool _isSavingProgress = false;
  bool _isOfflineCache = false;
  DateTime? _cacheSyncedAt;
  String _errorMessage = '';
  String _loadedLanguageCode = '';
  bool _includeDrafts = false;

  List<LessonCategoryModel> get categories => _categories;
  LearningProgressModel get progress => _progress;
  bool get isLoading => _isLoading;
  bool get isSavingProgress => _isSavingProgress;
  bool get isOfflineCache => _isOfflineCache;
  DateTime? get cacheSyncedAt => _cacheSyncedAt;
  String get errorMessage => _errorMessage;
  bool get includeDrafts => _includeDrafts;

  Future<void> initialize(
    Locale locale, {
    bool includeDrafts = false,
  }) async {
    final languageCode = locale.languageCode.toLowerCase();
    if (_loadedLanguageCode == languageCode &&
        _categories.isNotEmpty &&
        _includeDrafts == includeDrafts) {
      return;
    }

    _includeDrafts = includeDrafts;
    _loadedLanguageCode = languageCode;
    await _loadData(Locale(languageCode));
  }

  Future<void> reload({bool? includeDrafts}) async {
    if (includeDrafts != null) {
      _includeDrafts = includeDrafts;
    }
    final locale =
        Locale(_loadedLanguageCode.isEmpty ? 'pt' : _loadedLanguageCode);
    await _loadData(locale);
  }

  Future<void> _loadData(Locale locale) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final repo = _repository;
      if (repo is DefaultLearningRepository) {
        final snapshot = await repo.loadCourse(
          locale,
          includeDrafts: _includeDrafts,
        );
        _categories = snapshot.categories;
        _isOfflineCache = snapshot.fromCache;
        _cacheSyncedAt = snapshot.syncedAt;
      } else {
        _categories = await repo.loadCategories(locale);
        _isOfflineCache = false;
        _cacheSyncedAt = null;
      }
      _progress = await _progressRepository.loadProgress();
    } catch (e) {
      _errorMessage = friendlyError(e);
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  LessonCategoryModel? categoryById(String categoryId) {
    for (final category in _categories) {
      if (category.id == categoryId) {
        return category;
      }
    }
    return null;
  }

  LessonModel? lessonById({
    required String categoryId,
    required String lessonId,
  }) {
    final category = categoryById(categoryId);
    if (category == null) return null;

    for (final lesson in category.lessons) {
      if (lesson.id == lessonId) {
        return lesson;
      }
    }
    return null;
  }

  int get totalLessons {
    return _categories.fold<int>(
      0,
      (sum, category) =>
          sum + category.lessons.where((lesson) => lesson.isPublished).length,
    );
  }

  int get totalExercises {
    return _categories.fold<int>(
      0,
      (sum, category) =>
          sum +
          category.lessons
              .where((lesson) => lesson.isPublished)
              .fold<int>(
                0,
                (lessonSum, lesson) => lessonSum + lesson.exercises.length,
              ),
    );
  }

  int get completedLessons {
    return _progress.completedLessonsCount(
      _allLessonIds,
    );
  }

  double get overallProgress {
    if (totalLessons == 0) return 0;
    return completedLessons / totalLessons;
  }

  int completedLessonsForCategory(LessonCategoryModel category) {
    return _progress.completedLessonsCount(
      category.lessons.where((l) => l.isPublished).map((lesson) => lesson.id),
    );
  }

  double categoryProgress(LessonCategoryModel category) {
    return _progress.completionRate(
      category.lessons.where((l) => l.isPublished).map((lesson) => lesson.id),
    );
  }

  LessonProgressEntry? progressForLesson(String lessonId) {
    return _progress.lessonProgress(lessonId);
  }

  bool isLessonCompleted(String lessonId) {
    return _progress.isLessonCompleted(lessonId);
  }

  /// Primeira lição incompleta no percurso (Continuar aprendendo).
  /// Só considera aulas published (ignora draft, review e archived).
  ({LessonCategoryModel category, LessonModel lesson})? nextLessonTarget() {
    for (final category in _categories) {
      for (final lesson in category.lessons) {
        if (!lesson.isPublished) continue;
        if (!isLessonCompleted(lesson.id)) {
          return (category: category, lesson: lesson);
        }
      }
    }
    return null;
  }

  /// Status do módulo: completed / inProgress / pending.
  String moduleStatus(LessonCategoryModel category) {
    final published =
        category.lessons.where((lesson) => lesson.isPublished).toList();
    if (published.isEmpty) {
      return category.isDraft || category.lessons.any((l) => l.isDraft)
          ? 'draft'
          : 'pending';
    }
    final completed = completedLessonsForCategory(category);
    if (completed >= published.length) {
      return 'completed';
    }
    if (completed > 0) return 'inProgress';
    return 'pending';
  }

  Future<void> completeLesson({
    required String categoryId,
    required String lessonId,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    _isSavingProgress = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _progress = await _progressRepository.completeLesson(
        categoryId: categoryId,
        lessonId: lessonId,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
      );
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isSavingProgress = false;
      notifyListeners();
    }
  }

  /// Insere ou substitui módulo na lista (authoring local / pós-create).
  void upsertCategory(LessonCategoryModel category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index >= 0) {
      _categories = [..._categories]..[index] = category;
    } else {
      _categories = [..._categories, category];
    }
    notifyListeners();
  }

  void removeCategory(String categoryId) {
    _categories =
        _categories.where((category) => category.id != categoryId).toList();
    notifyListeners();
  }

  void upsertLesson({
    required String categoryId,
    required LessonModel lesson,
  }) {
    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index < 0) return;

    final category = _categories[index];
    final lessons = [...category.lessons];
    final lessonIndex = lessons.indexWhere((l) => l.id == lesson.id);
    if (lessonIndex >= 0) {
      lessons[lessonIndex] = lesson;
    } else {
      lessons.add(lesson);
    }

    _categories = [..._categories]
      ..[index] = category.copyWith(lessons: lessons);
    notifyListeners();
  }

  void removeLesson({
    required String categoryId,
    required String lessonId,
  }) {
    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index < 0) return;

    final category = _categories[index];
    _categories = [..._categories]
      ..[index] = category.copyWith(
        lessons: category.lessons
            .where((lesson) => lesson.id != lessonId)
            .toList(),
      );
    notifyListeners();
  }

  List<String> get _allLessonIds {
    return _categories
        .expand((category) => category.lessons)
        .where((lesson) => lesson.isPublished)
        .map((lesson) => lesson.id)
        .toList();
  }
}
