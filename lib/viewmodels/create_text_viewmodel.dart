import 'package:flutter/material.dart';

import '../models/sign_model.dart';
import '../models/text_document_model.dart';
import '../services/database_service.dart';

/// ViewModel para criação de textos em sinais
class CreateTextViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<SignModel> _availableSigns = [];
  List<String> _selectedSignIds = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SignModel> get availableSigns => _availableSigns;
  List<String> get selectedSignIds => _selectedSignIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carrega sinais disponíveis do banco
  Future<void> loadAvailableSigns() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _availableSigns = await _databaseService.getSigns();
    } catch (_) {
      _errorMessage = 'Não foi possível carregar os sinais.';
      _availableSigns = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona um sinal à composição
  void addSign(SignModel sign) {
    _selectedSignIds.add(sign.id);
    notifyListeners();
  }

  /// Remove um sinal da composição pelo índice
  void removeSignAt(int index) {
    if (index < 0 || index >= _selectedSignIds.length) return;
    _selectedSignIds.removeAt(index);
    notifyListeners();
  }

  /// Reordena sinais na composição
  void moveSign(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _selectedSignIds.length) return;
    if (newIndex < 0 || newIndex >= _selectedSignIds.length) return;
    final item = _selectedSignIds.removeAt(oldIndex);
    _selectedSignIds.insert(newIndex, item);
    notifyListeners();
  }

  /// Salva o documento no banco e retorna o ID
  Future<String?> saveDocument(String title) async {
    if (title.trim().isEmpty) {
      _errorMessage = 'Informe um título.';
      notifyListeners();
      return null;
    }
    if (_selectedSignIds.isEmpty) {
      _errorMessage = 'Adicione pelo menos um sinal.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final id = now.microsecondsSinceEpoch.toString();
      final document = TextDocumentModel(
        id: id,
        title: title.trim(),
        signIds: List.from(_selectedSignIds),
        createdAt: now,
        updatedAt: null,
      );
      await _databaseService.saveTextDocument(document);
      return id;
    } catch (_) {
      _errorMessage = 'Não foi possível salvar o texto.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
