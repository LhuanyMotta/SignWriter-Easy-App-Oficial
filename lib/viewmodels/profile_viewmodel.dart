import 'package:flutter/material.dart';

/// ViewModel para a tela de Perfil do usuário
class ProfileViewModel extends ChangeNotifier {
  // Dados do perfil do usuário
  final Map<String, dynamic> _userData = {
    'nome': 'Maria Silva',
    'email': 'maria.silva@email.com',
    'foto': null, // Será implementado posteriormente
    'nivel': 'Intermediário',
    'dataCadastro': '10/01/2023',
    'notificacoes': true,
    'temaEscuro': false,
    'idioma': 'Português',
  };
  
  // Configurações do usuário
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _language = 'Português';
  
  // Getters
  Map<String, dynamic> get userData => _userData;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkMode => _darkMode;
  String get language => _language;
  
  /// Lista de idiomas disponíveis
  final List<String> availableLanguages = [
    'Português',
    'Inglês',
    'Espanhol',
    'Libras',
  ];
  
  /// Alterna estado das notificações
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    _userData['notificacoes'] = value;
    notifyListeners();
  }
  
  /// Alterna tema escuro/claro
  void toggleDarkMode(bool value) {
    _darkMode = value;
    _userData['temaEscuro'] = value;
    notifyListeners();
  }
  
  /// Altera o idioma do aplicativo
  void setLanguage(String language) {
    if (availableLanguages.contains(language)) {
      _language = language;
      _userData['idioma'] = language;
      notifyListeners();
    }
  }
  
  /// Atualiza informações de perfil
  void updateProfile({
    required String name,
    required String email,
  }) {
    _userData['nome'] = name;
    _userData['email'] = email;
    notifyListeners();
  }
  
  /// Efetua logout do usuário
  Future<void> logout() async {
    // Implementação futura para logout:
    // - Limpar dados da sessão
    // - Redirecionar para tela de login
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  /// Exporta dados do usuário
  void exportUserData(BuildContext context) {
    // Implementação futura
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exportação de dados será implementada em breve')),
    );
  }
  
  /// Deleta conta do usuário
  Future<bool> deleteAccount() async {
    // Implementação futura
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
} 