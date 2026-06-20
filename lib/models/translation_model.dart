import 'dart:convert';

/// Modelo para representar uma tradução de texto → sinais ou sinais → texto
class TranslationModel {
  final String id;
  final String sourceText;
  final List<String> signIds;
  final List<String> notFoundWords;
  final String? signWritingSequence;
  final DateTime createdAt;
  final bool isFavorite;
  final String direction;

  TranslationModel({
    required this.id,
    required this.sourceText,
    required this.signIds,
    required this.notFoundWords,
    this.signWritingSequence,
    required this.createdAt,
    this.isFavorite = false,
    this.direction = 'text_to_libras',
  });

  factory TranslationModel.fromMap(Map<String, dynamic> map) {
    return TranslationModel(
      id: map['id'].toString(),
      sourceText: (map['source_text'] ?? '').toString(),
      signIds: _decodeList(map['sign_ids']),
      notFoundWords: _decodeList(map['not_found_words']),
      signWritingSequence: map['sign_writing_sequence']?.toString(),
      createdAt: map['created_at'] is String
          ? DateTime.tryParse(map['created_at']) ?? DateTime.now()
          : DateTime.now(),
      isFavorite: map['is_favorite'] == true || map['is_favorite'] == 1,
      direction: (map['direction'] ?? 'text_to_libras').toString(),
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
      'direction': direction,
    };
  }

  TranslationModel copyWith({
    String? id,
    String? sourceText,
    List<String>? signIds,
    List<String>? notFoundWords,
    String? signWritingSequence,
    DateTime? createdAt,
    bool? isFavorite,
    String? direction,
  }) {
    return TranslationModel(
      id: id ?? this.id,
      sourceText: sourceText ?? this.sourceText,
      signIds: signIds ?? this.signIds,
      notFoundWords: notFoundWords ?? this.notFoundWords,
      signWritingSequence: signWritingSequence ?? this.signWritingSequence,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      direction: direction ?? this.direction,
    );
  }

  // Aceita JSONB (List já decodificada pelo supabase_flutter) ou String JSON.
  static List<String> _decodeList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
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
