import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sign_model.dart';
import '../models/translation_model.dart';

class TranslateViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isTranslating = false;
  bool _isLoadingHistory = false;
  String? _errorMessage;

  List<SignModel> _signs = [];
  List<String> _notFoundWords = [];
  TranslationModel? _lastTranslation;
  List<TranslationModel> _recentTranslations = [];

  // Aba Libras → Texto
  File? _capturedImage;
  String? _recognizedText;

  // Ditado por voz
  bool _speechAvailable = false;
  bool _isListening = false;
  String _partialSpeechText = '';

  bool get isTranslating => _isTranslating;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get errorMessage => _errorMessage;
  List<SignModel> get signs => _signs;
  List<String> get notFoundWords => _notFoundWords;
  TranslationModel? get lastTranslation => _lastTranslation;
  List<TranslationModel> get recentTranslations => _recentTranslations;
  File? get capturedImage => _capturedImage;
  String? get recognizedText => _recognizedText;
  bool get isListening => _isListening;
  String get partialSpeechText => _partialSpeechText;

  // ─────────────────────────────────────────────────────────────
  // DITADO POR VOZ — converte fala em texto localmente, sem salvar
  // o áudio; apenas o texto resultante segue para a tradução normal.
  // ─────────────────────────────────────────────────────────────
  Future<bool> _ensureSpeechReady() async {
    if (_speechAvailable) return true;
    try {
      _speechAvailable = await _speech.initialize(
        onError: (error) {
          _isListening = false;
          _errorMessage = 'Não foi possível reconhecer a fala. Verifique a permissão do microfone.';
          notifyListeners();
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
      );
    } catch (_) {
      _speechAvailable = false;
    }
    return _speechAvailable;
  }

  /// Inicia o ditado. [onResult] recebe o texto reconhecido em tempo real
  /// para que a tela possa exibi-lo no campo de busca enquanto o usuário fala.
  Future<void> startListening({
    required void Function(String text) onResult,
    String localeId = 'pt_BR',
  }) async {
    final ready = await _ensureSpeechReady();
    if (!ready) {
      _errorMessage = 'Reconhecimento de voz indisponível neste dispositivo.';
      notifyListeners();
      return;
    }

    _errorMessage = null;
    _isListening = true;
    _partialSpeechText = '';
    notifyListeners();

    await _speech.listen(
      localeId: localeId,
      onResult: (result) {
        _partialSpeechText = result.recognizedWords;
        onResult(_partialSpeechText);
        notifyListeners();
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      partialResults: true,
      cancelOnError: true,
    );
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    await _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  void cancelListening() {
    if (_isListening) {
      _speech.cancel();
      _isListening = false;
      _partialSpeechText = '';
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // HISTÓRICO — persistido no Supabase, por usuário autenticado
  // ─────────────────────────────────────────────────────────────
  Future<void> loadRecentTranslations() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _recentTranslations = [];
      notifyListeners();
      return;
    }

    _isLoadingHistory = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('translations')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(10);

      _recentTranslations = (response as List)
          .map((row) => TranslationModel.fromMap(row))
          .toList();
    } catch (e) {
      _recentTranslations = [];
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> _saveTranslation(TranslationModel translation, String direction) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final inserted = await _supabase
          .from('translations')
          .insert({
            'user_id': user.id,
            'source_text': translation.sourceText,
            'direction': direction,
            'sign_ids': translation.signIds,
            'not_found_words': translation.notFoundWords,
            'sign_writing_sequence': translation.signWritingSequence,
          })
          .select()
          .single();

      final saved = TranslationModel.fromMap(inserted);
      _recentTranslations.insert(0, saved);
      if (_recentTranslations.length > 10) {
        _recentTranslations.removeLast();
      }
    } catch (_) {
      _recentTranslations.insert(0, translation);
      if (_recentTranslations.length > 10) {
        _recentTranslations.removeLast();
      }
    }
  }

  Future<void> toggleFavorite(TranslationModel translation) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final newValue = !translation.isFavorite;

    try {
      await _supabase
          .from('translations')
          .update({'is_favorite': newValue})
          .eq('id', translation.id);

      final index = _recentTranslations.indexWhere((t) => t.id == translation.id);
      if (index != -1) {
        _recentTranslations[index] = translation.copyWith(isFavorite: newValue);
        notifyListeners();
      }
    } catch (_) {
      // Ignora falha de rede ao favoritar; o estado local não muda.
    }
  }

  Future<void> deleteTranslation(TranslationModel translation) async {
    try {
      await _supabase.from('translations').delete().eq('id', translation.id);
    } catch (_) {
      // Mesmo que a exclusão remota falhe, removemos da lista local.
    }
    _recentTranslations.removeWhere((t) => t.id == translation.id);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // TEXTO → LIBRAS
  // ─────────────────────────────────────────────────────────────
  Future<void> translate(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    _isTranslating = true;
    _errorMessage = null;
    _signs = [];
    _notFoundWords = [];
    notifyListeners();

    try {
      final words = _extractWords(cleanText);
      final foundSigns = <SignModel>[];
      final notFound = <String>[];

      for (final word in words) {
        final normalized = _normalize(word);

        final response = await _supabase
            .from('signs_dictionary')
            .select()
            .or('title.ilike.%$word%,name.ilike.%$word%,description.ilike.%$word%')
            .limit(5);

        if (response.isNotEmpty) {
          final exact = (response as List).firstWhere(
            (row) {
              final title = _normalize((row['title'] ?? row['name'] ?? '').toString());
              return title == normalized;
            },
            orElse: () => response.first,
          );
          final sign = SignModel.fromMap(exact);
          if (!foundSigns.any((s) => s.id == sign.id)) {
            foundSigns.add(sign);
          }
        } else {
          notFound.add(word);
        }
      }

      _signs = foundSigns;
      _notFoundWords = notFound;

      _lastTranslation = TranslationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sourceText: cleanText,
        signIds: foundSigns.map((sign) => sign.id).toList(),
        notFoundWords: notFound,
        createdAt: DateTime.now(),
      );

      await _saveTranslation(_lastTranslation!, 'text_to_libras');
    } catch (e) {
      _errorMessage = 'Não foi possível traduzir agora. Verifique sua conexão e tente novamente.';
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LIBRAS → TEXTO (captura de imagem + busca por nome do sinal)
  // ─────────────────────────────────────────────────────────────
  Future<void> pickImageFromCamera() => _pickImage(ImageSource.camera);

  Future<void> pickImageFromGallery() => _pickImage(ImageSource.gallery);

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked == null) return;

      _capturedImage = File(picked.path);
      _recognizedText = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Não foi possível acessar a câmera ou galeria.';
      notifyListeners();
    }
  }

  Future<void> confirmRecognizedSign(String signName) async {
    final cleanName = signName.trim();
    if (cleanName.isEmpty) return;

    _isTranslating = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('signs_dictionary')
          .select()
          .or('title.ilike.%$cleanName%,name.ilike.%$cleanName%')
          .limit(1);

      if (response.isNotEmpty) {
        final sign = SignModel.fromMap(response.first);
        _recognizedText = sign.name;
        _signs = [sign];
        _notFoundWords = [];

        final translation = TranslationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sourceText: sign.name,
          signIds: [sign.id],
          notFoundWords: const [],
          createdAt: DateTime.now(),
        );
        await _saveTranslation(translation, 'libras_to_text');
      } else {
        _recognizedText = null;
        _errorMessage = 'Sinal não encontrado no dicionário. Tente outro nome.';
      }
    } catch (e) {
      _errorMessage = 'Erro ao buscar o sinal. Tente novamente.';
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  void clearCapturedImage() {
    _capturedImage = null;
    _recognizedText = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // UTILITÁRIOS
  // ─────────────────────────────────────────────────────────────
  List<String> _extractWords(String text) {
    return text
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .map((word) => word.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), ''))
        .where((word) => word.isNotEmpty)
        .toSet()
        .toList();
  }

  String _normalize(String input) {
    const withDiacritics = 'áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ';
    const withoutDiacritics = 'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN';

    var result = input.toLowerCase();
    for (var i = 0; i < withDiacritics.length; i++) {
      result = result.replaceAll(withDiacritics[i], withoutDiacritics[i].toLowerCase());
    }
    return result;
  }

  void clear() {
    _signs = [];
    _notFoundWords = [];
    _lastTranslation = null;
    _errorMessage = null;
    _capturedImage = null;
    _recognizedText = null;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_isListening) {
      _speech.stop();
    }
    super.dispose();
  }
}
