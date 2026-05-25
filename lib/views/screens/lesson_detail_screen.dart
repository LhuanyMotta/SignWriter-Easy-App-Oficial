import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/lesson_model.dart';
import '../../models/lesson_section_model.dart';
import '../../viewmodels/learn_practice_viewmodel.dart';
import 'lesson_exercise_screen.dart';

class LessonDetailScreen extends StatelessWidget {
  final String categoryId;
  final String lessonId;

  const LessonDetailScreen({
    required this.categoryId,
    required this.lessonId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<LearnPracticeViewModel>();
    final category = vm.categoryById(categoryId);
    final lesson = vm.lessonById(categoryId: categoryId, lessonId: lessonId);

    if (category == null || lesson == null) {
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

    final progress = vm.progressForLesson(lesson.id);
    final isCompleted = progress?.completed == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _LessonHeroCard(
              categoryTitle: category.title,
              lesson: lesson,
              isCompleted: isCompleted,
              scoreText: progress == null || progress.totalQuestions == 0
                  ? null
                  : l10n.learningCorrectAnswersSummary(
                      progress.correctAnswers,
                      progress.totalQuestions,
                    ),
            ),
            if (lesson.objectives.isNotEmpty) ...[
              const SizedBox(height: 20),
              _BlockCard(
                title: l10n.learningObjectives,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lesson.objectives
                      .map((item) => _BulletText(text: item))
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            ...lesson.sections.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SectionCard(section: section),
              ),
            ),
            if (lesson.references.isNotEmpty) ...[
              const SizedBox(height: 8),
              _BlockCard(
                title: l10n.learningReferences,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lesson.references
                      .map((item) => _BulletText(text: item))
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: vm.isSavingProgress
                  ? null
                  : () => _openPractice(context, lesson),
              icon: Icon(
                isCompleted ? Icons.refresh_rounded : Icons.play_arrow_rounded,
              ),
              label: Text(
                isCompleted
                    ? l10n.learningRetakePractice
                    : l10n.learningStartPractice,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPractice(BuildContext context, LessonModel lesson) async {
    final vm = context.read<LearnPracticeViewModel>();
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: LessonExerciseScreen(
            categoryId: categoryId,
            lessonId: lesson.id,
          ),
        ),
      ),
    );

    if (completed == true && context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.learningProgressUpdated),
        ),
      );
    }
  }
}

class _LessonHeroCard extends StatelessWidget {
  final String categoryTitle;
  final LessonModel lesson;
  final bool isCompleted;
  final String? scoreText;

  const _LessonHeroCard({
    required this.categoryTitle,
    required this.lesson,
    required this.isCompleted,
    this.scoreText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusColor =
        isCompleted ? Colors.green : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryTitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(lesson.summary),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroChip(
                icon: Icons.flag_outlined,
                label: lesson.difficulty,
              ),
              _HeroChip(
                icon: isCompleted
                    ? Icons.check_circle_outline_rounded
                    : Icons.menu_book_rounded,
                label: isCompleted
                    ? l10n.learningLessonCompletedStatus
                    : l10n.learningLessonInProgressStatus,
                foregroundColor: statusColor,
              ),
            ],
          ),
          if (scoreText != null) ...[
            const SizedBox(height: 12),
            Text(
              scoreText!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? foregroundColor;

  const _HeroChip({
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

class _SectionCard extends StatelessWidget {
  final LessonSectionModel section;

  const _SectionCard({
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return _BlockCard(
      title: section.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.body),
          if (section.bullets.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...section.bullets.map((item) => _BulletText(text: item)),
          ],
          if (section.highlight != null &&
              section.highlight!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                section.highlight!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BlockCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _BlockCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;

  const _BulletText({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 8),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
