import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sign_model.dart';
import '../models/translation_model.dart';

class TranslateViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isTranslating = false;
  String? _errorMessage;
  List<SignModel> _signs = [];
  List<String> _notFoundWords = [];
  TranslationModel? _lastTranslation;
  final List<TranslationModel> _recentTranslations = [];

  bool get isTranslating => _isTranslating;
  String? get errorMessage => _errorMessage;
  List<SignModel> get signs => _signs;
  List<String> get notFoundWords => _notFoundWords;
  TranslationModel? get lastTranslation => _lastTranslation;
  List<TranslationModel> get recentTranslations => _recentTranslations;

  Future<void> loadRecentTranslations() async {
    notifyListeners();
  }

  Future<void> translate(String text) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty) return;

    _isTranslating = true;
    _errorMessage = null;
    _signs = [];
    _notFoundWords = [];
    notifyListeners();

    try {
      final words = cleanText
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .map((word) => word.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), ''))
          .where((word) => word.isNotEmpty)
          .toSet()
          .toList();

      final foundSigns = <SignModel>[];
      final notFound = <String>[];

      for (final word in words) {
        final response = await _supabase
            .from('signs_dictionary')
            .select()
            .or('title.ilike.%$word%,name.ilike.%$word%,description.ilike.%$word%')
            .limit(1);

        if (response.isNotEmpty) {
          foundSigns.add(SignModel.fromMap(response.first));
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

      _recentTranslations.insert(0, _lastTranslation!);

      if (_recentTranslations.length > 5) {
        _recentTranslations.removeLast();
      }
    } catch (e) {
      _errorMessage = 'Translation error: $e';
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  void clear() {
    _signs = [];
    _notFoundWords = [];
    _lastTranslation = null;
    _errorMessage = null;
    notifyListeners();
  }
}
