import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lesson_category_model.dart';
import '../../models/lesson_model.dart';
import '../../services/authorization_service.dart';
import '../../services/learning_authoring_service.dart';
import '../../viewmodels/learn_practice_viewmodel.dart';
import '../../theme/responsive_content.dart';
import '../../theme/app_radius.dart';
import 'lesson_screen.dart';

class LearnPracticeScreen extends StatefulWidget {
  const LearnPracticeScreen({super.key});

  @override
  State<LearnPracticeScreen> createState() => _LearnPracticeScreenState();
}

class _LearnPracticeScreenState extends State<LearnPracticeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  final AuthorizationService _authorization = AuthorizationService();
  String _languageCode = '';
  bool _canManageLessons = false;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    await _authorization.clearLocalAuthorUiOverride();
    final canManage = await _authorization.hasEditorialRole();
    if (!mounted) return;
    setState(() => _canManageLessons = canManage);

    final locale = Localizations.localeOf(context);
    _languageCode = locale.languageCode;
    await context.read<LearnPracticeViewModel>().initialize(
          locale,
          includeDrafts: canManage,
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_languageCode == locale.languageCode) return;
    if (_languageCode.isEmpty) {
      // Primeiro load fica a cargo de _bootstrap (com includeDrafts certo).
      _languageCode = locale.languageCode;
      return;
    }

    _languageCode = locale.languageCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LearnPracticeViewModel>().initialize(
            locale,
            includeDrafts: _canManageLessons,
          );
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Aprender e Praticar'),
      ),
      body: ResponsiveContent(child: Consumer<LearnPracticeViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const _LoadingState();
          }
          if (vm.errorMessage.isNotEmpty && vm.categories.isEmpty) {
            return _ErrorState(
              message: vm.errorMessage,
              onRetry: vm.reload,
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HeaderBackground(
                  progress: vm.overallProgress,
                  completed: vm.completedLessons,
                  total: vm.totalLessons,
                ),
              ),
              if (vm.isOfflineCache)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Material(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        leading: const Icon(Icons.cloud_off_rounded,
                            color: Colors.orange),
                        title: const Text('Conteúdo offline'),
                        subtitle: Text(
                          vm.cacheSyncedAt == null
                              ? 'Exibindo a última versão salva neste dispositivo.'
                              : 'Última sincronização: ${vm.cacheSyncedAt!.toLocal()}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: vm.reload,
                        ),
                      ),
                    ),
                  ),
                ),
              if (vm.categories.isEmpty && !_canManageLessons)
                const SliverFillRemaining(child: _EmptyState())
              else ...[
                if (vm.categories.isNotEmpty) _ContinueLearningSection(vm: vm),
                _LearningPathSection(
                  vm: vm,
                  canManageLessons: _canManageLessons,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ],
          );
        },
      )),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  final double progress;
  final int completed;
  final int total;

  const _HeaderBackground({
    required this.progress,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            scheme.primary.withValues(alpha: 0.80),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seu progresso',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        total == 0
                            ? 'Nenhuma lição disponível'
                            : '$completed de $total lições concluídas',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _CircularProgress(progress: progress),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF4EB1F0)),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularProgress extends StatelessWidget {
  final double progress;
  const _CircularProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 5,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4EB1F0)),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Seção "Continuar de onde parou" ─────────────────────────────────────────

