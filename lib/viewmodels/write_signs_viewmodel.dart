import 'package:flutter/material.dart';
import '../models/sign_model.dart';

/// ViewModel para a tela de escrita de sinais
class WriteSignsViewModel extends ChangeNotifier {
  List<SignModel> _recentSigns = [];

  bool _isEditMode = false;
  String _statusMessage = '';
  bool _isLoading = false;

  List<SignModel> get recentSigns => List.unmodifiable(_recentSigns);
  bool get isEditMode => _isEditMode;
  String get statusMessage => _statusMessage;
  bool get isLoading => _isLoading;

  void enableEditMode() {
    _isEditMode = true;
    notifyListeners();
  }

  void disableEditMode() {
    _isEditMode = false;
    notifyListeners();
  }

  Future<bool> saveSign(SignModel sign) async {
    _isLoading = true;
    _statusMessage = 'Salvando sinal...';
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _recentSigns.insert(0, sign);
      _statusMessage = 'Sinal salvo com sucesso!';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _statusMessage = 'Erro ao salvar sinal: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSign(SignModel sign) async {
    _isLoading = true;
    _statusMessage = 'Atualizando sinal...';
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      final index = _recentSigns.indexWhere((s) => s.id == sign.id);
      if (index >= 0) {
        _recentSigns[index] = sign;
      }
      _statusMessage = 'Sinal atualizado com sucesso!';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _statusMessage = 'Erro ao atualizar sinal: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSign(String signId) async {
    _isLoading = true;
    _statusMessage = 'Excluindo sinal...';
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _recentSigns.removeWhere((sign) => sign.id == signId);
      _statusMessage = 'Sinal excluído com sucesso!';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _statusMessage = 'Erro ao excluir sinal: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void toggleFavorite(String signId) {
    final index = _recentSigns.indexWhere((sign) => sign.id == signId);
    if (index >= 0) {
      _recentSigns[index].isFavorite = !_recentSigns[index].isFavorite;
      notifyListeners();
    }
  }

  List<SignModel> searchSigns(String query) {
    if (query.isEmpty) {
      return _recentSigns;
    }
    return _recentSigns
        .where(
          (sign) =>
              sign.name.toLowerCase().contains(query.toLowerCase()) ||
              (sign.description != null &&
                  sign.description!.toLowerCase().contains(query.toLowerCase())),
        )
        .toList();
  }
}
