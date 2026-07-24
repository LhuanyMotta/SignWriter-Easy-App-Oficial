import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lesson_block_model.dart';
import '../../models/lesson_category_model.dart';
import '../../models/lesson_model.dart';
import '../../services/learning_authoring_service.dart';
import '../../theme/app_radius.dart';
import '../../theme/responsive_content.dart';
import '../../viewmodels/learn_practice_viewmodel.dart';
import '../widgets/learning/lesson_block_highlight.dart';
import '../widgets/learning/lesson_block_media_placeholder.dart';
import '../widgets/learning/lesson_block_text.dart';
import '../widgets/learning/lesson_inline_field.dart';
import 'exercise_screen.dart';

class LessonScreen extends StatefulWidget {
  final LessonModel lesson;
  final LessonCategoryModel category;

  /// Quando true, a tela é a mesma do aluno — com campos editáveis no lugar.
  final bool isEditing;

  /// Nova lição (ainda sem id remoto).
  final bool isCreating;

  const LessonScreen({
    super.key,
    required this.lesson,
    required this.category,
    this.isEditing = false,
    this.isCreating = false,
  });

  /// Modelo vazio com a mesma estrutura visual da lição.
  static LessonModel blankLesson() {
    return LessonModel(
      id: '',
      title: 'Nova lição',
      summary: 'Toque para descrever o objetivo desta lição.',
      estimatedMinutes: 5,
      difficulty: 'Iniciante',
      objectives: const [
        'Objetivo 1 — toque para editar',
        'Objetivo 2 — toque para editar',
      ],
      status: 'draft',
      explicitBlocks: [
        const LessonBlockModel(
          id: 'new-heading-1',
          type: LessonBlockType.heading,
          title: 'Na prática',
        ),
        const LessonBlockModel(
          id: 'new-text-1',
          type: LessonBlockType.text,
          body: 'Escreva aqui a explicação principal da lição…',
        ),
        const LessonBlockModel(
          id: 'new-highlight-1',
          type: LessonBlockType.highlight,
          body: 'Dica importante para o aluno.',
        ),
        const LessonBlockModel(
          id: 'new-heading-2',
          type: LessonBlockType.heading,
          title: 'Direitos na educação',
        ),
        const LessonBlockModel(
          id: 'new-text-2',
          type: LessonBlockType.text,
          body: 'Continue o conteúdo nesta seção…',
        ),
      ],
    );
  }

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final ScrollController _scroll = ScrollController();
  final _authoring = LearningAuthoringService();
  double _readProgress = 0.0;

  late String _title;
  late String _summary;
  late List<String> _objectives;
  late List<LessonBlockModel> _blocks;
  late String _status;
  late LessonBlockModel _observeBlock;
  bool _saving = false;

