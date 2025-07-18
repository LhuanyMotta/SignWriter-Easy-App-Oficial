import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// ViewModel para gerenciar autenticação
class AuthViewModel extends ChangeNotifier {
  final StorageService _storage = StorageService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _currentUser;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get currentUser => _currentUser;

  AuthViewModel() {
    _checkAuthStatus();
  }

  /// Verifica o status de autenticação ao inicializar
  Future<void> _checkAuthStatus() async {
    try {
      _isAuthenticated = await _storage.isAuthenticated();
      if (_isAuthenticated) {
        _currentUser = await _storage.getUserData();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao verificar status de autenticação: $e');
    }
  }

  /// Login com email e senha
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Busca usuários temporários
      final users = await _storage.getTemporaryUsers();
      
      // Verifica se existe usuário com esse email
      final userIndex = users.indexWhere((u) => u['email'] == email);
      
      if (userIndex == -1) {
        _setError('Email não cadastrado. Faça seu cadastro primeiro.');
        return false;
      }
      
      final user = users[userIndex];
      
      // Verifica senha
      if (user['password'] != password) {
        _setError('Senha incorreta.');
        return false;
      }

      // Remove senha antes de salvar dados do usuário
      user.remove('password');
      
      // Gera token simulado
      final token = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Salva dados
      await _storage.saveAuthToken(token);
      await _storage.saveUserData(user);
      
      _currentUser = user;
      _isAuthenticated = true;
      _setLoading(false);
      
      return true;
    } catch (e) {
      _setError('Erro ao fazer login: $e');
      return false;
    }
  }

  /// Cadastro com email e senha
  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Validações
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        _setError('Por favor, preencha todos os campos');
        return false;
      }

      if (name.length < 2) {
        _setError('Nome deve ter pelo menos 2 caracteres');
        return false;
      }

      if (!_isValidEmail(email)) {
        _setError('Email inválido');
        return false;
      }

      if (password.length < 6) {
        _setError('Senha deve ter pelo menos 6 caracteres');
        return false;
      }

      // Busca usuários existentes
      final users = await _storage.getTemporaryUsers();
      
      // Verifica se email já existe
      if (users.any((u) => u['email'] == email)) {
        _setError('Email já cadastrado. Faça login.');
        return false;
      }

      // Cria novo usuário
      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'email': email,
        'password': password, // Em produção, deve ser criptografada
        'nivel': 'Iniciante',
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Adiciona à lista e salva
      users.add(newUser);
      await _storage.saveTemporaryUsers(users);

      // Remove senha antes de salvar dados do usuário
      final userData = Map<String, dynamic>.from(newUser)..remove('password');
      
      // Gera token simulado
      final token = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Salva dados
      await _storage.saveAuthToken(token);
      await _storage.saveUserData(userData);
      
      _currentUser = userData;
      _isAuthenticated = true;
      _setLoading(false);
      
      return true;
    } catch (e) {
      _setError('Erro ao fazer cadastro: $e');
      return false;
    }
  }

  /// Login com Google (simulado)
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      // Simula dados do Google
      final userData = {
        'id': 'g_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Usuário Google',
        'email': 'usuario@gmail.com',
        'provider': 'google',
        'nivel': 'Iniciante',
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Gera token simulado
      final token = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Salva dados
      await _storage.saveAuthToken(token);
      await _storage.saveUserData(userData);
      
      _currentUser = userData;
      _isAuthenticated = true;
      _setLoading(false);
      
      return true;
    } catch (e) {
      _setError('Erro ao fazer login com Google: $e');
      return false;
    }
  }

  /// Login com Apple (simulado)
  Future<bool> signInWithApple() async {
    _setLoading(true);
    _clearError();

    try {
      // Simula dados da Apple
      final userData = {
        'id': 'a_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Usuário Apple',
        'email': 'usuario@icloud.com',
        'provider': 'apple',
        'nivel': 'Iniciante',
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Gera token simulado
      final token = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Salva dados
      await _storage.saveAuthToken(token);
      await _storage.saveUserData(userData);
      
      _currentUser = userData;
      _isAuthenticated = true;
      _setLoading(false);
      
      return true;
    } catch (e) {
      _setError('Erro ao fazer login com Apple: $e');
      return false;
    }
  }

  /// Logout
  Future<bool> signOut() async {
    _setLoading(true);
    
    try {
      await _storage.clearAll();
      
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = null;
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Erro ao fazer logout: $e');
      return false;
    }
  }

  /// Validar formato de email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Definir estado de carregamento
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Definir mensagem de erro
  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  /// Limpar mensagem de erro
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Atualiza dados do usuário
  Future<bool> updateUserData(Map<String, dynamic> userData) async {
    try {
      await _storage.saveUserData(userData);
      _currentUser = userData;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar dados do usuário: $e');
      return false;
    }
  }
} 