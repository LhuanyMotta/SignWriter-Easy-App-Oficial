import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lesson_category_model.dart';
import '../../models/lesson_model.dart';
import '../../models/lesson_section_model.dart';
import '../../viewmodels/learn_practice_viewmodel.dart';
import 'exercise_screen.dart';

class LessonScreen extends StatefulWidget {
  final LessonModel lesson;
  final LessonCategoryModel category;

  const LessonScreen({
    super.key,
    required this.lesson,
    required this.category,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final ScrollController _scroll = ScrollController();
  double _readProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    if (max <= 0) return;
    setState(() {
      _readProgress = (_scroll.offset / max).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _startExercises() {
    if (widget.lesson.exercises.isEmpty) {
      _completeWithNoExercises();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExerciseScreen(
          lesson: widget.lesson,
          category: widget.category,
        ),
      ),
    );
  }

  Future<void> _completeWithNoExercises() async {
    final vm = context.read<LearnPracticeViewModel>();
    try {
      await vm.completeLesson(
        categoryId: widget.category.id,
        lessonId: widget.lesson.id,
        correctAnswers: 1,
        totalQuestions: 1,
      );
    } catch (_) {}
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('Lição concluída!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final cat = widget.category;
    final hasExercises = lesson.exercises.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          // AppBar com gradiente da categoria
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: cat.color,
            foregroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: LinearProgressIndicator(
                value: _readProgress,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 4,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _LessonAppBarBackground(
                lesson: lesson,
                category: cat,
              ),
            ),
            title: Text(
              lesson.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),

          // Conteúdo
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Resumo
                _SummaryCard(summary: lesson.summary, color: cat.color),
                const SizedBox(height: 24),

                // Seções de conteúdo
                ...lesson.sections.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final section = entry.value;
                  return _SectionCard(
                    section: section,
                    index: idx,
                    color: cat.color,
                  );
                }),

                if (lesson.sections.isNotEmpty) const SizedBox(height: 8),

                // Informações da lição
                _LessonMetaRow(lesson: lesson, color: cat.color),
                const SizedBox(height: 32),

                // Botão principal
                _StartExercisesButton(
                  hasExercises: hasExercises,
                  exerciseCount: lesson.exercises.length,
                  color: cat.color,
                  onTap: _startExercises,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header da lição ──────────────────────────────────────────────────────────

class _LessonAppBarBackground extends StatelessWidget {
  final LessonModel lesson;
  final LessonCategoryModel category;

  const _LessonAppBarBackground({
    required this.lesson,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            category.color,
            category.color.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge de categoria
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(category.icon, color: Colors.white, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      category.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Resumo ───────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String summary;
  final Color color;

  const _SummaryCard({required this.summary, required this.color});

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              summary,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: scheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card de seção de conteúdo ────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final LessonSectionModel section;
  final int index;
  final Color color;

  const _SectionCard({
    required this.section,
    required this.index,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção
          if (section.title.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      section.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Corpo da seção
          if (section.body.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                section.body,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: scheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),

          // Bullets
          if (section.bullets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: section.bullets.map((b) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 6, right: 10),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            b,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: scheme.onSurface.withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          // Destaque
          if (section.highlight != null && section.highlight!.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.12),
                    color.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(color: color, width: 3),
                ),
              ),
              child: Text(
                section.highlight!,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  color: scheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Meta info ────────────────────────────────────────────────────────────────

class _LessonMetaRow extends StatelessWidget {
  final LessonModel lesson;
  final Color color;

  const _LessonMetaRow({required this.lesson, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MetaChip(
          icon: Icons.timer_outlined,
          label: '${lesson.estimatedMinutes} min',
          color: color,
        ),
        const SizedBox(width: 8),
        _MetaChip(
          icon: Icons.quiz_outlined,
          label: '${lesson.exercises.length} exercícios',
          color: color,
        ),
        const SizedBox(width: 8),
        _MetaChip(
          icon: Icons.signal_cellular_alt_rounded,
          label: lesson.difficulty,
          color: color,
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Botão iniciar exercícios ─────────────────────────────────────────────────

class _StartExercisesButton extends StatelessWidget {
  final bool hasExercises;
  final int exerciseCount;
  final Color color;
  final VoidCallback onTap;

  const _StartExercisesButton({
    required this.hasExercises,
    required this.exerciseCount,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasExercises
                  ? Icons.sports_esports_rounded
                  : Icons.check_circle_outline_rounded,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              hasExercises
                  ? 'Iniciar exercícios ($exerciseCount)'
                  : 'Concluir lição',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