class _ContinueLearningSection extends StatelessWidget {
  final LearnPracticeViewModel vm;
  const _ContinueLearningSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    final target = vm.nextLessonTarget();
    if (target == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(label: 'CONTINUAR APRENDENDO'),
            const SizedBox(height: 10),
            _ContinueCard(
              lesson: target.lesson,
              category: target.category,
              vm: vm,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final LessonModel lesson;
  final LessonCategoryModel category;
  final LearnPracticeViewModel vm;

  const _ContinueCard({
    required this.lesson,
    required this.category,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final progress = vm.progressForLesson(lesson.id);
    final score = progress?.scoreRatio ?? 0.0;

    return GestureDetector(
      onTap: () => _openLesson(context, lesson, category),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              category.color,
              category.color.withValues(alpha: 0.75),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: [
            BoxShadow(
              color: category.color.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Icon(category.icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: Colors.white70,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.estimatedMinutes} min',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.quiz_outlined,
                          color: Colors.white70,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.exercises.length} exerc.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          color: category.color,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          progress != null ? 'Revisar' : 'Iniciar',
                          style: TextStyle(
                            color: category.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (progress != null && score > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${(score * 100).round()}% acertos',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Percurso vertical (categorias = módulos/trilhas) ─────────────────────────

class _LearningPathSection extends StatelessWidget {
  final LearnPracticeViewModel vm;
  final bool canManageLessons;

  const _LearningPathSection({
    required this.vm,
    required this.canManageLessons,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel(label: 'PERCURSO DE APRENDIZADO'),
            const SizedBox(height: 6),
            Text(
              canManageLessons
                  ? 'Modo gestão: crie módulos, edite ou exclua lições. O aluno verá o mesmo layout.'
                  : 'Categorias atuais como módulos. Conclua na ordem ou explore livremente.',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 16),
            if (vm.categories.isEmpty && canManageLessons)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Nenhum módulo ainda. Crie o primeiro abaixo.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                  ),
                ),
              ),
            ...vm.categories.asMap().entries.map((entry) {
              final index = entry.key;
              final cat = entry.value;
              final isLast =
                  index == vm.categories.length - 1 && !canManageLessons;
              return _PathModuleCard(
                index: index + 1,
                category: cat,
                vm: vm,
                isLast: isLast,
                canManageLessons: canManageLessons,
                initiallyExpanded: vm.moduleStatus(cat) == 'inProgress' ||
                    (index == 0 && vm.moduleStatus(cat) == 'pending') ||
                    canManageLessons,
              );
            }),
            if (canManageLessons)
              _AddModuleCard(
                index: vm.categories.length + 1,
                onTap: () => _addModule(context, vm),
              ),
          ],
        ),
      ),
    );
  }
}

class _PathModuleCard extends StatefulWidget {
  final int index;
  final LessonCategoryModel category;
  final LearnPracticeViewModel vm;
  final bool isLast;
  final bool initiallyExpanded;
  final bool canManageLessons;

  const _PathModuleCard({
    required this.index,
    required this.category,
    required this.vm,
    required this.isLast,
    this.initiallyExpanded = false,
    this.canManageLessons = false,
  });

  @override
  State<_PathModuleCard> createState() => _PathModuleCardState();
}

class _PathModuleCardState extends State<_PathModuleCard>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _controller;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: _expanded ? 1 : 0,
    );
    _expandAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      _expanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final vm = widget.vm;
    final progress = vm.categoryProgress(cat);
    final completed = vm.completedLessonsForCategory(cat);
    final total = cat.lessons.length;
    final status = vm.moduleStatus(cat);
    final scheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                _PathNode(
                    index: widget.index, status: status, color: cat.color),
                if (!widget.isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'completed'
                            ? Colors.green.withValues(alpha: 0.45)
                            : cat.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: widget.isLast ? 0 : 14),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: status == 'inProgress'
                      ? cat.color.withValues(alpha: 0.45)
                      : scheme.outlineVariant,
                  width: status == 'inProgress' ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: _toggle,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: cat.color.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.small),
                            ),
                            child: Icon(cat.icon, color: cat.color, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        cat.title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    _ModuleStatusChip(
                                      status: status,
                                      color: cat.color,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  cat.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor:
                                              cat.color.withValues(alpha: 0.12),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  cat.color),
                                          minHeight: 5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '$completed/$total',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: cat.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (widget.canManageLessons)
                            IconButton(
                              tooltip: 'Excluir módulo',
                              onPressed: () => _deleteModule(context, vm, cat),
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: scheme.error.withValues(alpha: 0.85),
                                size: 20,
                              ),
                            ),
                          const SizedBox(width: 4),
                          AnimatedRotation(
                            turns: _expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: scheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizeTransition(
                    sizeFactor: _expandAnim,
                    child: Column(
                      children: [
                        Divider(height: 1, color: scheme.outlineVariant),
                        ...cat.lessons.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final lesson = entry.value;
                          final isCompleted = vm.isLessonCompleted(lesson.id);
                          final lessonProgress =
                              vm.progressForLesson(lesson.id);
                          final isLastLesson = idx == cat.lessons.length - 1 &&
                              !widget.canManageLessons;

                          return _LessonTile(
                            lesson: lesson,
                            category: cat,
                            isCompleted: isCompleted,
                            scoreRatio: lessonProgress?.scoreRatio,
                            isLast: isLastLesson,
                            canEdit: widget.canManageLessons,
                            onTap: () => _openLesson(context, lesson, cat),
                            onEdit: widget.canManageLessons
                                ? () => _editLesson(context, vm, cat, lesson)
                                : null,
                            onDelete: widget.canManageLessons
                                ? () => _deleteLesson(
                                      context,
                                      vm,
                                      cat,
                                      lesson,
                                    )
                                : null,
                          );
                        }),
                        if (widget.canManageLessons)
                          _AddLessonTile(
                            color: cat.color,
                            nextNumber: cat.lessons.length + 1,
                            onTap: () => _addLesson(context, vm, cat),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PathNode extends StatelessWidget {
  final int index;
  final String status;
  final Color color;

  const _PathNode({
    required this.index,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = status == 'completed';
    final isActive = status == 'inProgress';
    final isDraft = status == 'draft';
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isDone
            ? Colors.green
            : isActive
                ? color
                : isDraft
                    ? Colors.orange.withValues(alpha: 0.15)
                    : color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: isDraft ? Border.all(color: Colors.orange, width: 1.5) : null,
      ),
      alignment: Alignment.center,
      child: isDone
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
          : Text(
              '$index',
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : isDraft
                        ? Colors.orange.shade800
                        : color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
    );
  }
}

class _ModuleStatusChip extends StatelessWidget {
  final String status;
  final Color color;

  const _ModuleStatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'completed' => 'Concluído',
      'inProgress' => 'Em andamento',
      'draft' => 'Rascunho',
      _ => 'Pendente',
    };
    final chipColor = switch (status) {
      'completed' => Colors.green,
      'inProgress' => color,
      'draft' => Colors.orange,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: chipColor,
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final LessonModel lesson;
  final LessonCategoryModel category;
  final bool isCompleted;
  final double? scoreRatio;
  final bool isLast;
  final bool canEdit;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _LessonTile({
    required this.lesson,
    required this.category,
    required this.isCompleted,
    required this.scoreRatio,
    required this.isLast,
    required this.onTap,
    this.canEdit = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final score = scoreRatio ?? 0.0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 14, 16, isLast ? 16 : 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withValues(alpha: 0.1)
                    : category.color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.play_circle_outline_rounded,
                color: isCompleted ? Colors.green : category.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _LessonChip(
                        icon: Icons.timer_outlined,
                        label: '${lesson.estimatedMinutes} min',
                      ),
                      const SizedBox(width: 6),
                      _LessonChip(
                        icon: Icons.quiz_outlined,
                        label: '${lesson.exercises.length} exerc.',
                      ),
                      const SizedBox(width: 6),
                      _DifficultyBadge(difficulty: lesson.difficulty),
                      if (lesson.isDraft) ...[
                        const SizedBox(width: 6),
                        const _LessonChip(
                          icon: Icons.edit_note_rounded,
                          label: 'Rascunho',
                        ),
                      ],
                    ],
                  ),
                  if (isCompleted && score > 0) ...[
                    const SizedBox(height: 5),
                    _ScoreBar(score: score),
                  ],
                ],
              ),
            ),
            if (canEdit)
              PopupMenuButton<String>(
                tooltip: 'Opções da lição',
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Editar'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Excluir'),
                  ),
                ],
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: category.color,
                  size: 20,
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurface.withValues(alpha: 0.3),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _AddLessonTile extends StatelessWidget {
  final Color color;
  final int nextNumber;
  final VoidCallback onTap;

  const _AddLessonTile({
    required this.color,
    required this.nextNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Icon(Icons.add_rounded, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adicionar lição',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    Text(
                      'Será a lição $nextNumber deste módulo',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddModuleCard extends StatelessWidget {
  final int index;
  final VoidCallback onTap;

  const _AddModuleCard({
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = scheme.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.45)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.add_rounded, color: color, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: color.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        child: Icon(Icons.create_new_folder_outlined,
                            color: color, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Adicionar módulo',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Será o módulo $index do percurso — depois você cria as lições',
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _LessonChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: scheme.onSurface.withValues(alpha: 0.45)),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;
  const _DifficultyBadge({required this.difficulty});

  Color _color() {
    switch (difficulty.toLowerCase()) {
      case 'iniciante':
        return Colors.green;
      case 'intermediário':
      case 'intermediario':
        return Colors.orange;
      case 'avançado':
      case 'avancado':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 10,
          color: _color(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final double score;
  const _ScoreBar({required this.score});

  @override
  Widget build(BuildContext context) {
    Color barColor;
    if (score >= 0.8) {
      barColor = Colors.green;
    } else if (score >= 0.5) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.red;
    }

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: barColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${(score * 100).round()}%',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: barColor,
          ),
        ),
      ],
    );
  }
}

// ─── Utilities ────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface.withValues(alpha: 0.4),
        letterSpacing: 1.2,
      ),
    );
  }
}

