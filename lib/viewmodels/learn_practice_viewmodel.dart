import 'package:flutter/material.dart';

import '../models/learning_progress_model.dart';
import '../models/lesson_category_model.dart';
import '../models/lesson_model.dart';
import '../services/learning_content_service.dart';
import '../services/learning_progress_service.dart';

class LearnPracticeViewModel extends ChangeNotifier {
  LearnPracticeViewModel({
    LearningContentService? contentService,
    LearningProgressService? progressService,
  })  : _contentService = contentService ?? LearningContentService(),
        _progressService = progressService ?? LearningProgressService();

  final LearningContentService _contentService;
  final LearningProgressService _progressService;

  List<LessonCategoryModel> _categories = [];
  LearningProgressModel _progress = LearningProgressModel.empty();
  bool _isLoading = false;
  bool _isSavingProgress = false;
  String _errorMessage = '';
  String _loadedLanguageCode = '';

  List<LessonCategoryModel> get categories => _categories;
  LearningProgressModel get progress => _progress;
  bool get isLoading => _isLoading;
  bool get isSavingProgress => _isSavingProgress;
  String get errorMessage => _errorMessage;

  Future<void> initialize(Locale locale) async {
    final languageCode = locale.languageCode.toLowerCase();
    if (_loadedLanguageCode == languageCode && _categories.isNotEmpty) {
      return;
    }

    _loadedLanguageCode = languageCode;
    await _loadData(Locale(languageCode));
  }

  Future<void> reload() async {
    final locale =
        Locale(_loadedLanguageCode.isEmpty ? 'pt' : _loadedLanguageCode);
    await _loadData(locale);
  }

  Future<void> _loadData(Locale locale) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final categories = await _contentService.loadCategories(locale);
      final progress = await _progressService.loadProgress();
      _categories = categories;
      _progress = progress;
    } catch (e) {
      _errorMessage = e.toString();
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
      (sum, category) => sum + category.lessons.length,
    );
  }

  int get totalExercises {
    return _categories.fold<int>(
      0,
      (sum, category) =>
          sum +
          category.lessons.fold<int>(
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
      category.lessons.map((lesson) => lesson.id),
    );
  }

  double categoryProgress(LessonCategoryModel category) {
    return _progress.completionRate(
      category.lessons.map((lesson) => lesson.id),
    );
  }

  LessonProgressEntry? progressForLesson(String lessonId) {
    return _progress.lessonProgress(lessonId);
  }

  bool isLessonCompleted(String lessonId) {
    return _progress.isLessonCompleted(lessonId);
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
      _progress = await _progressService.completeLesson(
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

  List<String> get _allLessonIds {
    return _categories
        .expand((category) => category.lessons)
        .map((lesson) => lesson.id)
        .toList();
  }
}
