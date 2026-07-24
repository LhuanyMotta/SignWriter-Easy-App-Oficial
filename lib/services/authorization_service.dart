import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Consulta papéis do usuário. Em debug, permite override local.
class AuthorizationService {
  AuthorizationService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  static const _mockAuthorKey = 'mock_can_edit_learning_content';

  /// Allowlist de e-mails author em debug (enquanto `user_roles` não existir).
  static const debugAuthorEmails = <String>{
    // Adicione e-mails de teste aqui se necessário.
  };

  Future<bool> canEditLearningContent() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_mockAuthorKey) == true) return true;

    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final email = user.email?.toLowerCase();
    if (kDebugMode &&
        email != null &&
        debugAuthorEmails.contains(email)) {
      return true;
    }

    try {
      final rows = await _supabase
          .from('user_roles')
          .select('role')
          .eq('user_id', user.id);

      for (final row in rows) {
        final role = row['role']?.toString();
        if (role == 'author' || role == 'admin' || role == 'reviewer') {
          return true;
        }
      }
    } catch (_) {
      // Tabela ainda não existe — em debug permite testar a gestão.
      if (kDebugMode) return true;
    }

    // Enquanto o banco não tiver papéis, debug + logado libera a UI de gestão.
    if (kDebugMode) return true;

    return false;
  }

  /// Ativa/desativa modo author local (útil para testar o Estúdio).
  Future<void> setMockAuthorEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mockAuthorKey, enabled);
  }

  Future<bool> isMockAuthorEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_mockAuthorKey) ?? false;
  }
}
