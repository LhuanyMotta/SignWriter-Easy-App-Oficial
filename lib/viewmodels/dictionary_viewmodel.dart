import 'package:flutter/material.dart';
import '../models/sign_model.dart';
import '../services/database_service.dart';
import '../views/screens/sign_detail_screen.dart';

/// ViewModel para a tela de Dicionário
class DictionaryViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  /// Lista de sinais no dicionário
  List<SignModel> _signs = [];
  
  /// Lista de sinais filtrados pela pesquisa
  List<SignModel> _filteredSigns = [];
  
  /// Termo de pesquisa atual
  String _searchQuery = '';
  
  /// Categoria selecionada para filtro
  String _selectedCategory = 'Todos';
  
  /// Flag para indicar se está carregando
  bool _isLoading = false;

  /// Mensagem de erro (se houver)
  String? _errorMessage;

  /// Categorias disponíveis para filtro
  List<String> _categories = ['Todos'];
  
  /// Acesso à lista de sinais
  List<SignModel> get signs => _filteredSigns.isEmpty && _searchQuery.isEmpty && _selectedCategory == 'Todos'
      ? _signs
      : _filteredSigns;
  
  /// Acesso ao termo de pesquisa
  String get searchQuery => _searchQuery;
  
  /// Acesso à categoria selecionada
  String get selectedCategory => _selectedCategory;
  
  /// Acesso ao status de carregamento
  bool get isLoading => _isLoading;

  /// Acesso ao erro
  String? get errorMessage => _errorMessage;

  /// Acesso às categorias
  List<String> get categories => _categories;

  /// Construtor
  DictionaryViewModel() {
    loadSigns();
  }

  /// Carrega os sinais do dicionário a partir do banco
  Future<void> loadSigns() async {
    _searchQuery = '';
    _selectedCategory = 'Todos';
    await _refreshSigns();
  }

  /// Pesquisa sinais pelo termo fornecido
  void search(String query) {
    _searchQuery = query;
    _refreshSigns();
  }

  /// Filtra sinais por categoria
  void filterByCategory(String category) {
    _selectedCategory = category;
    _refreshSigns();
  }

  /// Abre os detalhes de um sinal
  Future<void> openSignDetails(BuildContext context, SignModel sign) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignDetailScreen(signId: sign.id),
      ),
    );
    await _refreshSigns();
  }

  /// Alterna um sinal como favorito
  Future<void> toggleFavorite(String signId) async {
    final index = _signs.indexWhere((sign) => sign.id == signId);
    if (index >= 0) {
      final newValue = !_signs[index].isFavorite;
      _signs[index].isFavorite = newValue;
      await _databaseService.toggleSignFavorite(signId, newValue);
      
      // Atualiza também na lista filtrada, se o sinal estiver lá
      final filteredIndex = _filteredSigns.indexWhere((sign) => sign.id == signId);
      if (filteredIndex >= 0) {
        _filteredSigns[filteredIndex].isFavorite = _signs[index].isFavorite;
      }
      
      notifyListeners();
    }
  }

  Future<void> _refreshSigns() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_searchQuery.isEmpty && _selectedCategory == 'Todos') {
        _signs = await _databaseService.getSigns();
        _filteredSigns = List.from(_signs);
        _categories = _buildCategories(_signs);
      } else if (_searchQuery.isNotEmpty && _selectedCategory == 'Todos') {
        _filteredSigns = await _databaseService.searchSigns(_searchQuery);
      } else if (_searchQuery.isEmpty && _selectedCategory != 'Todos') {
        _filteredSigns = await _databaseService.getSignsByCategory(_selectedCategory);
      } else {
        final results = await _databaseService.searchSigns(_searchQuery);
        _filteredSigns = results.where((sign) => sign.category == _selectedCategory).toList();
      }
    } catch (e) {
      _errorMessage = 'Não foi possível carregar os sinais.';
      _filteredSigns = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<String> _buildCategories(List<SignModel> signs) {
    final set = <String>{};
    for (final sign in signs) {
      if (sign.category.isNotEmpty) {
        set.add(sign.category);
      }
    }
    final list = set.toList()..sort();
    return ['Todos', ...list];
  }
} 