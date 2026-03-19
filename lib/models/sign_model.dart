import 'dart:convert';

/// Modelo para representar um sinal na linguagem de sinais
class SignModel {
  /// Identificador único do sinal
  final String id;
  
  /// Nome do sinal em português
  final String name;
  
  /// Descrição do sinal
  final String? description;
  
  /// Caminho para imagem que representa o sinal em SignWriting
  final String signImagePath;
  
  /// Caminho para um vídeo demonstrando o sinal (opcional)
  final String? videoPath;
  
  /// Categoria do sinal
  final String category;
  
  /// Tags para busca e classificação
  final List<String> tags;

  /// Código SignWriting (opcional)
  final String? signWritingCode;

  /// Texto em português correspondente (opcional)
  final String? portugueseText;

  /// Data de criação do sinal
  final DateTime createdAt;
  
  /// Se o sinal é um favorito do usuário
  bool isFavorite;

  /// Construtor
  SignModel({
    required this.id,
    required this.name,
    this.description,
    required this.signImagePath,
    this.videoPath,
    required this.category,
    this.tags = const [],
    this.signWritingCode,
    this.portugueseText,
    required this.createdAt,
    this.isFavorite = false,
  });
  
  /// Construtor para criar instâncias de teste sem necessidade de assets
  factory SignModel.demo({
    required String id,
    required String name,
    String? description,
    required String category,
    bool isFavorite = false,
  }) {
    return SignModel(
      id: '0',
      name: 'Exemplo',
      description: 'Sinal de exemplo',
      signImagePath: 'assets/images/signwriter_logo.png', // Usa imagem padrão
      category: 'Outros',
      tags: const [],
      signWritingCode: null,
      portugueseText: 'exemplo',
      createdAt: DateTime.now(),
    );
  }

  /// Construtor a partir de um mapa (para uso futuro com banco de dados)
  factory SignModel.fromMap(Map<String, dynamic> map) {
    return SignModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      signImagePath: map['sign_image_path'] ?? map['signImagePath'],
      videoPath: map['video_path'] ?? map['videoPath'],
      category: map['category'],
      tags: _parseTags(map['tags']),
      signWritingCode: map['sign_writing_code'] ?? map['signWritingCode'],
      portugueseText: map['portuguese_text'] ?? map['portugueseText'],
      createdAt: DateTime.parse(map['created_at'] ?? map['createdAt']),
      isFavorite: (map['is_favorite'] ?? map['isFavorite'] ?? 0) == 1,
    );
  }

  /// Converte o modelo para um mapa (para uso futuro com banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sign_image_path': signImagePath,
      'video_path': videoPath,
      'category': category,
      'tags': json.encode(tags),
      'sign_writing_code': signWritingCode,
      'portuguese_text': portugueseText,
      'created_at': createdAt.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  /// Cria uma cópia do modelo com algumas propriedades modificadas
  SignModel copyWith({
    String? id,
    String? name,
    String? description,
    String? signImagePath,
    String? videoPath,
    String? category,
    List<String>? tags,
    String? signWritingCode,
    String? portugueseText,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return SignModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      signImagePath: signImagePath ?? this.signImagePath,
      videoPath: videoPath ?? this.videoPath,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      signWritingCode: signWritingCode ?? this.signWritingCode,
      portugueseText: portugueseText ?? this.portugueseText,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Aceita lista pronta ou JSON string; fallback para lista vazia.
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
        // Ignora erro de parse e retorna lista vazia.
      }
    }
    return const [];
  }
} 