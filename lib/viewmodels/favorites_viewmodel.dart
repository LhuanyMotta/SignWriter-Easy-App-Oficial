import 'package:flutter/material.dart';
import '../models/sign_model.dart';
import '../services/database_service.dart';
import '../views/screens/sign_detail_screen.dart';

/// ViewModel para a tela de Favoritos
class FavoritesViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  // Lista de sinais favoritos
  final List<SignModel> _favorites = [];
  
  // Lista de categorias disponíveis
  List<String> _categories = ['Todos'];
  
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  List<SignModel> _filteredFavorites = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<SignModel> get favorites => _filteredFavorites.isEmpty && _searchQuery.isEmpty && _selectedCategory == 'Todos'
      ? _favorites
      : _filteredFavorites;
  
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Construtor que inicializa a lista filtrada
  FavoritesViewModel() {
    loadFavorites();
  }

  /// Carrega favoritos do banco
  Future<void> loadFavorites() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final favorites = await _databaseService.getFavoriteSigns();
      _favorites
        ..clear()
        ..addAll(favorites);
      _filteredFavorites = List.from(_favorites);
      _categories = _buildCategories(_favorites);
    } catch (e) {
      _errorMessage = 'Não foi possível carregar os favoritos.';
      _filteredFavorites = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Filtra itens favoritos por categoria
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }
  
  /// Pesquisa nos itens favoritos
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }
  
  /// Aplica filtros de categoria e pesquisa
  void _applyFilters() {
    if (_searchQuery.isEmpty && _selectedCategory == 'Todos') {
      _filteredFavorites = List.from(_favorites);
    } else {
      _filteredFavorites = _favorites.where((sign) {
        final matchesCategory = _selectedCategory == 'Todos' || sign.category == _selectedCategory;
        final matchesSearch = _searchQuery.isEmpty || 
                             sign.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                             (sign.description?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    }
    
    notifyListeners();
  }
  
  /// Remove um item dos favoritos
  Future<void> removeFavorite(String id) async {
    final index = _favorites.indexWhere((sign) => sign.id == id);
    if (index != -1) {
      final removed = _favorites.removeAt(index);
      
      // Também remove da lista filtrada
      _filteredFavorites.removeWhere((sign) => sign.id == id);
      
      // Atualiza estado do item para não favorito
      removed.isFavorite = false;
      await _databaseService.toggleSignFavorite(id, false);
      notifyListeners();
    }
  }
  
  /// Abre detalhes de um sinal
  Future<void> openSignDetails(BuildContext context, SignModel sign) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignDetailScreen(signId: sign.id),
      ),
    );
    await loadFavorites();
  }
  
  /// Limpa todos os favoritos
  Future<void> clearAllFavorites() async {
    for (var sign in _favorites) {
      sign.isFavorite = false;
      await _databaseService.toggleSignFavorite(sign.id, false);
    }
    
    _favorites.clear();
    _filteredFavorites.clear();
    notifyListeners();
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