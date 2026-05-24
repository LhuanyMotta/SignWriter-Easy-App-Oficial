import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ProfileViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _errorMessage;

  bool _notificationsEnabled = true;
  AppThemeMode _themeMode = AppThemeMode.system;
  double _fontSize = 1.0;
  double _contrastLevel = 1.0;
  double _spacing = 1.0;
  String _language = 'Português';

  Map<String, dynamic>? _userData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;

 bool get notificationsEnabled => _notificationsEnabled;

AppThemeMode get themeMode => _themeMode;

bool get darkMode => _themeMode == AppThemeMode.dark;

ThemeMode get flutterThemeMode {
  switch (_themeMode) {
    case AppThemeMode.light:
      return ThemeMode.light;

    case AppThemeMode.dark:
      return ThemeMode.dark;

    case AppThemeMode.system:
      return ThemeMode.system;
  }
}

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
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await _loadPreferences();
    await _loadUserData();
  }

  Future<void> _loadUserData() async {
  try {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      _userData = null;
      notifyListeners();
      return;
    }

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      final newProfile = {
        'id': user.id,
        'name': user.userMetadata?['name'] ??
            user.email?.split('@').first ??
            'Usuário',
        'email': user.email ?? '',
        'bio': '',
        'avatar_url': user.userMetadata?['avatar_url'],
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('profiles').insert(newProfile);

      _userData = newProfile;
    } else {
      _userData = Map<String, dynamic>.from(response);
    }

    _errorMessage = null;
    notifyListeners();
  } catch (e) {
    final user = _supabase.auth.currentUser;

    _userData = {
      'id': user?.id ?? '',
      'name': user?.userMetadata?['name'] ??
          user?.email?.split('@').first ??
          'Usuário',
      'email': user?.email ?? '',
      'bio': '',
      'avatar_url': user?.userMetadata?['avatar_url'],
    };

    _errorMessage = 'Erro ao carregar dados: $e';
    notifyListeners();
  }
}

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    _notificationsEnabled =
        prefs.getBool('notifications_enabled') ?? true;
    final savedTheme = prefs.getString('theme_mode') ?? 'system';
    _themeMode = AppThemeMode.values.firstWhere(
      (e) => e.name == savedTheme,
      orElse: () => AppThemeMode.system,
      );
    _fontSize = (prefs.getDouble('font_size') ?? 1.0).clamp(0.8, 2.0);
    _contrastLevel =
        (prefs.getDouble('contrast_level') ?? 1.0).clamp(0.5, 2.0);
    _spacing = (prefs.getDouble('spacing') ?? 1.0).clamp(0.8, 2.0);
    _language = prefs.getString('language') ?? 'Português';

    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setString('theme_mode',_themeMode.name,);
    await prefs.setDouble('font_size', _fontSize);
    await prefs.setDouble('contrast_level', _contrastLevel);
    await prefs.setDouble('spacing', _spacing);
    await prefs.setString('language', _language);
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await _savePreferences();
    notifyListeners();
  }

Future<void> setThemeMode(
  AppThemeMode mode,
) async {
  _themeMode = mode;

  await _savePreferences();

  notifyListeners();
}

  Future<void> setLanguage(String value) async {
    if (!availableLanguages.contains(value)) return;

    _language = value;
    await _savePreferences();
    notifyListeners();
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

  Future<void> resetAccessibility() async {
    _fontSize = 1.0;
    _contrastLevel = 1.0;
    _spacing = 1.0;
    await _savePreferences();
    notifyListeners();
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

      await _supabase.from('profiles').update({
        'name': name,
        'email': email,
        'bio': bio ?? '',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

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

  Future<bool> uploadProfileImage({
    required ImageSource source,
  }) async {
    try {
      final picker = ImagePicker();

      final pickedImage = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedImage == null) return false;

      return await _uploadPickedImage(pickedImage);
    } catch (e) {
      _errorMessage = 'Erro ao selecionar imagem: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> recoverLostProfileImage() async {
    if (!Platform.isAndroid) return false;

    try {
      final picker = ImagePicker();
      final response = await picker.retrieveLostData();

      if (response.isEmpty) return false;

      if (response.exception != null) {
        _errorMessage = 'Erro ao recuperar imagem: ${response.exception}';
        notifyListeners();
        return false;
      }

      final file = response.file;
      if (file == null) return false;

      return await _uploadPickedImage(file);
    } catch (e) {
      _errorMessage = 'Erro ao recuperar imagem: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> _uploadPickedImage(XFile pickedImage) async {
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

      final file = File(pickedImage.path);
      final fileExt = pickedImage.path.split('.').last;
      final filePath = 'profiles/${user.id}.$fileExt';

      await _supabase.storage.from('avatars').upload(
            filePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl =
          _supabase.storage.from('avatars').getPublicUrl(filePath);

      await _supabase.from('profiles').update({
        'avatar_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      await _loadUserData();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao enviar imagem: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
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

  Future<String> exportUserData() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      final dataToExport = {
        'profile': profileData,
        'settings': {
          'notifications_enabled': _notificationsEnabled,
          'theme_mode': _themeMode.name,
          'font_size': _fontSize,
          'contrast_level': _contrastLevel,
          'spacing': _spacing,
          'language': _language,
        },
        'exported_at': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
      };

      return const JsonEncoder.withIndent('  ').convert(dataToExport);
    } catch (e) {
      throw Exception('Erro ao exportar dados: $e');
    }
  }

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

      await _supabase.from('profiles').delete().eq('id', user.id);
      await _supabase.auth.signOut();

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