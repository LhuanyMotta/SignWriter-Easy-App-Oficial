import 'package:flutter/material.dart';
import '../models/sign_model.dart';

/// ViewModel para a tela de Dicionário
class DictionaryViewModel extends ChangeNotifier {
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

  /// Categorias disponíveis para filtro
  final List<String> categories = [
    'Todos',
    'Alfabeto',
    'Números',
    'Cumprimentos',
    'Família',
    'Alimentos',
    'Verbos',
    'Cores',
    'Tempo',
    'Lugares',
  ];
  
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

  /// Construtor
  DictionaryViewModel() {
    _loadSigns();
  }

  /// Carrega os sinais do dicionário (no futuro, a partir do banco)
  void _loadSigns() {
    _isLoading = true;
    notifyListeners();
    
    // Simular carregamento de dados
    Future.delayed(const Duration(milliseconds: 800), () {
      // Criar dados de exemplo
      _signs = [
        SignModel(
          id: '1',
          name: 'Olá',
          description: 'Saudação básica',
          signImagePath: 'assets/signs/ola.png',
          category: 'Cumprimentos',
          createdAt: DateTime.now(),
        ),
        SignModel(
          id: '2',
          name: 'Obrigado',
          description: 'Expressão de gratidão',
          signImagePath: 'assets/signs/obrigado.png',
          category: 'Cumprimentos',
          createdAt: DateTime.now(),
          isFavorite: true,
        ),
        SignModel(
          id: '3',
          name: 'Bom dia',
          description: 'Saudação matinal',
          signImagePath: 'assets/signs/bom_dia.png',
          category: 'Cumprimentos',
          createdAt: DateTime.now(),
        ),
        SignModel(
          id: '4',
          name: 'Casa',
          description: 'Local onde se mora',
          signImagePath: 'assets/signs/casa.png',
          category: 'Lugares',
          createdAt: DateTime.now(),
        ),
        SignModel(
          id: '5',
          name: 'Família',
          description: 'Grupo de pessoas relacionadas',
          signImagePath: 'assets/signs/familia.png',
          category: 'Família',
          createdAt: DateTime.now(),
          isFavorite: true,
        ),
        SignModel(
          id: '6',
          name: 'Água',
          description: 'Líquido essencial para a vida',
          signImagePath: 'assets/signs/agua.png',
          category: 'Alimentos',
          createdAt: DateTime.now(),
        ),
        SignModel(
          id: '7',
          name: 'Comer',
          description: 'Ação de se alimentar',
          signImagePath: 'assets/signs/comer.png',
          category: 'Verbos',
          createdAt: DateTime.now(),
        ),
        SignModel(
          id: '8',
          name: 'Estudar',
          description: 'Ação de adquirir conhecimento',
          signImagePath: 'assets/signs/estudar.png',
          category: 'Verbos',
          createdAt: DateTime.now(),
        ),
      ];
      
      // Inicialmente, todos os sinais são mostrados
      _filteredSigns = List.from(_signs);
      
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Pesquisa sinais pelo termo fornecido
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Filtra sinais por categoria
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }
  
  /// Aplica os filtros de busca e categoria
  void _applyFilters() {
    if (_searchQuery.isEmpty && _selectedCategory == 'Todos') {
      _filteredSigns = List.from(_signs);
    } else {
      _filteredSigns = _signs.where((sign) {
        // Filtro de categoria
        bool matchesCategory = _selectedCategory == 'Todos' || 
                              sign.category == _selectedCategory;
        
        // Filtro de pesquisa
        bool matchesSearch = _searchQuery.isEmpty || 
                           sign.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           (sign.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        
        return matchesCategory && matchesSearch;
      }).toList();
    }
    
    notifyListeners();
  }

  /// Abre os detalhes de um sinal
  void openSignDetails(BuildContext context, SignModel sign) {
    // No futuro, navegará para a tela de detalhes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Detalhes do sinal: ${sign.name}')),
    );
  }

  /// Alterna um sinal como favorito
  void toggleFavorite(String signId) {
    final index = _signs.indexWhere((sign) => sign.id == signId);
    if (index >= 0) {
      _signs[index].isFavorite = !_signs[index].isFavorite;
      
      // Atualiza também na lista filtrada, se o sinal estiver lá
      final filteredIndex = _filteredSigns.indexWhere((sign) => sign.id == signId);
      if (filteredIndex >= 0) {
        _filteredSigns[filteredIndex].isFavorite = _signs[index].isFavorite;
      }
      
      notifyListeners();
    }
  }
} 