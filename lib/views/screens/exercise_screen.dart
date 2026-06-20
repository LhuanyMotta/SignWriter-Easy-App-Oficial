import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lesson_category_model.dart';
import '../../models/lesson_exercise_model.dart';
import '../../models/lesson_model.dart';
import '../../viewmodels/learn_practice_viewmodel.dart';

class ExerciseScreen extends StatefulWidget {
  final LessonModel lesson;
  final LessonCategoryModel category;

  const ExerciseScreen({
    super.key,
    required this.lesson,
    required this.category,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _correctCount = 0;
  bool _answered = false;
  String? _selectedOptionId;
  String? _leftSelected;
  String? _rightSelected;
  final Map<String, String> _matchingAnswers = {};

  late AnimationController _feedbackController;
  late Animation<double> _feedbackScale;
  late AnimationController _progressController;

  List<LessonExerciseModel> get _exercises => widget.lesson.exercises;
  LessonExerciseModel get _current => _exercises[_currentIndex];
  bool get _isLast => _currentIndex == _exercises.length - 1;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _feedbackScale = CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticOut,
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 0,
    );
    _updateProgress();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    final target = _exercises.isEmpty
        ? 0.0
        : (_currentIndex / _exercises.length).clamp(0.0, 1.0);
    _progressController.animateTo(target, curve: Curves.easeOut);
  }

  bool _isCorrectOption(String optionId) {
    return _current.correctOptionId == optionId;
  }

  bool _checkMatchingComplete() {
    if (_current.pairs.isEmpty) return false;
    return _matchingAnswers.length == _current.pairs.length;
  }

  void _selectOption(String optionId) {
    if (_answered) return;
    setState(() {
      _selectedOptionId = optionId;
      _answered = true;
      if (_isCorrectOption(optionId)) _correctCount++;
    });
    _feedbackController.forward(from: 0);
  }

  void _selectMatchingLeft(String left) {
    if (_answered) return;
    setState(() {
      _leftSelected = left;
      if (_rightSelected != null) {
        _matchingAnswers[left] = _rightSelected!;
        _leftSelected = null;
        _rightSelected = null;
        if (_checkMatchingComplete()) {
          _answered = true;
          int correct = 0;
          for (final pair in _current.pairs) {
            if (_matchingAnswers[pair.left] == pair.right) correct++;
          }
          if (correct == _current.pairs.length) _correctCount++;
          _feedbackController.forward(from: 0);
        }
      }
    });
  }

  void _selectMatchingRight(String right) {
    if (_answered) return;
    setState(() {
      _rightSelected = right;
      if (_leftSelected != null) {
        _matchingAnswers[_leftSelected!] = right;
        _leftSelected = null;
        _rightSelected = null;
        if (_checkMatchingComplete()) {
          _answered = true;
          int correct = 0;
          for (final pair in _current.pairs) {
            if (_matchingAnswers[pair.left] == pair.right) correct++;
          }
          if (correct == _current.pairs.length) _correctCount++;
          _feedbackController.forward(from: 0);
        }
      }
    });
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    setState(() {
      _currentIndex++;
      _answered = false;
      _selectedOptionId = null;
      _leftSelected = null;
      _rightSelected = null;
      _matchingAnswers.clear();
    });
    _feedbackController.reset();
    _updateProgress();
  }

