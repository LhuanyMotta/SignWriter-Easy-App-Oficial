import 'dart:convert';

/// Modelo para representar uma tradução de texto → sinais
class TranslationModel {
  final String id;
  final String sourceText;
  final List<String> signIds;
  final List<String> notFoundWords;
  final String? signWritingSequence;
  final DateTime createdAt;
  final bool isFavorite;

  TranslationModel({
    required this.id,
    required this.sourceText,
    required this.signIds,
    required this.notFoundWords,
    this.signWritingSequence,
    required this.createdAt,
    this.isFavorite = false,
  });

  factory TranslationModel.fromMap(Map<String, dynamic> map) {
    return TranslationModel(
      id: map['id'],
      sourceText: map['source_text'],
      signIds: _decodeList(map['sign_ids']),
      notFoundWords: _decodeList(map['not_found_words']),
      signWritingSequence: map['sign_writing_sequence'],
      createdAt: DateTime.parse(map['created_at']),
      isFavorite: (map['is_favorite'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source_text': sourceText,
      'sign_ids': json.encode(signIds),
      'not_found_words': json.encode(notFoundWords),
      'sign_writing_sequence': signWritingSequence,
      'created_at': createdAt.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  static List<String> _decodeList(dynamic value) {
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = json.decode(value);
        if (decoded is List) {
          return decoded.map((item) => item.toString()).toList();
        }
      } catch (_) {
        return const [];
      }
    }
    return const [];
  }
}
