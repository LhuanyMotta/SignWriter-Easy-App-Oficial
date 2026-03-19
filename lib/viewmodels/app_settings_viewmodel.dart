import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsViewModel extends ChangeNotifier {
  // Chaves de persistência no SharedPreferences
  static const _themeModeKey = 'themeMode';
  static const _fontScaleKey = 'fontSize';
  static const _contrastLevelKey = 'contrast';
  static const _spacingScaleKey = 'spacing';
  static const _languageKey = 'language';

  // Chave que indica se o usuário já passou pela tela de configuração inicial
  static const _onboardingKey = 'accessibility_onboarding_done';

  ThemeMode _themeMode = ThemeMode.light;
  double _fontScale = 1.0;
  double _contrastLevel = 1.0;
  double _spacingScale = 1.0;
  Locale _locale = const Locale('pt');

  // Flag de controle do onboarding de acessibilidade; começa false até ser lida do disco
  bool _onboardingDone = false;

  ThemeMode get themeMode => _themeMode;
  double get fontScale => _fontScale;
  double get contrastLevel => _contrastLevel;
  double get spacingScale => _spacingScale;
  Locale get locale => _locale;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Retorna true quando o usuário já concluiu (ou pulou) a tela de acessibilidade inicial
  bool get accessibilityOnboardingDone => _onboardingDone;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    _themeMode = _fromThemeModeString(prefs.getString(_themeModeKey));
    _fontScale = (prefs.getDouble(_fontScaleKey) ?? 1.0).clamp(0.8, 2.0);
    _contrastLevel =
        (prefs.getDouble(_contrastLevelKey) ?? 1.0).clamp(1.0, 2.0);
    _spacingScale =
        (prefs.getDouble(_spacingScaleKey) ?? 1.0).clamp(0.8, 2.0);

    final savedLanguage = prefs.getString(_languageKey) ?? 'Português';
    _locale = _fromLanguageString(savedLanguage);

    // Carrega se o onboarding de acessibilidade já foi realizado anteriormente
    _onboardingDone = prefs.getBool(_onboardingKey) ?? false;

    notifyListeners();
  }

  /// Marca o onboarding como concluído e persiste a decisão.
  /// Deve ser chamado tanto ao confirmar quanto ao pular a tela inicial.
  Future<void> markOnboardingDone() async {
    _onboardingDone = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _saveString(_themeModeKey, _themeMode.name);
  }

  Future<void> toggleDarkMode(bool enabled) async {
    await setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> updateFontScale(double value) async {
    _fontScale = value.clamp(0.8, 2.0);
    notifyListeners();
    await _saveDouble(_fontScaleKey, _fontScale);
  }

  Future<void> updateContrastLevel(double value) async {
    _contrastLevel = value.clamp(1.0, 2.0);
    notifyListeners();
    await _saveDouble(_contrastLevelKey, _contrastLevel);
  }

  Future<void> updateSpacingScale(double value) async {
    _spacingScale = value.clamp(0.8, 2.0);
    notifyListeners();
    await _saveDouble(_spacingScaleKey, _spacingScale);
  }

  Future<void> setLocale(Locale value) async {
    _locale = value;
    notifyListeners();
    await _saveString(_languageKey, _toLegacyLanguageString(value));
  }

  ThemeMode _fromThemeModeString(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  Locale _fromLanguageString(String value) {
    switch (value) {
      case 'Inglês':
      case 'English':
      case 'en':
        return const Locale('en');
      case 'Português':
      case 'Portuguese':
      case 'pt':
      default:
        return const Locale('pt');
    }
  }

  String _toLegacyLanguageString(Locale locale) {
    return locale.languageCode == 'en' ? 'Inglês' : 'Português';
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }
}