void _openLesson(
  BuildContext context,
  LessonModel lesson,
  LessonCategoryModel category,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => LessonScreen(
        lesson: lesson,
        category: category,
      ),
    ),
  );
}

Future<void> _addLesson(
  BuildContext context,
  LearnPracticeViewModel vm,
  LessonCategoryModel category,
) async {
  final saved = await Navigator.of(context).push<LessonModel>(
    MaterialPageRoute(
      builder: (_) => LessonScreen(
        lesson: LessonScreen.blankLesson(),
        category: category,
        isEditing: true,
        isCreating: true,
      ),
    ),
  );
  if (saved == null) return;
  vm.upsertLesson(categoryId: category.id, lesson: saved);
  if (!saved.id.startsWith('les-local-')) {
    await vm.reload();
  }
}

Future<void> _editLesson(
  BuildContext context,
  LearnPracticeViewModel vm,
  LessonCategoryModel category,
  LessonModel lesson,
) async {
  final saved = await Navigator.of(context).push<LessonModel>(
    MaterialPageRoute(
      builder: (_) => LessonScreen(
        lesson: lesson,
        category: category,
        isEditing: true,
      ),
    ),
  );
  if (saved == null) return;
  vm.upsertLesson(categoryId: category.id, lesson: saved);
  if (!saved.id.startsWith('les-local-')) {
    await vm.reload();
  }
}

