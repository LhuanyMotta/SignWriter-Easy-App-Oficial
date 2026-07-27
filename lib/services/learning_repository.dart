import 'package:flutter/material.dart';

import '../models/lesson_category_model.dart';
import 'learning_content_service.dart';

/// Fonte de conteúdo didático do CMS pedagógico (Supabase + cache).
abstract class LearningRepository {
  Future<List<LessonCategoryModel>> loadCategories(Locale locale);

  LearningCourseSnapshot? get lastSnapshot;
}

class DefaultLearningRepository implements LearningRepository {
  DefaultLearningRepository({
    LearningContentService? contentService,
  }) : _contentService = contentService ?? LearningContentService();

  final LearningContentService _contentService;

  @override
  LearningCourseSnapshot? get lastSnapshot => _contentService.lastSnapshot;

  @override
  Future<List<LessonCategoryModel>> loadCategories(Locale locale) {
    return _contentService.loadCategories(locale);
  }

  Future<LearningCourseSnapshot> loadCourse(
    Locale locale, {
    bool includeDrafts = false,
  }) {
    return _contentService.loadCourse(locale, includeDrafts: includeDrafts);
  }
}
