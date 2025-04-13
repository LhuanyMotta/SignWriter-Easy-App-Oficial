import 'package:flutter/material.dart';
import '../models/sign_model.dart';

/// ViewModel para a tela de Favoritos
class FavoritesViewModel extends ChangeNotifier {
  // Lista de sinais favoritos (mockada)
  final List<SignModel> _favorites = [
    SignModel.demo(
      id: '1',
      name: 'Olá',
      description: 'Saudação básica',
      category: 'Cumprimentos',
      isFavorite: true,
    ),
    SignModel.demo(
      id: '2',
      name: 'Obrigado',
      description: 'Expressão de gratidão',
      category: 'Expressões',
      isFavorite: true,
    ),
    SignModel.demo(
      id: '3',
      name: 'Bom dia',
      description: 'Saudação matinal',
      category: 'Cumprimentos',
      isFavorite: true,
    ),
    SignModel.demo(
      id: '4',
      name: 'Casa',
      description: 'Residência, lar',
      category: 'Lugares',
      isFavorite: true,
    ),
    SignModel.demo(
      id: '5',
      name: 'Família',
      description: 'Grupo de parentes',
      category: 'Pessoas',
      isFavorite: true,
    ),
  ];
  
  // Lista de categorias disponíveis
  final List<String> _categories = [
    'Todos',
    'Cumprimentos',
    'Expressões',
    'Lugares',
    'Pessoas',
  ];
  
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  List<SignModel> _filteredFavorites = [];
  
  // Getters
  List<SignModel> get favorites => _filteredFavorites.isEmpty && _searchQuery.isEmpty && _selectedCategory == 'Todos'
      ? _favorites
      : _filteredFavorites;
  
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  
  /// Construtor que inicializa a lista filtrada
  FavoritesViewModel() {
    _filteredFavorites = List.from(_favorites);
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
  void removeFavorite(String id) {
    final index = _favorites.indexWhere((sign) => sign.id == id);
    if (index != -1) {
      final removed = _favorites.removeAt(index);
      
      // Também remove da lista filtrada
      _filteredFavorites.removeWhere((sign) => sign.id == id);
      
      // Atualiza estado do item para não favorito
      removed.isFavorite = false;
      
      notifyListeners();
    }
  }
  
  /// Abre detalhes de um sinal
  void openSignDetails(BuildContext context, SignModel sign) {
    // Implementação futura para abrir detalhes do sinal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Detalhes do sinal "${sign.name}" serão implementados em breve')),
    );
  }
  
  /// Limpa todos os favoritos
  void clearAllFavorites() {
    for (var sign in _favorites) {
      sign.isFavorite = false;
    }
    
    _favorites.clear();
    _filteredFavorites.clear();
    notifyListeners();
  }
} 