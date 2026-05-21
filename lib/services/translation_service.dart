import '../models/sign_model.dart';
import '../models/translation_model.dart';
import 'database_service.dart';

/// Serviço de tradução simples (sem ML)
class TranslationService {
  final DatabaseService _databaseService = DatabaseService();

  /// Traduz texto para sinais e retorna resultado com sinais encontrados
  Future<TranslationResult> translateTextToSigns(String text) async {
    final normalized = _normalizeText(text);
    final words = _tokenize(normalized);

    final List<SignModel> foundSigns = [];
    final List<String> notFoundWords = [];

    for (final word in words) {
      final sign = await _findBestSignForWord(word);
      if (sign != null) {
        foundSigns.add(sign);
      } else {
        notFoundWords.add(word);
      }
    }

    final signWritingSequence = _buildSignWritingSequence(foundSigns);

    final translation = TranslationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      sourceText: text,
      signIds: foundSigns.map((s) => s.id).toList(),
      notFoundWords: notFoundWords,
      signWritingSequence: signWritingSequence,
      createdAt: DateTime.now(),
    );

    await _databaseService.saveTranslation(translation.toMap());

    return TranslationResult(
      translation: translation,
      signs: foundSigns,
    );
  }

  /// Busca traduções recentes
  Future<List<TranslationModel>> getRecentTranslations({int limit = 10}) async {
    final maps = await _databaseService.getRecentTranslations(limit: limit);
    return maps.map((map) => TranslationModel.fromMap(map)).toList();
  }

  /// Alterna favorito de uma tradução
  Future<void> toggleFavorite(String translationId, bool isFavorite) async {
    await _databaseService.toggleTranslationFavorite(translationId, isFavorite);
  }

  Future<SignModel?> _findBestSignForWord(String word) async {
    if (word.isEmpty) return null;

    // 1) Busca exata pelo nome
    final exactByName = await _findExactByName(word);
    if (exactByName != null) return exactByName;

    // 2) Busca por tag
    final byTag = await _findByTag(word);
    if (byTag != null) return byTag;

    // 3) Busca geral (parcial)
    final results = await _databaseService.searchSigns(word);
    if (results.isNotEmpty) return results.first;

    return null;
  }

  Future<SignModel?> _findExactByName(String word) async {
    final results = await _databaseService.searchSigns(word);
    for (final sign in results) {
      if (_normalizeText(sign.name) == word) {
        return sign;
      }
    }
    return null;
  }

  Future<SignModel?> _findByTag(String word) async {
    final results = await _databaseService.getSignsByTag(word);
    return results.isNotEmpty ? results.first : null;
  }

  String _normalizeText(String text) {
    final lower = text.toLowerCase().trim();
    return lower
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^\w\s]'), '');
  }

  List<String> _tokenize(String text) {
    return text.split(' ').where((word) => word.isNotEmpty).toList();
  }

  String? _buildSignWritingSequence(List<SignModel> signs) {
    final codes = signs
        .map((s) => s.signWritingCode)
        .where((code) => code != null && code!.isNotEmpty)
        .map((code) => code!)
        .toList();
    return codes.isEmpty ? null : codes.join(' ');
  }
}

/// Resultado da tradução com sinais completos
class TranslationResult {
  final TranslationModel translation;
  final List<SignModel> signs;

  TranslationResult({
    required this.translation,
    required this.signs,
  });
}