  bool get _editMode => widget.isEditing || widget.isCreating;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _hydrateFromLesson(widget.lesson);
  }

  void _hydrateFromLesson(LessonModel lesson) {
    _title = lesson.title;
    _summary = lesson.summary;
    _objectives = List<String>.from(lesson.objectives);
    _blocks = List<LessonBlockModel>.from(lesson.blocks);
    _status = lesson.status;
    _observeBlock = LessonBlockModel(
      id: 'observe-${lesson.id.isEmpty ? 'new' : lesson.id}',
      type: LessonBlockType.signwriting,
      mediaAsset: 'assets/images/signwriter_logo.png',
      caption: 'Observe a escrita do sinal',
    );
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
    if (_editMode) return;
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

  String get _bodyFallback {
    return _blocks
        .where((b) => b.type == LessonBlockType.text && b.body.trim().isNotEmpty)
        .map((b) => b.body.trim())
        .join('\n\n');
  }

  Future<void> _save() async {
    final title = _title.trim();
    final summary = _summary.trim();
    if (title.isEmpty || summary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha título e objetivo da lição.')),
      );
      return;
    }

    setState(() => _saving = true);
    final sections = LearningAuthoringService.sectionsFromBlocks(_blocks);
    final body = _bodyFallback.isNotEmpty ? _bodyFallback : summary;
    final objectives = _objectives
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    String? remoteId;
    var remoteOk = false;

    if (widget.isCreating || widget.lesson.id.isEmpty) {
      remoteId = await _authoring.createLesson(
        categoryId: widget.category.id,
        title: title,
        summary: summary,
        body: body,
        status: _status,
        objectives: objectives,
        sections: sections,
      );
      remoteOk = remoteId != null;
    } else {
      remoteOk = await _authoring.updateLesson(
        lessonId: widget.lesson.id,
        title: title,
        summary: summary,
        body: body,
        status: _status,
        objectives: objectives,
        sections: sections,
      );
      remoteId = widget.lesson.id;
    }

    if (!mounted) return;
    setState(() => _saving = false);

    final lessonId = remoteId ??
        (widget.lesson.id.isNotEmpty
            ? widget.lesson.id
            : 'les-local-${DateTime.now().millisecondsSinceEpoch}');

    final savedLesson = LessonModel(
      id: lessonId,
      title: title,
      summary: summary,
      estimatedMinutes: widget.lesson.estimatedMinutes,
      difficulty: widget.lesson.difficulty,
      objectives: objectives,
      sections: sections,
      exercises: widget.lesson.exercises,
      references: widget.lesson.references,
      relatedSignIds: widget.lesson.relatedSignIds,
      explicitBlocks: List<LessonBlockModel>.from(_blocks),
      status: _status,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          remoteOk
              ? 'Lição salva.'
              : 'Lição mantida neste dispositivo. Banco ainda pode estar bloqueado (RLS).',
        ),
        backgroundColor: remoteOk ? Colors.green : Colors.orange,
      ),
    );
    Navigator.of(context).pop(savedLesson);
  }

  void _mediaSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Troca de mídia via SignBank/FSW em breve. Por enquanto edite a legenda.',
        ),
      ),
    );
  }

  void _updateBlock(int index, LessonBlockModel updated) {
    setState(() => _blocks[index] = updated);
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final hasExercises = widget.lesson.exercises.isNotEmpty;
    final scheme = Theme.of(context).colorScheme;
    final displayTitle = _title;

    return Scaffold(
      body: ResponsiveContent(
        maxWidth: 720,
        child: CustomScrollView(
          controller: _scroll,
          slivers: [
            SliverAppBar(
              expandedHeight: 170,
              pinned: true,
              backgroundColor: cat.color,
              foregroundColor: Colors.white,
              actions: _editMode
                  ? [
                      PopupMenuButton<String>(
                        tooltip: 'Status',
                        initialValue: _status,
                        onSelected: (value) =>
                            setState(() => _status = value),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'draft',
                            child: Text('Rascunho'),
                          ),
                          PopupMenuItem(
                            value: 'published',
                            child: Text('Publicado'),
                          ),
                        ],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Chip(
                            label: Text(
                              _status == 'published' ? 'Publicado' : 'Rascunho',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            visualDensity: VisualDensity.compact,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            labelStyle: const TextStyle(color: Colors.white),
                            side: BorderSide.none,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Salvar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ]
                  : null,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: _editMode ? 1 : _readProgress,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 4,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cat.color,
                        cat.color.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 72, 20, 20),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.title,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_editMode)
                        LessonInlineField(
                          value: _title,
                          hint: 'Título da lição',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                          cursorColor: Colors.white,
                          showUnderline: false,
                          onChanged: (v) => setState(() => _title = v),
                        )
                      else
                        Text(
                          displayTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              title: Text(
                displayTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_editMode) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(
                          color: cat.color.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit_note_rounded,
                              color: cat.color, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Editando como o aluno verá. Toque nos textos para alterar.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface.withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  _StepLabel(number: 1, label: 'Objetivo', color: cat.color),
                  _ObjectivesCard(
                    summary: _summary,
                    objectives: _objectives,
                    color: cat.color,
                    isEditing: _editMode,
                    onSummaryChanged: (v) => setState(() => _summary = v),
                    onObjectivesChanged: (v) =>
                        setState(() => _objectives = v),
                  ),
                  const SizedBox(height: 20),

                  _StepLabel(number: 2, label: 'Observe', color: cat.color),
                  LessonBlockMediaPlaceholder(
                    accent: cat.color,
                    label: widget.lesson.relatedSignIds.isNotEmpty
                        ? 'Sinal relacionado (SignBank)'
                        : 'Placeholder visual — FSW/SignBank em breve',
                    block: _observeBlock,
                    isEditing: _editMode,
                    onChanged: (b) => setState(() => _observeBlock = b),
                    onReplaceMedia: _editMode ? _mediaSoon : null,
                  ),

                  _StepLabel(number: 3, label: 'Entenda', color: cat.color),
                  if (_blocks.isEmpty)
                    _editMode
                        ? LessonInlineField(
                            value: _summary,
                            hint: 'Escreva o conteúdo…',
                            style: TextStyle(
                              fontSize: 15.5,
                              height: 1.55,
                              color: scheme.onSurface.withValues(alpha: 0.9),
                            ),
                            minLines: 3,
                            cursorColor: cat.color,
                            onChanged: (v) => setState(() => _summary = v),
                          )
                        : Text(
                            _summary,
                            style: TextStyle(
                              fontSize: 15.5,
                              height: 1.55,
                              color: scheme.onSurface.withValues(alpha: 0.9),
                            ),
                          )
                  else
                    ...List.generate(_blocks.length, (index) {
                      final block = _blocks[index];
                      switch (block.type) {
                        case LessonBlockType.highlight:
                          return LessonBlockHighlight(
                            block: block,
                            accent: cat.color,
                            isEditing: _editMode,
                            onChanged: (b) => _updateBlock(index, b),
                          );
                        case LessonBlockType.image:
                        case LessonBlockType.signwriting:
                          return LessonBlockMediaPlaceholder(
                            block: block,
                            accent: cat.color,
                            isEditing: _editMode,
                            onChanged: (b) => _updateBlock(index, b),
                            onReplaceMedia: _editMode ? _mediaSoon : null,
                          );
                        case LessonBlockType.comparison:
                          return LessonBlockComparisonPlaceholder(
                            accent: cat.color,
                            isEditing: _editMode,
                          );
                        case LessonBlockType.heading:
                        case LessonBlockType.text:
                        case LessonBlockType.bullets:
                          return LessonBlockText(
                            block: block,
                            accent: cat.color,
                            isEditing: _editMode,
                            onChanged: (b) => _updateBlock(index, b),
                          );
                      }
                    }),

                  if (_editMode) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _blocks = [
                              ..._blocks,
                              LessonBlockModel(
                                id: 'block-${DateTime.now().millisecondsSinceEpoch}',
                                type: LessonBlockType.heading,
                                title: 'Nova seção',
                              ),
                              LessonBlockModel(
                                id: 'text-${DateTime.now().millisecondsSinceEpoch}',
                                type: LessonBlockType.text,
                                body: 'Escreva o conteúdo…',
                              ),
                            ];
                          });
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Adicionar seção'),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  _StepLabel(number: 4, label: 'Compare', color: cat.color),
                  LessonBlockComparisonPlaceholder(
                    accent: cat.color,
                    isEditing: _editMode,
                  ),

                  _StepLabel(number: 5, label: 'Pratique', color: cat.color),
                  _PracticeCard(
                    hasExercises: hasExercises,
                    exerciseCount: widget.lesson.exercises.length,
                    color: cat.color,
                    onTap: _startExercises,
                    isEditing: _editMode,
                  ),
                  const SizedBox(height: 20),

                  _StepLabel(number: 6, label: 'Resumo', color: cat.color),
                  _MetaCard(
                    lesson: widget.lesson.copyWith(
                      title: _title,
                      summary: _summary,
                      status: _status,
                    ),
                    color: cat.color,
                  ),
                  if (widget.lesson.references.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...widget.lesson.references.map(
                      (ref) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.link_rounded,
                                size: 16, color: cat.color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ref,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: scheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (_editMode) ...[
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: const Icon(Icons.save_rounded),
                      label: Text(
                        widget.isCreating ? 'Criar lição' : 'Salvar alterações',
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: cat.color,
                      ),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  final int number;
  final String label;
  final Color color;

  const _StepLabel({
    required this.number,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ObjectivesCard extends StatelessWidget {
  final String summary;
  final List<String> objectives;
  final Color color;
  final bool isEditing;
  final ValueChanged<String>? onSummaryChanged;
  final ValueChanged<List<String>>? onObjectivesChanged;

  const _ObjectivesCard({
    required this.summary,
    required this.objectives,
    required this.color,
    this.isEditing = false,
    this.onSummaryChanged,
    this.onObjectivesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final summaryStyle = TextStyle(
      fontSize: 15,
      height: 1.45,
      color: scheme.onSurface.withValues(alpha: 0.9),
    );
    final objectiveStyle = TextStyle(
      fontSize: 14,
      color: scheme.onSurface.withValues(alpha: 0.8),
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditing)
            LessonInlineField(
              value: summary,
              hint: 'Resumo / objetivo da lição',
              style: summaryStyle,
              minLines: 2,
              cursorColor: color,
              onChanged: (v) => onSummaryChanged?.call(v),
            )
          else
            Text(summary, style: summaryStyle),
          if (isEditing || objectives.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (isEditing)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.flag_rounded, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LessonInlineField(
                      value: objectives.join('\n'),
                      hint: 'Um objetivo por linha',
                      style: objectiveStyle,
                      minLines: 2,
                      cursorColor: color,
                      onChanged: (v) => onObjectivesChanged?.call(
                        v
                            .split('\n')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList(),
                      ),
                    ),
                  ),
                ],
              )
            else
              ...objectives.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.flag_rounded, size: 16, color: color),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item, style: objectiveStyle)),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  final bool hasExercises;
  final int exerciseCount;
  final Color color;
  final VoidCallback onTap;
  final bool isEditing;

  const _PracticeCard({
    required this.hasExercises,
    required this.exerciseCount,
    required this.color,
    required this.onTap,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: isEditing ? 0.65 : 1),
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: InkWell(
        onTap: isEditing ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.fitness_center_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing
                          ? 'Pratique'
                          : (hasExercises ? 'Praticar agora' : 'Concluir lição'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      isEditing
                          ? 'Exercícios serão editáveis em breve'
                          : (hasExercises
                              ? '$exerciseCount atividades disponíveis'
                              : 'Marcar esta lição como concluída'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isEditing)
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  final LessonModel lesson;
  final Color color;

  const _MetaCard({required this.lesson, required this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _chip(Icons.timer_outlined, '${lesson.estimatedMinutes} min', scheme),
          _chip(Icons.signal_cellular_alt_rounded, lesson.difficulty, scheme),
          _chip(
            Icons.quiz_outlined,
            '${lesson.exercises.length} exercícios',
            scheme,
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, ColorScheme scheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
