import 'package:flutter/foundation.dart'
    show ChangeNotifier, debugPrint, defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/email_validator.dart';

/// Tipo de erro de autenticação — usado pela View para exibir a string localizada
enum AuthErrorType {
  invalidCredentials,
  emailExists,
  invalidEmail,
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
  static const String _oauthRedirectUrl = 'signwriterfacil://login-callback/';

  /// Na Web não existe esquema de URI customizado (signwriterfacil://) —
  /// o navegador precisa voltar pra uma URL http(s) real, que tem que estar
  /// cadastrada em Supabase Dashboard > Authentication > URL Configuration
  /// > Redirect URLs. Em mobile, mantém o esquema customizado de sempre.
  String get _resolvedRedirectUrl =>
      kIsWeb ? Uri.base.origin : _oauthRedirectUrl;

  bool _isLoading = false;
  bool _requiresEmailConfirmation = false;
  bool _waitingForOtp = false;
  String? _pendingVerificationEmail;
  String? _pendingOtpSessionId;
  String? _error;
  AuthErrorType? _errorType;

  AuthViewModel(this._supabase);

  bool get isLoading => _isLoading;
  bool get requiresEmailConfirmation => _requiresEmailConfirmation;
  bool get waitingForOtp => _waitingForOtp;
  String? get pendingVerificationEmail => _pendingVerificationEmail;
  String? get error => _error;
  AuthErrorType? get errorType => _errorType;

  void setEmailConfirmationState({
    required bool requiresEmailConfirmation,
    String? pendingVerificationEmail,
  }) {
    _requiresEmailConfirmation = requiresEmailConfirmation;
    if (requiresEmailConfirmation) {
      _pendingVerificationEmail = pendingVerificationEmail;
    } else {
      _pendingVerificationEmail = null;
    }
    notifyListeners();
  }

  void resetEmailConfirmation() {
    _requiresEmailConfirmation = false;
    _pendingVerificationEmail = null;
    _error = null;
    _errorType = null;
    notifyListeners();
  }

  // ---------- SIGN IN ----------
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    // Validar email ANTES de chamar Supabase
    if (!EmailValidator.isValid(email)) {
      _errorType = AuthErrorType.invalidEmail;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }

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

    if (!EmailValidator.isValid(email)) {
      _errorType = AuthErrorType.invalidEmail;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      debugPrint('SIGNUP_START: email=${email.trim()}, name=$name');

      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: _resolvedRedirectUrl,
        data: {
          'name': name.trim(),
        },
      );

      debugPrint('SIGNUP_RESPONSE: user=${response.user?.id}, session=${response.session != null}');

      _pendingVerificationEmail = email.trim();
      _pendingOtpSessionId = null;
      _waitingForOtp = false;
      _requiresEmailConfirmation = response.session == null;
      _errorType = response.session == null ? AuthErrorType.emailNotConfirmed : null;
      _error = null;
      _isLoading = false;
      notifyListeners();

      return response.session != null;
    } on AuthException catch (e) {
      debugPrint('SIGNUP_AUTH_EXCEPTION: ${e.message}');
      _setError(e.message);
      return false;
    } catch (e) {
      debugPrint('SIGNUP_UNKNOWN_EXCEPTION: $e');
      _setError('$e');
      return false;
    }
  }

  /// Verifica o OTP enviado por email
  Future<bool> verifyOtp({
    required String otp,
  }) async {
    _setLoading(true);

    if (_pendingVerificationEmail == null || _pendingOtpSessionId == null) {
      _setError('Sessão OTP expirada. Tente fazer signup novamente.');
      return false;
    }

    try {
      debugPrint('VERIFYING_OTP: email=$_pendingVerificationEmail');

      final response = await _supabase.auth.verifyOTP(
        email: _pendingVerificationEmail!,
        token: otp,
        type: OtpType.signup,
      );

      debugPrint('OTP_VERIFIED: user=${response.user?.id}');

      // OTP confirmado, usuário autenticado
      _pendingVerificationEmail = null;
      _pendingOtpSessionId = null;
      _waitingForOtp = false;
      _requiresEmailConfirmation = false;
      _error = null;
      _errorType = null;
      _isLoading = false;
      notifyListeners();

      return true;
    } on AuthException catch (e) {
      debugPrint('OTP_VERIFICATION_FAILED: ${e.message}');
      _setError(e.message);
      return false;
    } catch (e) {
      debugPrint('OTP_UNKNOWN_EXCEPTION: $e');
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
        redirectTo: _resolvedRedirectUrl,
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
        redirectTo: _resolvedRedirectUrl,
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
    _error = rawError;
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
    } else if (e.contains('error sending confirmation email') ||
        e.contains('sending confirmation email')) {
      return AuthErrorType.unknown;
    } else if (e.contains('email not confirmed')) {
      return AuthErrorType.emailNotConfirmed;
    } else if (e.contains('unsupported provider') || e.contains('provider is not enabled')) {
      return AuthErrorType.oauthNotEnabled;
    }
    return AuthErrorType.unknown;
  }
}
