import 'dart:math';
import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/sign_model.dart';
import '../../theme/app_spacing.dart';

class PracticeQuizScreen extends StatefulWidget {
  final String title;
  final List<SignModel> signs;

  const PracticeQuizScreen({
    super.key,
    required this.title,
    required this.signs,
  });

  @override
  State<PracticeQuizScreen> createState() => _PracticeQuizScreenState();
}

class _PracticeQuizScreenState extends State<PracticeQuizScreen> {
  final supabase = Supabase.instance.client;
  int currentIndex = 0;
  int score = 0;
  String? selectedAnswer;
  late List<SignModel> questions;

  @override
  void initState() {
    super.initState();
    questions = List.from(widget.signs)..shuffle();
    if (questions.length > 10) {
      questions = questions.take(10).toList();
    }
  }

  List<String> _generateOptions(SignModel correct) {
    final options = <String>{correct.name};
    final random = Random();
    final allSigns = List<SignModel>.from(widget.signs)..shuffle();

    while (options.length < 4 && options.length < widget.signs.length) {
      options.add(allSigns[random.nextInt(allSigns.length)].name);
    }

    return options.toList()..shuffle();
  }

  Future<void> _saveAnswer(SignModel sign, bool correct) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final existing = await supabase
        .from('learning_progress')
        .select()
        .eq('user_id', user.id)
        .eq('sign_id', sign.id)
        .limit(1);

    if (existing.isEmpty) {
      await supabase.from('learning_progress').insert({
        'user_id': user.id,
        'sign_id': sign.id,
        'correct_answers': correct ? 1 : 0,
        'wrong_answers': correct ? 0 : 1,
        'completed': correct,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } else {
      final item = existing.first;

      await supabase
          .from('learning_progress')
          .update({
            'correct_answers': (item['correct_answers'] ?? 0) + (correct ? 1 : 0),
            'wrong_answers': (item['wrong_answers'] ?? 0) + (correct ? 0 : 1),
            'completed': correct ? true : item['completed'],
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', item['id']);
    }
  }

  void _answer(SignModel sign, String answer) async {
    if (selectedAnswer != null) return;

    final isCorrect = answer == sign.name;

    setState(() {
      selectedAnswer = answer;
      if (isCorrect) score++;
    });

    await _saveAnswer(sign, isCorrect);
  }

  void _nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(context.l10n.quizExerciseDone),
          content: Text('Você acertou $score de ${questions.length} sinais.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Finalizar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(child: Text(context.l10n.quizNoSigns)),
      );
    }

    final sign = questions[currentIndex];
    final options = _generateOptions(sign);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF2D78BB),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: AppSpacing.all(context, 16),
        child: Column(
          children: [
            Text(
              'Questão ${currentIndex + 1} de ${questions.length}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D78BB),
              ),
            ),
            SizedBox(height: AppSpacing.value(context, 16)),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: AppSpacing.all(context, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Image.network(
                  sign.signImagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(height: AppSpacing.value(context, 20)),

            const Text(
              'Qual é este sinal?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: AppSpacing.value(context, 16)),

            ...options.map((option) {
              final isSelected = selectedAnswer == option;
              final isCorrect = option == sign.name;

              Color color = Colors.white;
              if (selectedAnswer != null) {
                if (isCorrect) color = Colors.green.shade100;
                if (isSelected && !isCorrect) color = Colors.red.shade100;
              }

              return Container(
                width: double.infinity,
                margin: AppSpacing.only(context, bottom: 10),
                child: ElevatedButton(
                  onPressed: () => _answer(sign, option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.black87,
                    padding: AppSpacing.symmetric(context, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(option),
                ),
              );
            }),

            SizedBox(height: AppSpacing.value(context, 8)),

            ElevatedButton(
              onPressed: selectedAnswer == null ? null : _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D78BB),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
              ),
              child: Text(context.l10n.quizNext),
            ),
          ],
        ),
      ),
    );
  }
}
