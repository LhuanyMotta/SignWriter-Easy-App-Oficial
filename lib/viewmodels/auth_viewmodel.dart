import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_profile_service.dart';

/// ViewModel para gerenciar autenticação
class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _supabase;
  final SupabaseProfileService _profileService;
  StreamSubscription<AuthState>? _authStateSubscription;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _currentUser;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get currentUser => _currentUser;

  AuthViewModel({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client,
        _profileService =
            SupabaseProfileService(supabaseClient ?? Supabase.instance.client) {
    _checkAuthStatus();
    _authStateSubscription =
        _supabase.auth.onAuthStateChange.listen((AuthState authState) {
      final session = authState.session;
      if (session?.user != null) {
        _loadCurrentUser(session!.user);
      } else {
        _clearSession();
      }
    });
  }

  /// Verifica o status de autenticação ao inicializar
  Future<void> _checkAuthStatus() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _clearSession();
        return;
      }

      await _loadCurrentUser(user);
    } catch (e) {
      debugPrint('Erro ao verificar status de autenticação: $e');
    }
  }

  Future<void> _loadCurrentUser(User user) async {
    final profile = await _profileService.fetchProfile(user.id);
    _currentUser = _mergeUserProfile(user, profile);
    _isAuthenticated = true;
    notifyListeners();
  }

  Map<String, dynamic> _mergeUserProfile(
    User user,
    Map<String, dynamic>? profile,
  ) {
    final metadata = user.userMetadata ?? {};
    final name = (profile?['name'] ?? metadata['name'] ?? user.email ?? 'Usuário')
        .toString();
    final createdAt = profile?['createdAt'] ?? user.createdAt;

    return {
      'id': user.id,
      'name': name,
      'email': user.email,
      'nivel': profile?['nivel'] ?? 'Iniciante',
      'createdAt': createdAt,
    };
  }

  void _clearSession() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  /// Login com email e senha
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        _setError('Não foi possível autenticar. Tente novamente.');
        return false;
      }

      await _loadCurrentUser(response.user!);
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

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      final user = response.user;
      if (user == null) {
        _setError('Não foi possível finalizar o cadastro.');
        return false;
      }

      await _profileService.upsertProfile(
        id: user.id,
        name: name,
        email: email,
      );

      if (response.session == null) {
        _setError(
          'Cadastro realizado. Confirme seu email para continuar.',
        );
        return false;
      }

      await _loadCurrentUser(user);
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
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? Uri.base.toString() : null,
      );
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
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: kIsWeb ? Uri.base.toString() : null,
      );
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
      await _supabase.auth.signOut();
      _errorMessage = null;
      _setLoading(false);
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
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _setError('Usuário não autenticado.');
        return false;
      }

      final name = userData['name']?.toString() ?? '';
      if (name.isEmpty) {
        _setError('Nome inválido.');
        return false;
      }

      await _profileService.updateProfileName(
        id: user.id,
        name: name,
      );
      _currentUser = {
        ...?_currentUser,
        ...userData,
      };
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar dados do usuário: $e');
      return false;
    }
  }

  /// Recuperação de senha
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _supabase.auth.resetPasswordForEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erro ao enviar email de recuperação: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
