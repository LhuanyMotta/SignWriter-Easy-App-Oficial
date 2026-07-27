import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Consulta papéis do usuário. `user_roles` é a única fonte de autorização editorial.
class AuthorizationService {
  AuthorizationService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  static const _mockAuthorKey = 'mock_can_edit_learning_content';

  /// Preferência legada (não libera UI nem escrita). Mantida só para limpeza/compat.
  Future<bool> isLocalAuthorUiEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_mockAuthorKey) ?? false;
  }

  Future<void> setLocalAuthorUiEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mockAuthorKey, enabled);
  }

  /// Apaga override local antigo que podia mostrar botões sem role no banco.
  Future<void> clearLocalAuthorUiOverride() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_mockAuthorKey);
  }

  /// Ferramentas editoriais na UI: só com papel real em `user_roles`.
  /// Escrita no Supabase continua sujeita a RLS + o mesmo papel.
  Future<bool> canEditLearningContent() async {
    return hasEditorialRole();
  }

  /// Papel editorial real no banco (`author` | `reviewer` | `admin`).
  Future<bool> hasEditorialRole() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

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
      return false;
    } on PostgrestException catch (error) {
      // Erro RLS/autorização — não libera edição.
      if (error.code == '42501') return false;
      rethrow;
    }
  }

  /// @deprecated Use [setLocalAuthorUiEnabled].
  Future<void> setMockAuthorEnabled(bool enabled) =>
      setLocalAuthorUiEnabled(enabled);

  /// @deprecated Use [isLocalAuthorUiEnabled].
  Future<bool> isMockAuthorEnabled() => isLocalAuthorUiEnabled();
}
