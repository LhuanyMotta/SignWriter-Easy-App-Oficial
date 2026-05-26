import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/lesson_category_model.dart';
import '../../viewmodels/learn_practice_viewmodel.dart';
import '../../theme/app_theme.dart';
import 'learning_category_screen.dart';

class LearnPracticeScreen extends StatefulWidget {
  const LearnPracticeScreen({super.key});

  @override
  State<LearnPracticeScreen> createState() => _LearnPracticeScreenState();
}

class _LearnPracticeScreenState extends State<LearnPracticeScreen> {
  late LearnPracticeViewModel _viewModel;
  String _languageCode = '';

  @override
  void initState() {
    super.initState();
    _viewModel = LearnPracticeViewModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_languageCode != locale.languageCode) {
      _languageCode = locale.languageCode;
      _viewModel.initialize(locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing =
        Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0;
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<LearnPracticeViewModel>(
        builder: (context, vm, _) => Scaffold(
          appBar: AppBar(
            title: Text(l10n.featureLearnPractice),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: vm.isLoading ? null : vm.reload,
              ),
            ],
          ),
          body: SafeArea(
            child: _buildBody(
              context: context,
              spacing: spacing,
              l10n: l10n,
              vm: vm,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required double spacing,
    required AppLocalizations l10n,
    required LearnPracticeViewModel vm,
  }) {
    if (vm.isLoading && vm.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage.isNotEmpty && vm.categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48),
              const SizedBox(height: 16),
              Text(
                l10n.learningContentUnavailable,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: vm.reload,
                child: Text(l10n.learningTryAgain),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16 * spacing),
        children: [
          _SummaryCard(
            completedLessons: vm.completedLessons,
            totalLessons: vm.totalLessons,
            totalExercises: vm.totalExercises,
            progress: vm.overallProgress,
          ),
          SizedBox(height: 24 * spacing),
          Text(
            l10n.learningCategoriesTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 8 * spacing),
          Text(
            l10n.learningSummarySubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 16 * spacing),
          if (vm.categories.isEmpty)
            _EmptyStateCard(message: l10n.learningCategoryEmpty)
          else
            ...vm.categories.map(
              (category) => Padding(
                padding: EdgeInsets.only(bottom: 12 * spacing),
                child: _CategoryCard(
                  category: category,
                  completedLessons: vm.completedLessonsForCategory(category),
                  progress: vm.categoryProgress(category),
                  onTap: () => _openCategory(context, category),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openCategory(BuildContext context, LessonCategoryModel category) {
    final vm = context.read<LearnPracticeViewModel>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: LearningCategoryScreen(categoryId: category.id),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int completedLessons;
  final int totalLessons;
  final int totalExercises;
  final double progress;

  const _SummaryCard({
    required this.completedLessons,
    required this.totalLessons,
    required this.totalExercises,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2D78BB),
            Color(0xFF4EB1F0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.overallProgress,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.learningSummarySubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percent%',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricBadge(
                label: l10n.completedLessons,
                value: '$completedLessons/$totalLessons',
              ),
              _MetricBadge(
                label: l10n.learningLessonsTitle,
                value: totalLessons.toString(),
              ),
              _MetricBadge(
                label: l10n.exercises,
                value: totalExercises.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final LessonCategoryModel category;
  final int completedLessons;
  final double progress;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.completedLessons,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final percent = (progress * 100).round();

    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(category.icon, color: category.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
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
                  backgroundColor: category.color.withValues(alpha: 0.10),
                  valueColor: AlwaysStoppedAnimation<Color>(category.color),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '$percent%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.chevron_right_rounded),
                    label: Text(l10n.learningOpenCategory),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final String label;
  final String value;

  const _MetricBadge({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.90),
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String message;

  const _EmptyStateCard({
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
