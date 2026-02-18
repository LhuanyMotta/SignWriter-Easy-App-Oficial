import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  double _fontSize = 1.0;
  double _contrastLevel = 1.0;
  double _spacing = 1.0;
  String _language = 'Português';
  Map<String, dynamic>? _userData;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkMode => _darkMode;
  double get fontSize => _fontSize;
  double get contrastLevel => _contrastLevel;
  double get spacing => _spacing;
  String get language => _language;
  
  final List<String> availableLanguages = [
    'Português',
    'Inglês',
    'Espanhol',
  ];
  
  ProfileViewModel() {
    _loadUserData();
    _loadPreferences();
  }
  
  Future<void> _loadUserData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final response = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        
        if (response != null) {
          _userData = Map<String, dynamic>.from(response);
        }
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar dados: $e';
      notifyListeners();
    }
  }
  
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _darkMode = prefs.getBool('darkMode') ?? false;
      _fontSize = (prefs.getDouble('fontSize') ?? 1.0).clamp(0.8, 2.0);
      _contrastLevel = (prefs.getDouble('contrast') ?? 1.0).clamp(0.5, 2.0);
      _spacing = (prefs.getDouble('spacing') ?? 1.0).clamp(0.8, 2.0);
      _language = prefs.getString('language') ?? 'Português';
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar preferências: $e');
    }
  }
  
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setDouble('contrast', _contrastLevel);
    await prefs.setDouble('spacing', _spacing);
    await prefs.setString('language', _language);
  }
  
  Future<bool> updateProfile({
    required String name,
    required String email,
    String? bio,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _errorMessage = 'Usuário não autenticado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Atualiza dados no perfil
      await _supabase.from('profiles').update({
        'name': name,
        'email': email,
        'bio': bio ?? '',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      // Recarrega dados
      await _loadUserData();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar perfil: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    _savePreferences();
    notifyListeners();
  }
  
  void toggleDarkMode(bool value) {
    _darkMode = value;
    _savePreferences();
    notifyListeners();
  }
  
  void setLanguage(String language) {
    if (availableLanguages.contains(language)) {
      _language = language;
      _savePreferences();
      notifyListeners();
    }
  }
  
  Future<void> updateFontSize(double value) async {
    _fontSize = value.clamp(0.8, 2.0);
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> updateContrast(double value) async {
    _contrastLevel = value.clamp(0.5, 2.0);
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> updateSpacing(double value) async {
    _spacing = value.clamp(0.8, 2.0);
    await _savePreferences();
    notifyListeners();
  }
  
  Future<bool> logout() async {
    try {
      await _supabase.auth.signOut();
      _userData = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao fazer logout: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Método para exportar dados do usuário
  Future<String> exportUserData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Busca dados do usuário
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      // Busca dados adicionais (futuramente)
      final dataToExport = {
        'profile': profileData,
        'exported_at': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
      };

      // Converte para JSON formatado
      final jsonString = JsonEncoder.withIndent('  ').convert(dataToExport);
      return jsonString;
    } catch (e) {
      throw Exception('Erro ao exportar dados: $e');
    }
  }
  
  // Método para excluir conta do usuário
  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _errorMessage = 'Usuário não autenticado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Primeiro, exclui os dados do perfil
      await _supabase.from('profiles').delete().eq('id', user.id);
      
      // Depois, exclui a conta de autenticação
      await _supabase.auth.admin.deleteUser(user.id);
      
      _userData = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao excluir conta: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}