Future<void> _addModule(
  BuildContext context,
  LearnPracticeViewModel vm,
) async {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;
      return AlertDialog(
        title: const Text('Novo módulo'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Título do módulo',
                  hintText: 'Ex.: Comece aqui',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'O que o aluno encontra neste módulo',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              Text(
                'Em seguida você cria a primeira lição no mesmo visual do aluno.',
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Criar'),
          ),
        ],
      );
    },
  );

  if (confirmed != true || !context.mounted) {
    titleCtrl.dispose();
    descCtrl.dispose();
    return;
  }

  final title = titleCtrl.text.trim();
  final description = descCtrl.text.trim().isEmpty
      ? 'Novo módulo do percurso'
      : descCtrl.text.trim();
  titleCtrl.dispose();
  descCtrl.dispose();

  final authoring = LearningAuthoringService();
  final remoteId = await authoring.createCategory(
    title: title,
    description: description,
    orderIndex: vm.categories.length + 1,
  );

  final category = LessonCategoryModel(
    id: remoteId ?? 'cat-local-${DateTime.now().millisecondsSinceEpoch}',
    title: title,
    description: description,
    iconKey: 'school',
    colorHex: '#2D78BB',
    lessons: const [],
    status: 'draft',
  );
  vm.upsertCategory(category);

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        remoteId != null
            ? 'Módulo criado. Agora monte a primeira lição.'
            : 'Módulo criado neste dispositivo. Banco pode ainda estar bloqueado.',
      ),
      backgroundColor: remoteId != null ? Colors.green : Colors.orange,
    ),
  );

  // Fluxo contínuo: módulo → primeira lição.
  await _addLesson(context, vm, category);
}

Future<void> _deleteModule(
  BuildContext context,
  LearnPracticeViewModel vm,
  LessonCategoryModel category,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Excluir módulo?'),
      content: Text(
        'Isso remove "${category.title}" e as ${category.lessons.length} '
        'lição(ões) dentro dele.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final authoring = LearningAuthoringService();
  final isLocal = category.id.startsWith('cat-local-');
  final remoteOk = isLocal ? true : await authoring.deleteCategory(category.id);

  vm.removeCategory(category.id);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        remoteOk
            ? 'Módulo excluído.'
            : 'Módulo removido da lista. Verifique RLS no Supabase.',
      ),
      backgroundColor: remoteOk ? Colors.green : Colors.orange,
    ),
  );
}

Future<void> _deleteLesson(
  BuildContext context,
  LearnPracticeViewModel vm,
  LessonCategoryModel category,
  LessonModel lesson,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Excluir lição?'),
      content: Text('Remover "${lesson.title}" deste módulo?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final authoring = LearningAuthoringService();
  final isLocal = lesson.id.startsWith('les-local-');
  final remoteOk = isLocal ? true : await authoring.deleteLesson(lesson.id);

  vm.removeLesson(categoryId: category.id, lessonId: lesson.id);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        remoteOk
            ? 'Lição excluída.'
            : 'Lição removida da lista. Verifique RLS no Supabase.',
      ),
      backgroundColor: remoteOk ? Colors.green : Colors.orange,
    ),
  );
}

// ─── Estados auxiliares ───────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando lições...'),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 64, color: scheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Não foi possível carregar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                  fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined,
                size: 72, color: scheme.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              'Nenhuma lição disponível',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 8),
            Text(
              'As lições serão adicionadas em breve.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.4), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
