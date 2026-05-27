import 'package:flutter/material.dart';
import '../models/written_sign_model.dart';
import '../services/written_signs_service.dart';

/// ViewModel para a tela de escrita de sinais
class WriteSignsViewModel extends ChangeNotifier {
  final WrittenSignsService _writtenSignsService = WrittenSignsService();
  List<WrittenSignModel> _signs = [];
  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _statusMessage = '';
  bool _isLoading = false;

  List<WrittenSignModel> get signs {
    return _signs.where((sign) {
      final matchesStatus = _selectedStatus == 'all' || sign.status == _selectedStatus;
      final query = _searchQuery.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          sign.title.toLowerCase().contains(query) ||
          sign.glossPt.toLowerCase().contains(query) ||
          sign.category.toLowerCase().contains(query) ||
          sign.tags.any((tag) => tag.toLowerCase().contains(query)) ||
          (sign.description?.toLowerCase().contains(query) ?? false);
      return matchesStatus && matchesQuery;
    }).toList();
  }

  List<WrittenSignModel> get draftSigns =>
      _signs.where((sign) => sign.isDraft).toList();

  List<WrittenSignModel> get publishedSigns =>
      _signs.where((sign) => sign.isPublished).toList();

  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  String get statusMessage => _statusMessage;
  bool get isLoading => _isLoading;

  WriteSignsViewModel() {
    loadSigns();
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void updateStatusFilter(String value) {
    _selectedStatus = value;
    notifyListeners();
  }

  Future<void> loadSigns() async {
    _isLoading = true;
    notifyListeners();

    try {
      _signs = await _writtenSignsService.getWrittenSigns();
      _statusMessage = '';
    } catch (e) {
      _statusMessage = 'Erro ao carregar sinais: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveSign(WrittenSignModel sign) async {
    _isLoading = true;
    _statusMessage = 'Salvando sinal...';
    notifyListeners();

    try {
      await _writtenSignsService.saveWrittenSign(sign);
      await loadSigns();
      _statusMessage = 'Sinal salvo com sucesso!';
      return true;
    } catch (e) {
      _statusMessage = 'Erro ao salvar sinal: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSign(String signId) async {
    _isLoading = true;
    _statusMessage = 'Excluindo sinal...';
    notifyListeners();

    try {
      await _writtenSignsService.deleteWrittenSign(signId);
      await loadSigns();
      _statusMessage = 'Sinal excluído com sucesso!';
      return true;
    } catch (e) {
      _statusMessage = 'Erro ao excluir sinal: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> publishSign(WrittenSignModel sign) async {
    final publishedSign = sign.copyWith(
      status: WrittenSignModel.statusPublished,
      updatedAt: DateTime.now(),
      publishedAt: sign.publishedAt ?? DateTime.now(),
    );
    return saveSign(publishedSign);
  }
}
