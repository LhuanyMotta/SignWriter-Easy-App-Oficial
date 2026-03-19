import 'package:flutter/material.dart';

/// ViewModel para a tela de Progresso
class ProgressViewModel extends ChangeNotifier {
  /// Progresso geral do usuário
  // Valor inicial zerado até integração com dados reais.
  final double _overallProgress = 0.0;
  
  /// Estatísticas de tempo de estudo
  // Estrutura mantida com valores zerados para integração futura.
  final Map<String, double> _studyTimeStats = {
    'Segunda': 0,
    'Terça': 0,
    'Quarta': 0,
    'Quinta': 0,
    'Sexta': 0,
    'Sábado': 0,
    'Domingo': 0,
  };
  
  /// Progresso por categoria
  // Lista vazia para integração futura.
  final List<Map<String, dynamic>> _categoryProgress = [];

  /// Dados de uso do aplicativo
  // Estrutura mantida com valores zerados para integração futura.
  final Map<String, dynamic> _usageData = {
    'diasConsecutivos': 0,
    'totalHorasEstudo': 0,
    'exerciciosCompletados': 0,
    'sinaisAprendidos': 0,
  };
  
  /// Getters para acesso aos dados
  double get overallProgress => _overallProgress;
  Map<String, double> get studyTimeStats => _studyTimeStats;
  List<Map<String, dynamic>> get categoryProgress => _categoryProgress;
  Map<String, dynamic> get usageData => _usageData;

  /// Retorna o dia da semana com maior tempo de estudo
  String get bestStudyDay {
    if (_studyTimeStats.values.every((value) => value == 0)) {
      return 'Sem dados';
    }

    String bestDay = '';
    double maxTime = 0;

    _studyTimeStats.forEach((day, time) {
      if (time > maxTime) {
        maxTime = time;
        bestDay = day;
      }
    });

    return bestDay.isEmpty ? 'Sem dados' : bestDay;
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