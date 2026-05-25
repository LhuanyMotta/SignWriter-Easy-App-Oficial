import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/lesson_exercise_model.dart';
import '../../models/lesson_model.dart';
import '../../viewmodels/learn_practice_viewmodel.dart';

class LessonExerciseScreen extends StatefulWidget {
  final String categoryId;
  final String lessonId;

  const LessonExerciseScreen({
    required this.categoryId,
    required this.lessonId,
    super.key,
  });

  @override
  State<LessonExerciseScreen> createState() => _LessonExerciseScreenState();
}

class _LessonExerciseScreenState extends State<LessonExerciseScreen> {
  int _currentIndex = 0;
  final Map<String, String> _selectedOptions = {};
  final Map<String, Map<String, String>> _matchingAnswers = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<LearnPracticeViewModel>();
    final lesson = vm.lessonById(
      categoryId: widget.categoryId,
      lessonId: widget.lessonId,
    );

    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.learningPracticeTitle)),
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

    if (lesson.exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.learningPracticeTitle)),
        body: Center(
          child: FilledButton(
            onPressed: vm.isSavingProgress
                ? null
                : () => _finishLesson(
                      context: context,
                      lesson: lesson,
                      correctAnswers: 0,
                      totalQuestions: 0,
                    ),
            child: Text(l10n.learningMarkLessonComplete),
          ),
        ),
      );
    }

    final exercise = lesson.exercises[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.learningPracticeTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.learningQuestionProgress(
                  _currentIndex + 1,
                  lesson.exercises.length,
                ),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: (_currentIndex + 1) / lesson.exercises.length,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: _ExerciseCard(
                    exercise: exercise,
                    selectedOptionId: _selectedOptions[exercise.id],
                    selectedMatches: _matchingAnswers[exercise.id] ?? const {},
                    onOptionSelected: (optionId) {
                      setState(() {
                        _selectedOptions[exercise.id] = optionId;
                      });
                    },
                    onMatchSelected: (left, right) {
                      setState(() {
                        final matches = Map<String, String>.from(
                          _matchingAnswers[exercise.id] ?? const {},
                        );
                        matches[left] = right;
                        _matchingAnswers[exercise.id] = matches;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _currentIndex == 0 || vm.isSavingProgress
                          ? null
                          : () {
                              setState(() {
                                _currentIndex -= 1;
                              });
                            },
                      child: Text(l10n.learningPrevious),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: vm.isSavingProgress
                          ? null
                          : () => _advance(context, lesson),
                      child: Text(
                        _currentIndex == lesson.exercises.length - 1
                            ? l10n.learningFinishLesson
                            : l10n.learningNext,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _advance(BuildContext context, LessonModel lesson) async {
    final l10n = AppLocalizations.of(context)!;
    final currentExercise = lesson.exercises[_currentIndex];

    if (!_isExerciseAnswered(currentExercise)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentExercise.isMatching
                ? l10n.learningMatchingIncompleteError
                : l10n.learningChooseOptionError,
          ),
        ),
      );
      return;
    }

    if (_currentIndex < lesson.exercises.length - 1) {
      setState(() {
        _currentIndex += 1;
      });
      return;
    }

    final correctAnswers = _countCorrectAnswers(lesson);
    await _finishLesson(
      context: context,
      lesson: lesson,
      correctAnswers: correctAnswers,
      totalQuestions: lesson.exercises.length,
    );
  }

  bool _isExerciseAnswered(LessonExerciseModel exercise) {
    if (exercise.isMatching) {
      final answers = _matchingAnswers[exercise.id];
      if (answers == null) return false;
      return exercise.pairs.every((pair) => answers.containsKey(pair.left));
    }

    return _selectedOptions.containsKey(exercise.id);
  }

  int _countCorrectAnswers(LessonModel lesson) {
    var total = 0;

    for (final exercise in lesson.exercises) {
      if (exercise.isMatching) {
        final answers = _matchingAnswers[exercise.id] ?? const {};
        final allCorrect = exercise.pairs.every(
          (pair) => answers[pair.left] == pair.right,
        );
        if (allCorrect) {
          total += 1;
        }
        continue;
      }

      if (_selectedOptions[exercise.id] == exercise.correctOptionId) {
        total += 1;
      }
    }

    return total;
  }

  Future<void> _finishLesson({
    required BuildContext context,
    required LessonModel lesson,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.read<LearnPracticeViewModel>();

    await vm.completeLesson(
      categoryId: widget.categoryId,
      lessonId: widget.lessonId,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
    );

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final progressValue =
            totalQuestions == 0 ? 1.0 : correctAnswers / totalQuestions;
        return AlertDialog(
          title: Text(l10n.learningResultsTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.learningCorrectAnswersSummary(
                  correctAnswers,
                  totalQuestions,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: progressValue,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.learningReturnToLesson),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;
    Navigator.of(context).pop(true);
  }
}

class _ExerciseCard extends StatelessWidget {
  final LessonExerciseModel exercise;
  final String? selectedOptionId;
  final Map<String, String> selectedMatches;
  final ValueChanged<String> onOptionSelected;
  final void Function(String left, String right) onMatchSelected;

  const _ExerciseCard({
    required this.exercise,
    required this.selectedOptionId,
    required this.selectedMatches,
    required this.onOptionSelected,
    required this.onMatchSelected,
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
              exercise.prompt,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (exercise.isMatching)
              ..._buildMatchingInputs(context)
            else
              ...exercise.options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _OptionTile(
                    label: option.label,
                    selected: selectedOptionId == option.id,
                    onTap: () => onOptionSelected(option.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMatchingInputs(BuildContext context) {
    final answers = exercise.pairs.map((pair) => pair.right).toList();

    return exercise.pairs
        .map(
          (pair) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pair.left,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedMatches[pair.left],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: answers
                      .map(
                        (answer) => DropdownMenuItem<String>(
                          value: answer,
                          child: Text(answer),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onMatchSelected(pair.left, value);
                    }
                  },
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor =
        selected ? colorScheme.primary : colorScheme.outlineVariant;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: borderColor,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}
