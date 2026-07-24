import 'dart:convert';

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
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

Locale get locale {
  switch (_language) {
    case 'English':
    case 'Inglês':
      return const Locale('en');

    case 'Português':
    default:
      return const Locale('pt');
  }
}

  final List<String> availableLanguages = [
    'Português',
    'English',
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
    _fontSize = (prefs.getDouble('font_size') ?? 1.0).clamp(0.8, 1.5);
    _contrastLevel =        (prefs.getDouble('contrast_level') ?? 1.0).clamp(0.8, 1.5);
    _spacing = (prefs.getDouble('spacing') ?? 1.0).clamp(0.8, 1.5);
    _language = prefs.getString('language') ?? 'Português';
    if (_language == 'Inglês') _language = 'English';
    if (_language == 'Espanhol') _language = 'Português';

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

  Future<void> toggleDarkMode(bool value) async {
    _themeMode = value ? AppThemeMode.dark : AppThemeMode.light;
    await _savePreferences();
    notifyListeners();
  }

  Future<void> updateFontSize(double value) async {
    _fontSize = value.clamp(0.8, 1.5);
    await _savePreferences();
    notifyListeners();
  }

  Future<void> updateContrast(double value) async {
    _contrastLevel = value.clamp(0.8, 1.5);
    await _savePreferences();
    notifyListeners();
  }

  Future<void> updateSpacing(double value) async {
    _spacing = value.clamp(0.8, 1.5);
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

      // Atualiza cache local — não recarrega do banco pra evitar que
      // _loadUserData sobrescreva os dados novos com os dados antigos do auth.
      if (_userData != null) {
        _userData = Map<String, dynamic>.from(_userData!);
        _userData!['name'] = name;
        _userData!['email'] = email;
        _userData!['bio'] = bio ?? '';
      }

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


  Future<bool> removeProfileImage() async {
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

      // Tenta deletar o arquivo do Storage usando múltiplas estratégias
      Future<void> tryDelete(String path) async {
        try {
          await _supabase.storage.from('avatars').remove([path]);
        } catch (_) {}
      }

      // Estratégia 1: usa o path guardado no cache durante o upload
      final cachedPath = _userData?['_storage_path'] as String?;
      if (cachedPath != null) {
        await tryDelete(cachedPath);
      }

      // Estratégia 2: extrai o path da URL salva no banco
      final avatarUrl = _userData?['avatar_url'] as String?;
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(avatarUrl);
          final segments = uri.pathSegments;
          final idx = segments.indexOf('avatars');
          if (idx >= 0 && idx < segments.length - 1) {
            final path = segments.sublist(idx + 1).join('/');
            await tryDelete(path);
          }
        } catch (_) {}
      }

      // Estratégia 3: tenta todas as extensões comuns com e sem pasta
      for (final ext in ['jpg', 'jpeg', 'png', 'webp']) {
        await tryDelete('profiles/${user.id}.$ext');
        await tryDelete('${user.id}.$ext');
      }

      // Limpa avatar_url no banco
      try {
        await _supabase.from('profiles').update({
          'avatar_url': null,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);
      } catch (_) {
        await _supabase.from('profiles').upsert({
          'id': user.id,
          'avatar_url': null,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      if (_userData != null) {
        _userData = Map<String, dynamic>.from(_userData!);
        _userData!['avatar_url'] = null;
        _userData!.remove('_storage_path');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao remover foto: $e';
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
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

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

      final bytes = await pickedImage.readAsBytes();
      final fileExt = pickedImage.path.contains('.')
          ? pickedImage.path.split('.').last.toLowerCase()
          : 'jpg';
      final filePath = 'profiles/${user.id}.$fileExt';

      // 1. Upload para o Storage
      await _supabase.storage.from('avatars').uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl =
          _supabase.storage.from('avatars').getPublicUrl(filePath);

      // 2. Salva avatar_url no banco — tenta update primeiro, depois upsert
      bool dbOk = false;
      String dbError = '';
      try {
        await _supabase.from('profiles').update({
          'avatar_url': imageUrl,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);
        dbOk = true;
      } catch (e1) {
        try {
          await _supabase.from('profiles').upsert({
            'id': user.id,
            'avatar_url': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          });
          dbOk = true;
        } catch (e2) {
          dbError = e2.toString();
        }
      }

      // 3. Atualiza cache local com a nova URL e o path para deleção futura
      if (_userData != null) {
        _userData = Map<String, dynamic>.from(_userData!);
        _userData!['avatar_url'] = imageUrl;
        _userData!['_storage_path'] = filePath; // guarda o path real
      }

      if (!dbOk) {
        _errorMessage = 'Foto enviada mas erro ao salvar no banco: $dbError';
      }

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