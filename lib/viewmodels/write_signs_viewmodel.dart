import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sign_model.dart';

/// ViewModel para a tela de escrita de sinais
class WriteSignsViewModel extends ChangeNotifier {
  /// Lista de sinais recentemente criados
  List<SignModel> _recentSigns = [];
  
  /// Lista de categorias disponíveis
  final List<String> categories = [
    'Alfabeto',
    'Números',
    'Cumprimentos',
    'Família',
    'Tempo',
    'Alimentos',
    'Cores',
    'Animais',
    'Verbos',
    'Outros',
  ];
  
  /// Categoria selecionada no momento
  String _selectedCategory = 'Alfabeto';
  
  /// Modo de edição atual (novo sinal ou edição)
  bool _isEditMode = false;
  
  /// Mensagem de status das operações
  String _statusMessage = '';
  
  /// Indica se uma operação está em andamento
  bool _isLoading = false;

  /// Getter para a lista de sinais recentes
  List<SignModel> get recentSigns => _recentSigns;
  
  /// Getter para a categoria selecionada
  String get selectedCategory => _selectedCategory;
  
  /// Getter para verificar se estamos em modo de edição
  bool get isEditMode => _isEditMode;
  
  /// Getter para a mensagem de status
  String get statusMessage => _statusMessage;
  
  /// Getter para verificar se está carregando
  bool get isLoading => _isLoading;

  /// Construtor
  WriteSignsViewModel() {
    // Inicializar com dados fictícios (mock)
    // Futuramente, aqui carregaríamos do banco de dados
    _loadMockData();
  }

  /// Carrega dados mock para a aplicação (temporário)
  void _loadMockData() {
    _recentSigns = [
      SignModel(
        id: '1',
        name: 'Conversar',
        description: 'Interação por sinais',
        signImagePath: 'assets/signs/conversar.png',
        category: 'Comunicacao',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SignModel(
        id: '2',
        name: 'Estudar',
        description: 'Atividade de aprendizagem',
        signImagePath: 'assets/signs/estudar.png',
        category: 'Educacao',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
    notifyListeners();
  }

  /// Altera a categoria selecionada
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Ativa o modo de edição
  void enableEditMode() {
    _isEditMode = true;
    notifyListeners();
  }

  /// Desativa o modo de edição
  void disableEditMode() {
    _isEditMode = false;
    notifyListeners();
  }

  /// Salva um novo sinal
  Future<bool> saveSign(SignModel sign) async {
    _isLoading = true;
    _statusMessage = 'Salvando sinal...';
    notifyListeners();
    
    try {
      // Simular uma operação assíncrona
      await Future.delayed(const Duration(seconds: 1));
      
      // Adicionar à lista de sinais recentes
      // Em uma implementação real, salvaríamos no banco de dados
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

  /// Atualiza um sinal existente
  Future<bool> updateSign(SignModel sign) async {
    _isLoading = true;
    _statusMessage = 'Atualizando sinal...';
    notifyListeners();
    
    try {
      // Simular uma operação assíncrona
      await Future.delayed(const Duration(seconds: 1));
      
      // Encontrar e atualizar o sinal na lista
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

  /// Exclui um sinal
  Future<bool> deleteSign(String signId) async {
    _isLoading = true;
    _statusMessage = 'Excluindo sinal...';
    notifyListeners();
    
    try {
      // Simular uma operação assíncrona
      await Future.delayed(const Duration(seconds: 1));
      
      // Remover o sinal da lista
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

  /// Alterna um sinal como favorito/não favorito
  void toggleFavorite(String signId) {
    final index = _recentSigns.indexWhere((sign) => sign.id == signId);
    if (index >= 0) {
      _recentSigns[index].isFavorite = !_recentSigns[index].isFavorite;
      notifyListeners();
    }
  }

  /// Busca sinais pelo nome
  List<SignModel> searchSigns(String query) {
    if (query.isEmpty) {
      return _recentSigns;
    }
    return _recentSigns.where((sign) => 
      sign.name.toLowerCase().contains(query.toLowerCase()) ||
      (sign.description != null && sign.description!.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }
} 