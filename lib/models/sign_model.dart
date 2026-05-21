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
      createdAt: DateTime.now(),
    );
  }

  /// Construtor a partir de um mapa (para uso futuro com banco de dados)
  factory SignModel.fromMap(Map<String, dynamic> map) {
  return SignModel(
    id: map['id'].toString(),
    name: map['title'] ?? map['name'] ?? 'Sem nome',
    description: map['description'],
    signImagePath: map['image_url'] ?? '',
    category: map['category'] ?? 'Sem categoria',
    createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    isFavorite: false,
  );
}

  /// Converte o modelo para um mapa (para uso futuro com banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'signImagePath': signImagePath,
      'videoPath': videoPath,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
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
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
} 