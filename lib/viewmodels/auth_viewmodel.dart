import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _supabase;

  bool _isLoading = false;
  String? _error;

  AuthViewModel(this._supabase);

  bool get isLoading => _isLoading;
  String? get error => _error;

  // ---------- SIGN IN ----------
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = _translateAuthError(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro interno: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ---------- SIGN UP ----------
  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name},
      );

      if (res.user != null) {
        // Tenta criar perfil
        try {
          await _supabase.from('profiles').insert({
            'id': res.user!.id,
            'name': name,
            'email': email,
            'level': 'Beginner',
          });
        } catch (e) {
          // Ignora erro de perfil
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Erro ao criar conta';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      _error = _translateAuthError(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro interno: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ---------- LOGOUT ----------
  Future<bool> signOut() async {
    try {
      await _supabase.auth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ---------- SOCIAL LOGIN ----------
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    _error = 'Login com Google será implementado em breve';
    notifyListeners();
    return false;
  }

  Future<bool> signInWithApple() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    _error = 'Login com Apple será implementado em breve';
    notifyListeners();
    return false;
  }

  // ---------- HELPER ----------
  String _translateAuthError(String error) {
    error = error.toLowerCase();
    
    if (error.contains('invalid login credentials')) {
      return 'Email ou senha incorretos';
    } else if (error.contains('user already registered')) {
      return 'Email já cadastrado';
    } else if (error.contains('password should be at least')) {
      return 'A senha deve ter pelo menos 6 caracteres';
    } else if (error.contains('email signups are disabled')) {
      return 'Cadastro por email desabilitado';
    } else if (error.contains('email logins are disabled')) {
      return 'Login por email desabilitado';
    } else if (error.contains('email not confirmed')) {
      return 'Email não confirmado';
    } else {
      return 'Erro: $error';
    }
  }
}