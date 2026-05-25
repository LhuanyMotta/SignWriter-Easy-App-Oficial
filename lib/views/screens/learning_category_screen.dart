import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/lesson_category_model.dart';
import '../../models/lesson_model.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/learn_practice_viewmodel.dart';
import 'lesson_detail_screen.dart';

class LearningCategoryScreen extends StatelessWidget {
  final String categoryId;

  const LearningCategoryScreen({
    required this.categoryId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<LearnPracticeViewModel>();
    final category = vm.categoryById(categoryId);

    if (category == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.featureLearnPractice)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.learningContentUnavailable,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final spacing =
        Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0;
    final completed = vm.completedLessonsForCategory(category);
    final progress = vm.categoryProgress(category);

    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16 * spacing),
          children: [
            _CategoryHeaderCard(
              category: category,
              completedLessons: completed,
              progress: progress,
            ),
            SizedBox(height: 20 * spacing),
            Text(
              l10n.learningLessonsTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 12 * spacing),
            if (category.lessons.isEmpty)
              _EmptyCategoryCard(message: l10n.learningCategoryEmpty)
            else
              ...category.lessons.asMap().entries.map(
                    (entry) => Padding(
                      padding: EdgeInsets.only(bottom: 12 * spacing),
                      child: _LessonCard(
                        index: entry.key + 1,
                        lesson: entry.value,
                        isCompleted: vm.isLessonCompleted(entry.value.id),
                        onTap: () => _openLesson(context, entry.value),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _openLesson(BuildContext context, LessonModel lesson) {
    final vm = context.read<LearnPracticeViewModel>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: LessonDetailScreen(
            categoryId: categoryId,
            lessonId: lesson.id,
          ),
        ),
      ),
    );
  }
}

class _CategoryHeaderCard extends StatelessWidget {
  final LessonCategoryModel category;
  final int completedLessons;
  final double progress;

  const _CategoryHeaderCard({
    required this.category,
    required this.completedLessons,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: category.color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(category.description),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$completedLessons/${category.lessons.length} ${l10n.learningLessonsLower}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: category.color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(category.color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percent%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final int index;
  final LessonModel lesson;
  final bool isCompleted;
  final VoidCallback onTap;

  const _LessonCard({
    required this.index,
    required this.lesson,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = isCompleted ? Colors.green : colorScheme.primary;
    final statusLabel = isCompleted
        ? l10n.learningLessonCompletedStatus
        : l10n.learningLessonNotStartedStatus;

    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: statusColor.withValues(alpha: 0.12),
                foregroundColor: statusColor,
                child: Text(index.toString()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(lesson.summary),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.quiz_outlined,
                          label: '${lesson.exercises.length} ${l10n.exercises}',
                        ),
                        _InfoChip(
                          icon: isCompleted
                              ? Icons.check_circle_outline_rounded
                              : Icons.play_circle_outline_rounded,
                          label: statusLabel,
                          foregroundColor: statusColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? foregroundColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCategoryCard extends StatelessWidget {
  final String message;

  const _EmptyCategoryCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
      ),
    );
  }
}
