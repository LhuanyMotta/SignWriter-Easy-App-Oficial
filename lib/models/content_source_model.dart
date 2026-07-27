class ContentSourceModel {
  final String id;
  final String title;
  final List<String> authors;
  final List<String> contributors;
  final List<String> translators;
  final String? publisher;
  final int? publicationYear;
  final String sourceUrl;
  final String licenseName;
  final String licenseUrl;
  final String attributionText;
  final String? notes;

  const ContentSourceModel({
    required this.id,
    required this.title,
    this.authors = const [],
    this.contributors = const [],
    this.translators = const [],
    this.publisher,
    this.publicationYear,
    this.sourceUrl = '',
    this.licenseName = '',
    this.licenseUrl = '',
    this.attributionText = '',
    this.notes,
  });

  factory ContentSourceModel.fromMap(
    Map<String, dynamic> map, {
    String lang = 'pt',
  }) {
    final isEn = lang.toLowerCase() == 'en';
    return ContentSourceModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      authors: _stringList(map['authors']),
      contributors: _stringList(map['contributors']),
      translators: _stringList(map['translators']),
      publisher: map['publisher']?.toString(),
      publicationYear: _asInt(map['publication_year'] ?? map['publicationYear']),
      sourceUrl: map['source_url']?.toString() ?? map['sourceUrl']?.toString() ?? '',
      licenseName:
          map['license_name']?.toString() ?? map['licenseName']?.toString() ?? '',
      licenseUrl:
          map['license_url']?.toString() ?? map['licenseUrl']?.toString() ?? '',
      attributionText: map['attribution_text']?.toString() ??
          map['attributionText']?.toString() ??
          '',
      notes: _localized(map, 'notes', isEn),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'contributors': contributors,
      'translators': translators,
      'publisher': publisher,
      'publication_year': publicationYear,
      'source_url': sourceUrl,
      'license_name': licenseName,
      'license_url': licenseUrl,
      'attribution_text': attributionText,
      'notes': notes,
    };
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    return const [];
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static String? _localized(Map<String, dynamic> map, String base, bool isEn) {
    final primary = map['${base}_${isEn ? "en" : "pt"}']?.toString();
    if (primary != null && primary.trim().isNotEmpty) return primary;
    final fallback = map['${base}_${isEn ? "pt" : "en"}']?.toString();
    if (fallback != null && fallback.trim().isNotEmpty) return fallback;
    return map[base]?.toString();
  }
}
