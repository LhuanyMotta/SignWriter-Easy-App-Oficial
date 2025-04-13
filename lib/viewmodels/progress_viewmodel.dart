import 'package:flutter/material.dart';

/// ViewModel para a tela de Progresso
class ProgressViewModel extends ChangeNotifier {
  /// Progresso geral do usuário
  final double _overallProgress = 0.65;
  
  /// Estatísticas de tempo de estudo
  final Map<String, double> _studyTimeStats = {
    'Segunda': 45,
    'Terça': 30,
    'Quarta': 60,
    'Quinta': 20,
    'Sexta': 50,
    'Sábado': 75,
    'Domingo': 15,
  };
  
  /// Progresso por categoria
  final List<Map<String, dynamic>> _categoryProgress = [
    {
      'name': 'Introdução ao SignWriting',
      'progress': 0.9,
      'color': const Color(0xFF2D78BB),
    },
    {
      'name': 'Alfabeto Manual',
      'progress': 0.75,
      'color': const Color(0xFF4EB1F0),
    },
    {
      'name': 'Números',
      'progress': 0.6,
      'color': const Color(0xFF2D78BB),
    },
    {
      'name': 'Expressões Faciais',
      'progress': 0.4,
      'color': const Color(0xFF4EB1F0),
    },
    {
      'name': 'Movimentos',
      'progress': 0.3,
      'color': const Color(0xFF2D78BB),
    },
    {
      'name': 'Frases',
      'progress': 0.1,
      'color': const Color(0xFF4EB1F0),
    },
  ];
  
  /// Conquistas do usuário
  final List<Map<String, dynamic>> _achievements = [
    {
      'title': 'Primeira Lição',
      'description': 'Completou sua primeira lição',
      'icon': Icons.star,
      'unlocked': true,
      'date': '10/06/2023',
    },
    {
      'title': 'Estudante Dedicado',
      'description': 'Estudou por 7 dias consecutivos',
      'icon': Icons.calendar_month,
      'unlocked': true,
      'date': '15/06/2023',
    },
    {
      'title': 'Mestre do Alfabeto',
      'description': 'Dominou todo o alfabeto manual',
      'icon': Icons.abc,
      'unlocked': true,
      'date': '22/06/2023',
    },
    {
      'title': 'Especialista em Números',
      'description': 'Aprendeu todos os números de 1 a 20',
      'icon': Icons.format_list_numbered,
      'unlocked': false,
      'date': null,
    },
    {
      'title': 'Comunicador Fluente',
      'description': 'Capaz de formar frases completas',
      'icon': Icons.chat,
      'unlocked': false,
      'date': null,
    },
  ];
  
  /// Dados de uso do aplicativo
  final Map<String, dynamic> _usageData = {
    'diasConsecutivos': 5,
    'totalHorasEstudo': 12.5,
    'exerciciosCompletados': 48,
    'sinaisAprendidos': 120,
  };
  
  /// Getters para acesso aos dados
  double get overallProgress => _overallProgress;
  Map<String, double> get studyTimeStats => _studyTimeStats;
  List<Map<String, dynamic>> get categoryProgress => _categoryProgress;
  List<Map<String, dynamic>> get achievements => _achievements;
  Map<String, dynamic> get usageData => _usageData;
  
  /// Retorna o dia da semana com maior tempo de estudo
  String get bestStudyDay {
    String bestDay = '';
    double maxTime = 0;
    
    _studyTimeStats.forEach((day, time) {
      if (time > maxTime) {
        maxTime = time;
        bestDay = day;
      }
    });
    
    return bestDay;
  }
  
  /// Calcula a média diária de estudo em minutos
  double get averageStudyTime {
    if (_studyTimeStats.isEmpty) return 0;
    
    double total = 0;
    _studyTimeStats.forEach((_, time) => total += time);
    return total / _studyTimeStats.length;
  }
  
  /// Retorna a categoria com maior progresso
  Map<String, dynamic> get bestCategory {
    if (_categoryProgress.isEmpty) {
      return {
        'name': 'Nenhuma categoria',
        'progress': 0.0,
        'color': Colors.grey,
      };
    }
    
    Map<String, dynamic> best = _categoryProgress[0];
    
    for (var category in _categoryProgress) {
      if (category['progress'] > best['progress']) {
        best = category;
      }
    }
    
    return best;
  }
  
  /// Retorna o número de conquistas desbloqueadas
  int get unlockedAchievementsCount {
    return _achievements.where((a) => a['unlocked'] == true).length;
  }
  
  /// Retorna a porcentagem de conquistas desbloqueadas
  double get achievementsPercentage {
    if (_achievements.isEmpty) return 0;
    return unlockedAchievementsCount / _achievements.length;
  }
  
  /// Compartilha o progresso do usuário
  void shareProgress(BuildContext context) {
    // Implementação futura para compartilhar progresso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compartilhamento de progresso será implementado em breve')),
    );
  }
  
  /// Exporta os dados de progresso do usuário
  void exportProgressData(BuildContext context) {
    // Implementação futura para exportar dados
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exportação de dados será implementada em breve')),
    );
  }
} 