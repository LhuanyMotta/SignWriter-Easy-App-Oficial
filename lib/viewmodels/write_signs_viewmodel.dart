import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/written_sign_model.dart';
import '../services/written_signs_service.dart';
import '../utils/friendly_error.dart';

/// ViewModel para a tela de escrita de sinais
class WriteSignsViewModel extends ChangeNotifier {
  WriteSignsViewModel({
    WrittenSignsService? writtenSignsService,
    bool loadOnCreate = true,
  }) : _writtenSignsService = writtenSignsService ?? WrittenSignsService() {
    if (loadOnCreate) {
      loadSigns();
    }
  }

  final WrittenSignsService _writtenSignsService;
  List<WrittenSignModel> _signs = [];
  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _statusMessage = '';
  String? _loadError;
  bool _isLoading = false;
  bool _isSaving = false;

  List<WrittenSignModel> get signs {
    return _signs.where((sign) {
      final matchesStatus =
          _selectedStatus == 'all' || sign.status == _selectedStatus;
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
  String? get loadError => _loadError;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isAuthenticated =>
      Supabase.instance.client.auth.currentUser != null;

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
    _loadError = null;
    notifyListeners();

    try {
      if (!isAuthenticated) {
        _signs = [];
        _statusMessage = 'Faça login para ver e salvar seus sinais.';
        return;
      }
      _signs = await _writtenSignsService.getWrittenSigns();
      _statusMessage = '';
      _loadError = null;
    } catch (e) {
      _loadError = friendlyError(e);
      _statusMessage = '';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cria ou atualiza conforme [isCreate] (tela usa `initialSign == null`).
  Future<bool> saveSign(
    WrittenSignModel sign, {
    required bool isCreate,
  }) async {
    if (!isAuthenticated) {
      _statusMessage = 'Faça login para salvar sinais.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _statusMessage = '';
    notifyListeners();

    try {
      final saved = isCreate
          ? await _writtenSignsService.createWrittenSign(sign)
          : await _writtenSignsService.updateWrittenSign(sign);
      _upsertLocal(saved);
      _statusMessage = 'Sinal salvo com sucesso!';
      return true;
    } catch (e) {
      _statusMessage = friendlyError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSign(String signId) async {
    if (!isAuthenticated) {
      _statusMessage = 'Faça login para excluir sinais.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _statusMessage = '';
    notifyListeners();

    try {
      await _writtenSignsService.deleteWrittenSign(signId);
      _signs = _signs.where((sign) => sign.id != signId).toList();
      _statusMessage = 'Sinal excluído com sucesso!';
      return true;
    } catch (e) {
      _statusMessage = friendlyError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> publishSign(WrittenSignModel sign) async {
    final publishedSign = sign.copyWith(
      status: WrittenSignModel.statusPublished,
      updatedAt: DateTime.now(),
      publishedAt: sign.publishedAt ?? DateTime.now(),
    );
    return saveSign(publishedSign, isCreate: false);
  }

  void _upsertLocal(WrittenSignModel saved) {
    final index = _signs.indexWhere((item) => item.id == saved.id);
    if (index >= 0) {
      _signs = List<WrittenSignModel>.from(_signs)..[index] = saved;
    } else {
      _signs = [saved, ..._signs];
    }
  }

}
