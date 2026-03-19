import 'package:flutter/material.dart';

import '../models/sign_model.dart';
import '../models/text_document_model.dart';
import '../services/database_service.dart';

/// ViewModel para listar e gerenciar documentos de texto
class TextsViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<TextDocumentModel> _documents = [];
  final Map<String, List<SignModel>> _previews = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<TextDocumentModel> get documents => _documents;
  Map<String, List<SignModel>> get previews => _previews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carrega documentos e prévias de sinais
  Future<void> loadDocuments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _documents = await _databaseService.getAllTextDocuments();
      _previews.clear();
      for (final doc in _documents) {
        final signs = await _loadSignsForDocument(doc, limit: 5);
        _previews[doc.id] = signs;
      }
    } catch (_) {
      _errorMessage = 'Não foi possível carregar os textos.';
      _documents = [];
      _previews.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega um documento pelo ID
  Future<TextDocumentModel?> loadDocumentById(String id) async {
    return _databaseService.getTextDocumentById(id);
  }

  /// Carrega sinais em ordem para um documento
  Future<List<SignModel>> loadSignsForDocument(TextDocumentModel doc) async {
    return _loadSignsForDocument(doc);
  }

  /// Remove um documento
  Future<void> deleteDocument(String id) async {
    await _databaseService.deleteTextDocument(id);
    _documents.removeWhere((doc) => doc.id == id);
    _previews.remove(id);
    notifyListeners();
  }

  Future<List<SignModel>> _loadSignsForDocument(
    TextDocumentModel doc, {
    int? limit,
  }) async {
    final ids = limit != null ? doc.signIds.take(limit).toList() : doc.signIds;
    if (ids.isEmpty) return [];
    final signs = await _databaseService.getSignsByIds(ids);
    final map = {for (final sign in signs) sign.id: sign};
    return ids.map((id) => map[id]).whereType<SignModel>().toList();
  }
}
