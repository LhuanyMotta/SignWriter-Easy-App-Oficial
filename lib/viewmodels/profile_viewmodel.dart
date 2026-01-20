import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_viewmodel.dart';

/// ViewModel para a tela de Perfil do usuário
class ProfileViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel;
  
  // Configurações gerais
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  
  // Configurações de acessibilidade
  double _fontSize = 1.0;
  double _contrastLevel = 1.0;
  double _spacing = 1.0;
  
  // Getters
  Map<String, dynamic>? get userData => _authViewModel.currentUser;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkMode => _darkMode;
  double get fontSize => _fontSize;
  double get contrastLevel => _contrastLevel;
  double get spacing => _spacing;
  
  /// Lista de idiomas disponíveis
  final List<String> availableLanguages = [
    'Português',
    'Inglês',
    'Espanhol',
  ];
  
  String _language = 'Português';
  String get language => _language;
  
  ProfileViewModel({required AuthViewModel authViewModel}) : _authViewModel = authViewModel {
    _loadPreferences();
  }
  
  // Carrega preferências salvas
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _darkMode = prefs.getBool('darkMode') ?? false;
      
      // Validação e limites para valores de acessibilidade
      _fontSize = (prefs.getDouble('fontSize') ?? 1.0).clamp(0.8, 2.0);
      _contrastLevel = (prefs.getDouble('contrast') ?? 1.0).clamp(0.5, 2.0);
      _spacing = (prefs.getDouble('spacing') ?? 1.0).clamp(0.8, 2.0);
      
      _language = prefs.getString('language') ?? 'Português';
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar preferências: $e');
      // Valores padrão em caso de erro
      _fontSize = 1.0;
      _contrastLevel = 1.0;
      _spacing = 1.0;
    }
  }
  
  // Salva preferências
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setDouble('contrast', _contrastLevel);
    await prefs.setDouble('spacing', _spacing);
    await prefs.setString('language', _language);
  }
  
  /// Alterna estado das notificações
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    _savePreferences();
    notifyListeners();
  }
  
  /// Alterna tema escuro/claro
  void toggleDarkMode(bool value) {
    _darkMode = value;
    _savePreferences();
    notifyListeners();
  }
  
  /// Altera o idioma do aplicativo
  void setLanguage(String language) {
    if (availableLanguages.contains(language)) {
      _language = language;
      _savePreferences();
      notifyListeners();
    }
  }
  
  /// Atualiza informações de perfil
  Future<bool> updateProfile({required String name}) async {
    try {
      if (name.isEmpty || name.length < 2) {
        return false;
      }

      final currentUser = Map<String, dynamic>.from(userData ?? {});
      currentUser['name'] = name;
      
      // Atualiza o usuário no AuthViewModel
      await _authViewModel.updateUserData(currentUser);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar perfil: $e');
      return false;
    }
  }
  
  /// Efetua logout do usuário
  Future<void> logout(BuildContext context) async {
    try {
      final success = await _authViewModel.signOut();
      
      if (success && context.mounted) {
        // Limpa a pilha de navegação e vai para a tela de autenticação
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/auth',
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Erro ao fazer logout: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao fazer logout. Tente novamente.')),
        );
      }
    }
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
  
  // Atualiza tamanho da fonte
  Future<void> updateFontSize(double value) async {
    try {
      _fontSize = value.clamp(0.8, 2.0);
      await _savePreferences();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao atualizar tamanho da fonte: $e');
    }
  }
  
  // Atualiza nível de contraste
  Future<void> updateContrast(double value) async {
    try {
      _contrastLevel = value.clamp(0.5, 2.0);
      await _savePreferences();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao atualizar contraste: $e');
    }
  }
  
  // Atualiza espaçamento
  Future<void> updateSpacing(double value) async {
    try {
      _spacing = value.clamp(0.8, 2.0);
      await _savePreferences();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao atualizar espaçamento: $e');
    }
  }
} 