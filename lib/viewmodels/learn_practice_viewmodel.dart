import 'package:flutter/material.dart';

/// ViewModel para a tela de Aprender e Praticar
class LearnPracticeViewModel extends ChangeNotifier {
  /// Categorias de aprendizado (estrutura sem dados mock de progresso)
  final List<Map<String, dynamic>> categories = [
    {
      'title': 'Introdução ao SignWriting',
      'icon': Icons.menu_book,
      'color': const Color(0xFF2D78BB),
    },
    {
      'title': 'Alfabeto Manual',
      'icon': Icons.sign_language,
      'color': const Color(0xFF4EB1F0),
    },
    {
      'title': 'Números',
      'icon': Icons.looks_one,
      'color': const Color(0xFF2D78BB),
    },
    {
      'title': 'Expressões Faciais',
      'icon': Icons.face,
      'color': const Color(0xFF4EB1F0),
    },
    {
      'title': 'Movimentos',
      'icon': Icons.swipe,
      'color': const Color(0xFF2D78BB),
    },
    {
      'title': 'Frases',
      'icon': Icons.format_quote,
      'color': const Color(0xFF4EB1F0),
    },
  ];

  void openCategory(BuildContext context, int index) {
    // Integração futura com progresso e lições reais
  }
}
