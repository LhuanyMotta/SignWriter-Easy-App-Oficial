import 'package:flutter/material.dart';

import '../models/sign_model.dart';
import '../services/database_service.dart';

/// ViewModel para a tela de detalhes do sinal
class SignDetailViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  SignModel? _sign;
  bool _isLoading = false;
  String? _errorMessage;

  SignModel? get sign => _sign;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carrega um sinal pelo ID
  Future<void> loadSign(String signId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sign = await _databaseService.getSignById(signId);
      if (_sign == null) {
        _errorMessage = 'Sinal não encontrado.';
      }
    } catch (e) {
      _errorMessage = 'Não foi possível carregar o sinal.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Alterna favorito do sinal carregado
  Future<void> toggleFavorite() async {
    final current = _sign;
    if (current == null) return;
    final newValue = !current.isFavorite;
    current.isFavorite = newValue;
    await _databaseService.toggleSignFavorite(current.id, newValue);
    notifyListeners();
  }
}
