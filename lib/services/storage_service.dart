import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para gerenciar armazenamento de dados
/// Atualmente usa SharedPreferences, mas pode ser facilmente migrado para Supabase
class StorageService {
  static const String _userKey = 'user_data';
  static const String _authTokenKey = 'auth_token';
  
  /// Salva dados do usuário
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(userData));
  }
  
  /// Recupera dados do usuário
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return json.decode(userStr) as Map<String, dynamic>;
    }
    return null;
  }
  
  /// Salva token de autenticação
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }
  
  /// Recupera token de autenticação
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }
  
  /// Verifica se usuário está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null;
  }
  
  /// Limpa todos os dados armazenados
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Limpa apenas dados de sessão do usuário atual.
  /// Mantém registros temporários de usuários cadastrados.
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userKey);
  }
  
  /// Salva dados temporários de usuários cadastrados
  /// Isso será substituído pelo Supabase posteriormente
  Future<void> saveTemporaryUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temp_users', json.encode(users));
  }
  
  /// Recupera dados temporários de usuários cadastrados
  Future<List<Map<String, dynamic>>> getTemporaryUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersStr = prefs.getString('temp_users');
    if (usersStr != null) {
      final List<dynamic> decoded = json.decode(usersStr);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }
} 