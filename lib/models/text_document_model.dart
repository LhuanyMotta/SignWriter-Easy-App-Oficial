import 'dart:convert';

/// Modelo para representar um documento de texto em sinais
class TextDocumentModel {
  final String id;
  final String title;
  final List<String> signIds;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFavorite;

  TextDocumentModel({
    required this.id,
    required this.title,
    required this.signIds,
    required this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
  });

  factory TextDocumentModel.fromMap(Map<String, dynamic> map) {
    return TextDocumentModel(
      id: map['id'],
      title: map['title'],
      signIds: _decodeList(map['sign_ids']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      isFavorite: (map['is_favorite'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'sign_ids': json.encode(signIds),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
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
