import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_viewmodel.dart';
import 'app_settings_viewmodel.dart';

/// ViewModel para a tela de Perfil do usuário
class ProfileViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel;
  final AppSettingsViewModel _appSettingsViewModel;
  
  // Configurações gerais
  bool _notificationsEnabled = true;
  
  // Getters
  Map<String, dynamic>? get userData => _authViewModel.currentUser;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkMode => _appSettingsViewModel.isDarkMode;
  double get fontSize => _appSettingsViewModel.fontScale;
  double get contrastLevel => _appSettingsViewModel.contrastLevel;
  double get spacing => _appSettingsViewModel.spacingScale;
  
  /// Lista de idiomas disponíveis
  final List<String> availableLanguages = [
    'pt',
    'en',
  ];
  
  String get language => _appSettingsViewModel.locale.languageCode;
  
  ProfileViewModel({
    required AuthViewModel authViewModel,
    required AppSettingsViewModel appSettingsViewModel,
  })  : _authViewModel = authViewModel,
        _appSettingsViewModel = appSettingsViewModel {
    _appSettingsViewModel.addListener(_onAppSettingsChanged);
    _loadPreferences();
  }

  void _onAppSettingsChanged() => notifyListeners();
  
  // Carrega preferências salvas
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar preferências: $e');
    }
  }
  
  // Salva preferências
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notificationsEnabled);
  }
  
  /// Alterna estado das notificações
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    _savePreferences();
    notifyListeners();
  }
  
  /// Alterna tema escuro/claro
  void toggleDarkMode(bool value) {
    _appSettingsViewModel.toggleDarkMode(value);
  }
  
  /// Altera o idioma do aplicativo
  void setLanguage(String language) {
    if (availableLanguages.contains(language)) {
      _appSettingsViewModel.setLocale(Locale(language));
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
      await _appSettingsViewModel.updateFontScale(value);
    } catch (e) {
      debugPrint('Erro ao atualizar tamanho da fonte: $e');
    }
  }
  
  // Atualiza nível de contraste
  Future<void> updateContrast(double value) async {
    try {
      await _appSettingsViewModel.updateContrastLevel(value);
    } catch (e) {
      debugPrint('Erro ao atualizar contraste: $e');
    }
  }
  
  // Atualiza espaçamento
  Future<void> updateSpacing(double value) async {
    try {
      await _appSettingsViewModel.updateSpacingScale(value);
    } catch (e) {
      debugPrint('Erro ao atualizar espaçamento: $e');
    }
  }

  @override
  void dispose() {
    _appSettingsViewModel.removeListener(_onAppSettingsChanged);
    super.dispose();
  }
} 