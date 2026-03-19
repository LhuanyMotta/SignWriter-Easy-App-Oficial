import 'package:flutter/material.dart';

/// ViewModel para a tela de Aprender e Praticar
class LearnPracticeViewModel extends ChangeNotifier {
  /// Lista de categorias de aprendizado
  final List<Map<String, dynamic>> categories = [
    {
      'title': 'Introdução ao SignWriting',
      'icon': Icons.menu_book,
      'color': const Color(0xFF2D78BB),
      'progress': 0.8,
      'lessons': 5,
      'lessonsCompleted': 4,
    },
    {
      'title': 'Alfabeto Manual',
      'icon': Icons.sign_language,
      'color': const Color(0xFF4EB1F0),
      'progress': 0.6,
      'lessons': 8,
      'lessonsCompleted': 5,
    },
    {
      'title': 'Números',
      'icon': Icons.looks_one,
      'color': const Color(0xFF2D78BB),
      'progress': 0.4,
      'lessons': 6,
      'lessonsCompleted': 2,
    },
    {
      'title': 'Expressões Faciais',
      'icon': Icons.face,
      'color': const Color(0xFF4EB1F0),
      'progress': 0.3,
      'lessons': 10,
      'lessonsCompleted': 3,
    },
    {
      'title': 'Movimentos',
      'icon': Icons.swipe,
      'color': const Color(0xFF2D78BB),
      'progress': 0.1,
      'lessons': 8,
      'lessonsCompleted': 1,
    },
    {
      'title': 'Frases',
      'icon': Icons.format_quote,
      'color': const Color(0xFF4EB1F0),
      'progress': 0.0,
      'lessons': 12,
      'lessonsCompleted': 0,
    },
  ];

  /// Lista de exercícios recomendados
  final List<Map<String, dynamic>> recommendedExercises = [
    {
      'title': 'Praticar Alfabeto',
      'description': 'Exercício para reforçar o aprendizado do alfabeto manual',
      'duration': '5 min',
      'isNew': true,
    },
    {
      'title': 'Números de 1 a 10',
      'description': 'Pratique a escrita de números em SignWriting',
      'duration': '7 min',
      'isNew': false,
    },
    {
      'title': 'Cumprimentos Básicos',
      'description': 'Pratique sinais de cumprimentos e despedidas',
      'duration': '10 min',
      'isNew': true,
    },
  ];

  /// Progresso geral do usuário
  double get overallProgress {
    if (categories.isEmpty) return 0.0;

    double total = 0;
    for (var category in categories) {
      total += (category['progress'] as double? ?? 0.0);
    }
    return (total / categories.length).clamp(0.0, 1.0);
  }

  /// Abre uma categoria para aprendizado (atualmente apenas mostra SnackBar)
  void openCategory(BuildContext context, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrindo categoria: ${categories[index]['title']}')),
    );
  }

  /// Inicia um exercício recomendado (atualmente apenas mostra SnackBar)
  void startExercise(BuildContext context, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Iniciando exercício: ${recommendedExercises[index]['title']}')),
    );
  }
}
