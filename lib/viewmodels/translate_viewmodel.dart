import 'package:flutter/material.dart';

import '../models/sign_model.dart';
import '../models/translation_model.dart';
import '../services/translation_service.dart';

/// ViewModel da tela de tradução
class TranslateViewModel extends ChangeNotifier {
  final TranslationService _translationService = TranslationService();

  bool _isTranslating = false;
  String? _errorMessage;
  List<SignModel> _signs = [];
  List<String> _notFoundWords = [];
  String? _signWritingSequence;
  TranslationModel? _lastTranslation;
  List<TranslationModel> _recentTranslations = [];

  bool get isTranslating => _isTranslating;
  String? get errorMessage => _errorMessage;
  List<SignModel> get signs => _signs;
  List<String> get notFoundWords => _notFoundWords;
  String? get signWritingSequence => _signWritingSequence;
  TranslationModel? get lastTranslation => _lastTranslation;
  List<TranslationModel> get recentTranslations => _recentTranslations;

  /// Limpa o resultado atual sem afetar o histórico.
  void clearResults() {
    _errorMessage = null;
    _signs = [];
    _notFoundWords = [];
    _signWritingSequence = null;
    _lastTranslation = null;
    notifyListeners();
  }

  /// Carrega histórico recente
  Future<void> loadRecentTranslations() async {
    _recentTranslations = await _translationService.getRecentTranslations();
    notifyListeners();
  }

  /// Executa tradução
  Future<void> translate(String text) async {
    if (text.trim().isEmpty) {
      clearResults();
      return;
    }
    _isTranslating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _translationService.translateTextToSigns(text);
      _lastTranslation = result.translation;
      _signs = result.signs;
      _notFoundWords = result.translation.notFoundWords;
      _signWritingSequence = result.translation.signWritingSequence;
      await loadRecentTranslations();
    } catch (_) {
      _errorMessage = 'Não foi possível traduzir o texto.';
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }
}
