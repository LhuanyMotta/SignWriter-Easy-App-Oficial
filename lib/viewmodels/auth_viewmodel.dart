import 'package:flutter/foundation.dart'
    show ChangeNotifier, defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tipo de erro de autenticação — usado pela View para exibir a string localizada
enum AuthErrorType {
  invalidCredentials,
  emailExists,
  weakPassword,
  emailSignupsDisabled,
  emailLoginsDisabled,
  emailNotConfirmed,
  oauthNotEnabled,
  createAccount,
  unknown,
}

class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _supabase;
  static const String _oauthRedirectUrl = 'signwriterfacil://login-callback';

  bool _isLoading = false;
  String? _error;
  AuthErrorType? _errorType;

  AuthViewModel(this._supabase);

  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthErrorType? get errorType => _errorType;

  // ---------- SIGN IN ----------
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('$e');
      return false;
    }
  }

  // ---------- SIGN UP ----------
  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final res = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name},
      );

      if (res.user != null) {
        // Tenta criar perfil (ignora erro se já existir)
        try {
          await _supabase.from('profiles').insert({
            'id': res.user!.id,
            'name': name,
            'email': email,
            'level': 'Beginner',
          });
        } catch (_) {}

        _setLoading(false);
        return true;
      } else {
        _errorType = AuthErrorType.createAccount;
        _error = null;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('$e');
      return false;
    }
  }

  // ---------- LOGOUT ----------
  Future<bool> signOut() async {
    try {
      await _supabase.auth.signOut();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---------- GOOGLE ----------
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      final launchMode = !kIsWeb &&
              defaultTargetPlatform == TargetPlatform.android
          ? LaunchMode.externalApplication
          : LaunchMode.platformDefault;

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _oauthRedirectUrl,
        authScreenLaunchMode: launchMode,
        queryParams: {
          'prompt': 'select_account', // sempre mostra tela de seleção de conta
        },
      );
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('$e');
      return false;
    }
  }

  // ---------- APPLE ----------
  Future<bool> signInWithApple() async {
    _setLoading(true);
    try {
      final launchMode = !kIsWeb &&
              defaultTargetPlatform == TargetPlatform.android
          ? LaunchMode.externalApplication
          : LaunchMode.platformDefault;

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: _oauthRedirectUrl,
        authScreenLaunchMode: launchMode,
      );
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('$e');
      return false;
    }
  }

  // ---------- HELPERS ----------
  void _setLoading(bool value) {
    _isLoading = value;
    if (value) {
      _error = null;
      _errorType = null;
    }
    notifyListeners();
  }

  void _setError(String rawError) {
    _errorType = _classifyError(rawError);
    _error = null; // a View usa errorType para pegar a string localizada
    _isLoading = false;
    notifyListeners();
  }

  AuthErrorType _classifyError(String error) {
    final e = error.toLowerCase();
    if (e.contains('invalid login credentials') || e.contains('invalid email or password')) {
      return AuthErrorType.invalidCredentials;
    } else if (e.contains('user already registered') || e.contains('already exists')) {
      return AuthErrorType.emailExists;
    } else if (e.contains('password should be at least') || e.contains('weak password')) {
      return AuthErrorType.weakPassword;
    } else if (e.contains('email signups are disabled')) {
      return AuthErrorType.emailSignupsDisabled;
    } else if (e.contains('email logins are disabled')) {
      return AuthErrorType.emailLoginsDisabled;
    } else if (e.contains('email not confirmed')) {
      return AuthErrorType.emailNotConfirmed;
    } else if (e.contains('unsupported provider') || e.contains('provider is not enabled')) {
      return AuthErrorType.oauthNotEnabled;
    }
    return AuthErrorType.unknown;
  }
}