  Future<void> _finish() async {
    final vm = context.read<LearnPracticeViewModel>();
    try {
      await vm.completeLesson(
        categoryId: widget.category.id,
        lessonId: widget.lesson.id,
        correctAnswers: _correctCount,
        totalQuestions: _exercises.length,
      );
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => _ResultScreen(
          lesson: widget.lesson,
          category: widget.category,
          correctCount: _correctCount,
          totalCount: _exercises.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cat = widget.category;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Column(
        children: [
          _ExerciseHeader(
            category: cat,
            currentIndex: _currentIndex,
            total: _exercises.length,
            progressController: _progressController,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ExerciseTypeBadge(type: _current.type, color: cat.color),
                  const SizedBox(height: 16),
                  Text(
                    _current.prompt,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_current.isMultipleChoice || _current.isTrueFalse)
                    _MultipleChoiceOptions(
                      exercise: _current,
                      selectedOptionId: _selectedOptionId,
                      answered: _answered,
                      color: cat.color,
                      onSelect: _selectOption,
                    ),
                  if (_current.isMatching)
                    _MatchingOptions(
                      exercise: _current,
                      leftSelected: _leftSelected,
                      rightSelected: _rightSelected,
                      matchingAnswers: _matchingAnswers,
                      answered: _answered,
                      color: cat.color,
                      onSelectLeft: _selectMatchingLeft,
                      onSelectRight: _selectMatchingRight,
                    ),
                  const SizedBox(height: 20),
                  if (_answered)
                    ScaleTransition(
                      scale: _feedbackScale,
                      child: _AnswerFeedback(
                        exercise: _current,
                        selectedOptionId: _selectedOptionId,
                        matchingAnswers: _matchingAnswers,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_answered)
            _NextButton(
              isLast: _isLast,
              color: cat.color,
              onTap: _next,
            ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ExerciseHeader extends StatelessWidget {
  final LessonCategoryModel category;
  final int currentIndex;
  final int total;
  final AnimationController progressController;

  const _ExerciseHeader({
    required this.category,
    required this.currentIndex,
    required this.total,
    required this.progressController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: category.color,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => _confirmExit(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedBuilder(
                  animation: progressController,
                  builder: (_, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: progressController.value,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${currentIndex + 1}/$total',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair do exercício?'),
        content: const Text('Seu progresso nesta sessão não será salvo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continuar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

// ─── Badge de tipo ────────────────────────────────────────────────────────────

class _ExerciseTypeBadge extends StatelessWidget {
  final LessonExerciseType type;
  final Color color;

  const _ExerciseTypeBadge({required this.type, required this.color});

  String get _label {
    switch (type) {
      case LessonExerciseType.trueFalse:
        return 'Verdadeiro ou Falso';
      case LessonExerciseType.matching:
        return 'Associação';
      default:
        return 'Múltipla Escolha';
    }
  }

  IconData get _icon {
    switch (type) {
      case LessonExerciseType.trueFalse:
        return Icons.thumbs_up_down_rounded;
      case LessonExerciseType.matching:
        return Icons.compare_arrows_rounded;
      default:
        return Icons.radio_button_checked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            _label,
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

// ─── Opções múltipla escolha / V/F ───────────────────────────────────────────

class _MultipleChoiceOptions extends StatelessWidget {
  final LessonExerciseModel exercise;
  final String? selectedOptionId;
  final bool answered;
  final Color color;
  final ValueChanged<String> onSelect;

  const _MultipleChoiceOptions({
    required this.exercise,
    required this.selectedOptionId,
    required this.answered,
    required this.color,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: exercise.options.map((opt) {
        final isSelected = selectedOptionId == opt.id;
        final isCorrect = exercise.correctOptionId == opt.id;
        final showCorrect = answered && isCorrect;
        final showWrong = answered && isSelected && !isCorrect;

        Color borderColor;
        Color bgColor;
        Color textColor;
        Widget? trailingIcon;

        if (showCorrect) {
          borderColor = const Color(0xFF16A34A);
          bgColor = const Color(0xFF16A34A).withValues(alpha: 0.08);
          textColor = const Color(0xFF15803D);
          trailingIcon = const Icon(Icons.check_circle_rounded,
              color: Color(0xFF16A34A), size: 22);
        } else if (showWrong) {
          borderColor = const Color(0xFFDC2626);
          bgColor = const Color(0xFFDC2626).withValues(alpha: 0.08);
          textColor = const Color(0xFFB91C1C);
          trailingIcon = const Icon(Icons.cancel_rounded,
              color: Color(0xFFDC2626), size: 22);
        } else if (isSelected) {
          borderColor = color;
          bgColor = color.withValues(alpha: 0.08);
          textColor = scheme.onSurface;
          trailingIcon = null;
        } else {
          borderColor = scheme.outline.withValues(alpha: 0.4);
          bgColor = scheme.surface;
          textColor = scheme.onSurface;
          trailingIcon = null;
        }

        return GestureDetector(
          onTap: () => onSelect(opt.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    opt.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                if (trailingIcon != null) trailingIcon,
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Opções de associação ─────────────────────────────────────────────────────

class _MatchingOptions extends StatelessWidget {
  final LessonExerciseModel exercise;
  final String? leftSelected;
  final String? rightSelected;
  final Map<String, String> matchingAnswers;
  final bool answered;
  final Color color;
  final ValueChanged<String> onSelectLeft;
  final ValueChanged<String> onSelectRight;

  const _MatchingOptions({
    required this.exercise,
    required this.leftSelected,
    required this.rightSelected,
    required this.matchingAnswers,
    required this.answered,
    required this.color,
    required this.onSelectLeft,
    required this.onSelectRight,
  });

  bool _isPairCorrect(String left, String right) {
    return exercise.pairs.any((p) => p.left == left && p.right == right);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rights = exercise.pairs.map((p) => p.right).toList()..shuffle();

    return Column(
      children: [
        Text(
          'Selecione um item da esquerda, depois um da direita para formar o par.',
          style: TextStyle(
            fontSize: 13,
            color: scheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coluna esquerda
            Expanded(
              child: Column(
                children: exercise.pairs.map((pair) {
                  final isSelected = leftSelected == pair.left;
                  final isMatched = matchingAnswers.containsKey(pair.left);
                  final matchedRight = matchingAnswers[pair.left];
                  final isCorrect = isMatched &&
                      matchedRight != null &&
                      _isPairCorrect(pair.left, matchedRight);

                  Color bg;
                  Color border;
                  if (answered && isMatched) {
                    bg = isCorrect
                        ? const Color(0xFF16A34A).withValues(alpha: 0.08)
                        : const Color(0xFFDC2626).withValues(alpha: 0.08);
                    border = isCorrect
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626);
                  } else if (isSelected) {
                    bg = color.withValues(alpha: 0.1);
                    border = color;
                  } else if (isMatched) {
                    bg = scheme.surfaceVariant ?? scheme.surface;
                    border = scheme.outline.withValues(alpha: 0.3);
                  } else {
                    bg = scheme.surface;
                    border = scheme.outline.withValues(alpha: 0.4);
                  }

                  return GestureDetector(
                    onTap: isMatched ? null : () => onSelectLeft(pair.left),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: border, width: 1.5),
                      ),
                      child: Text(
                        pair.left,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              child: Icon(
                Icons.compare_arrows_rounded,
                color: scheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            // Coluna direita
            Expanded(
              child: Column(
                children: rights.map((right) {
                  final isSelected = rightSelected == right;
                  final isMatched = matchingAnswers.containsValue(right);
                  final matchedLeft = matchingAnswers.entries
                      .where((e) => e.value == right)
                      .map((e) => e.key)
                      .firstOrNull;
                  final isCorrect = isMatched &&
                      matchedLeft != null &&
                      _isPairCorrect(matchedLeft, right);

                  Color bg;
                  Color border;
                  if (answered && isMatched) {
                    bg = isCorrect
                        ? const Color(0xFF16A34A).withValues(alpha: 0.08)
                        : const Color(0xFFDC2626).withValues(alpha: 0.08);
                    border = isCorrect
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626);
                  } else if (isSelected) {
                    bg = color.withValues(alpha: 0.1);
                    border = color;
                  } else if (isMatched) {
                    bg = scheme.surfaceVariant ?? scheme.surface;
                    border = scheme.outline.withValues(alpha: 0.3);
                  } else {
                    bg = scheme.surface;
                    border = scheme.outline.withValues(alpha: 0.4);
                  }

                  return GestureDetector(
                    onTap: isMatched ? null : () => onSelectRight(right),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: border, width: 1.5),
                      ),
                      child: Text(
                        right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Feedback de resposta ─────────────────────────────────────────────────────

class _AnswerFeedback extends StatelessWidget {
  final LessonExerciseModel exercise;
  final String? selectedOptionId;
  final Map<String, String> matchingAnswers;

  const _AnswerFeedback({
    required this.exercise,
    required this.selectedOptionId,
    required this.matchingAnswers,
  });

  bool get _isCorrect {
    if (exercise.isMatching) {
      return exercise.pairs
          .every((p) => matchingAnswers[p.left] == p.right);
    }
    return exercise.correctOptionId == selectedOptionId;
  }

  @override
  Widget build(BuildContext context) {
    final correct = _isCorrect;
    const correctColor = Color(0xFF16A34A);
    const wrongColor = Color(0xFFD97706);

    final feedbackColor = correct ? correctColor : wrongColor;
    final icon = correct
        ? Icons.check_circle_rounded
        : Icons.lightbulb_outline_rounded;
    final title = correct ? 'Correto!' : 'Quase lá!';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: feedbackColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: feedbackColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: feedbackColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: feedbackColor,
                  ),
                ),
                if (exercise.explanation != null &&
                    exercise.explanation!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    exercise.explanation!,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: feedbackColor.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Botão próximo ────────────────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  final bool isLast;
  final Color color;
  final VoidCallback onTap;

  const _NextButton({
    required this.isLast,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
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
            child: Text(
              isLast ? 'Ver resultado' : 'Próximo',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tela de resultado ────────────────────────────────────────────────────────

class _ResultScreen extends StatefulWidget {
  final LessonModel lesson;
  final LessonCategoryModel category;
  final int correctCount;
  final int totalCount;

  const _ResultScreen({
    required this.lesson,
    required this.category,
    required this.correctCount,
    required this.totalCount,
  });

  @override
  State<_ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<_ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim =
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _scoreRatio =>
      widget.totalCount == 0 ? 1 : widget.correctCount / widget.totalCount;

  String get _title {
    if (_scoreRatio >= 0.8) return 'Excelente!';
    if (_scoreRatio >= 0.5) return 'Bom trabalho!';
    return 'Continue praticando!';
  }

  String get _subtitle {
    if (_scoreRatio >= 0.8) return 'Você dominou esta lição!';
    if (_scoreRatio >= 0.5) return 'Você está evoluindo. Revise e tente de novo!';
    return 'Revise o conteúdo e tente novamente.';
  }

  Color get _resultColor {
    if (_scoreRatio >= 0.8) return const Color(0xFF16A34A);
    if (_scoreRatio >= 0.5) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [cat.color, cat.color.withValues(alpha: 0.6)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  const Spacer(),
                  // Ícone animado
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _scoreRatio >= 0.8
                              ? Icons.emoji_events_rounded
                              : _scoreRatio >= 0.5
                                  ? Icons.trending_up_rounded
                                  : Icons.replay_rounded,
                          size: 56,
                          color: _resultColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    _title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Card de pontuação
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _ScoreStat(
                              label: 'Acertos',
                              value: '${widget.correctCount}',
                              color: const Color(0xFF16A34A),
                            ),
                            Container(
                                width: 1,
                                height: 50,
                                color: const Color(0xFFE5E7EB)),
                            _ScoreStat(
                              label: 'Erros',
                              value:
                                  '${widget.totalCount - widget.correctCount}',
                              color: const Color(0xFFDC2626),
                            ),
                            Container(
                                width: 1,
                                height: 50,
                                color: const Color(0xFFE5E7EB)),
                            _ScoreStat(
                              label: 'Pontuação',
                              value: '${(_scoreRatio * 100).round()}%',
                              color: _resultColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: _scoreRatio,
                            backgroundColor:
                                _resultColor.withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _resultColor),
                            minHeight: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context)
                          ..pop()
                          ..pop();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: cat.color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Voltar para lições',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ScoreStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
