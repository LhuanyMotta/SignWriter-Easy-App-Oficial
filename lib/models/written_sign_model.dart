import 'dart:convert';
import 'dart:typed_data';

import 'signmaker_result.dart';

/// Modelo local para sinais autorais criados pelo usuário.
class WrittenSignModel {
  static const String statusDraft = 'draft';
  static const String statusPublished = 'published';
  static const String statusArchived = 'archived';

  final String id;
  final String userId;
  final String title;
  final String glossPt;
  final String? description;
  final String category;
  final List<String> tags;
  final String fsw;
  final String swu;
  final String layoutJson;

  /// Cache visual PNG (Base64, sem prefixo data:). FSW continua canônico.
  final String? previewPngBase64;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;

  const WrittenSignModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.glossPt,
    this.description,
    required this.category,
    this.tags = const [],
    this.fsw = '',
    this.swu = '',
    this.layoutJson = '[]',
    this.previewPngBase64,
    this.status = statusDraft,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
  });

  bool get isDraft => status == statusDraft;
  bool get isPublished => status == statusPublished;
  bool get hasSignWriting => fsw.trim().isNotEmpty && !fsw.startsWith('SW-MVP:');

  Uint8List? get previewPngBytes =>
      SignMakerResult.decodePngBase64(previewPngBase64);

  factory WrittenSignModel.fromMap(Map<String, dynamic> map) {
    final pngRaw = map['preview_png_base64'] ?? map['preview_svg'];
    return WrittenSignModel(
      id: map['id'] as String,
      userId: (map['user_id'] ?? 'local_user') as String,
      title: map['title'] as String,
      glossPt: map['gloss_pt'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      tags: _parseTags(map['tags']),
      fsw: (map['fsw'] ?? '') as String,
      swu: (map['swu'] ?? '') as String,
      layoutJson: (map['layout_json'] ?? '[]') as String,
      previewPngBase64: SignMakerResult.normalizePngBase64(
        pngRaw?.toString(),
      ),
      status: (map['status'] ?? statusDraft) as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      publishedAt: map['published_at'] != null
          ? DateTime.parse(map['published_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'gloss_pt': glossPt,
      'description': description,
      'category': category,
      'tags': json.encode(tags),
      'fsw': fsw,
      'swu': swu,
      'layout_json': layoutJson,
      'preview_png_base64': previewPngBase64,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
    };
  }

  WrittenSignModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? glossPt,
    String? description,
    String? category,
    List<String>? tags,
    String? fsw,
    String? swu,
    String? layoutJson,
    String? previewPngBase64,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
  }) {
    return WrittenSignModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      glossPt: glossPt ?? this.glossPt,
      description: description ?? this.description,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      fsw: fsw ?? this.fsw,
      swu: swu ?? this.swu,
      layoutJson: layoutJson ?? this.layoutJson,
      previewPngBase64: previewPngBase64 ?? this.previewPngBase64,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  static List<String> _parseTags(dynamic value) {
    if (value == null) return const [];
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
        return value
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
    }
    return const [];
  }
}
