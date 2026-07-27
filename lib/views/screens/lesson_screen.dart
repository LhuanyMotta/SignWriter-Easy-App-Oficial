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
import '../widgets/learning/lesson_block_text.dart';
import '../widgets/learning/lesson_inline_field.dart';
import '../widgets/learning/lesson_media_view.dart';
import '../widgets/learning/lesson_sources_section.dart';
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
      blocks: [
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
  bool _dirty = false;

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
    _status = lesson.status.isEmpty ? 'draft' : lesson.status;
    _observeBlock = LessonBlockModel(
      id: 'observe-${lesson.id.isEmpty ? 'new' : lesson.id}',
      type: LessonBlockType.signwriting,
      mediaAsset: 'assets/images/signwriter_logo.png',
      caption: 'Observe a escrita do sinal',
    );
    _dirty = false;
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

  Future<void> _save({required String status}) async {
    final title = _title.trim();
    final summary = _summary.trim();
    if (title.isEmpty || summary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha título e objetivo da lição.')),
      );
      return;
    }

    setState(() {
      _saving = true;
      _status = status;
    });
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
        status: status,
        objectives: objectives,
        blocks: _blocks,
      );
      remoteOk = remoteId != null;
    } else {
      remoteOk = await _authoring.updateLesson(
        lessonId: widget.lesson.id,
        categoryId: widget.category.id,
        title: title,
        summary: summary,
        body: body,
        status: status,
        objectives: objectives,
        blocks: _blocks,
      );
      remoteId = widget.lesson.id;
    }

    if (!mounted) return;
    setState(() {
      _saving = false;
      if (remoteOk) _dirty = false;
    });

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
      blocks: List<LessonBlockModel>.from(_blocks),
      exercises: widget.lesson.exercises,
      references: widget.lesson.references,
      relatedSignIds: widget.lesson.relatedSignIds,
      sources: widget.lesson.sources,
      media: widget.lesson.media,
      status: status,
      version: widget.lesson.version,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          remoteOk
              ? (status == 'published'
                  ? 'Lição publicada.'
                  : 'Rascunho salvo no banco.')
              : 'Não foi possível salvar no banco (RLS/rede).',
        ),
        backgroundColor: remoteOk ? Colors.green : Colors.orange,
      ),
    );
    if (remoteOk) {
      Navigator.of(context).pop(savedLesson);
    }
  }

  Future<bool> _confirmDiscardIfNeeded() async {
    if (!_editMode || !_dirty || _saving) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text(
          'Há alterações não salvas. Se sair agora, o rascunho não será atualizado no banco.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Continuar editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    return leave == true;
  }

  void _updateBlock(int index, LessonBlockModel updated) {
    setState(() {
      _blocks[index] = updated;
      _dirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final hasExercises = widget.lesson.exercises.isNotEmpty;
    final scheme = Theme.of(context).colorScheme;
    final displayTitle = _title;

    return PopScope(
      canPop: !_editMode || !_dirty || _saving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final leave = await _confirmDiscardIfNeeded();
        if (leave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
                      Padding(
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
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () => _save(status: 'draft'),
                        child: _saving && _status == 'draft'
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Salvar rascunho',
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
                          onChanged: (v) => setState(() {
                            _title = v;
                            _dirty = true;
                          }),
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
                    onSummaryChanged: (v) => setState(() {
                      _summary = v;
                      _dirty = true;
                    }),
                    onObjectivesChanged: (v) =>
                        setState(() {
                          _objectives = v;
                          _dirty = true;
                        }),
                  ),
                  const SizedBox(height: 20),

                  _StepLabel(number: 2, label: 'Observe', color: cat.color),
                  LessonMediaView.fromBlock(
                    block: _observeBlock,
                    accent: cat.color,
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
                            onChanged: (v) => setState(() {
                              _summary = v;
                              _dirty = true;
                            }),
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
                          return LessonMediaView.fromBlock(
                            block: block,
                            accent: cat.color,
                          );
                        case LessonBlockType.comparison:
                          return LessonComparisonView(
                            block: block,
                            accent: cat.color,
                          );
                        case LessonBlockType.heading:
                        case LessonBlockType.text:
                        case LessonBlockType.bullets:
                        case LessonBlockType.unknown:
                          return LessonBlockText(
                            block: block.type == LessonBlockType.unknown
                                ? block.copyWith(type: LessonBlockType.text)
                                : block,
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
                            _dirty = true;
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
                  LessonComparisonView(
                    block: LessonBlockModel(
                      id: 'compare-${widget.lesson.id}',
                      type: LessonBlockType.comparison,
                      payload: const {
                        'leftTitle': 'Correto',
                        'rightTitle': 'Incorreto',
                        'leftBody': 'Exemplo de escrita adequada',
                        'rightBody': 'Exemplo a evitar',
                      },
                    ),
                    accent: cat.color,
                  ),

                  _StepLabel(number: 5, label: 'Pratique', color: cat.color),
                  _PracticeCard(
                    hasExercises: hasExercises,
                    exerciseCount: widget.lesson.exercises.length,
                    color: cat.color,
                    onTap: _startExercises,
                    isEditing: _editMode,
                  ),

                  const SizedBox(height: 16),
                  LessonSourcesSection(
                    sources: widget.lesson.sources,
                    legacyReferences: widget.lesson.references,
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
                    OutlinedButton.icon(
                      onPressed:
                          _saving ? null : () => _save(status: 'draft'),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Salvar rascunho'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: cat.color,
                        side: BorderSide(color: cat.color),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed:
                          _saving ? null : () => _save(status: 'published'),
                      icon: const Icon(Icons.publish_rounded),
                      label: const Text('Publicar lição'),
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
