enum MediaAssetKind {
  image,
  video,
  audio,
  document,
  animation,
  signwriting,
  unknown,
}

class MediaAssetModel {
  final String id;
  final MediaAssetKind kind;
  final String? storageBucket;
  final String? storagePath;
  final String? externalUrl;
  final String? assetPath;
  final String? mimeType;
  final String? title;
  final String altText;
  final String? caption;
  final String? fsw;
  final String? swu;
  final String? symbolKey;
  final String? sourceId;
  final int? sourcePageStart;
  final int? sourcePageEnd;
  final bool isModified;
  final String? modificationNotes;
  final String? licenseName;
  final String? licenseUrl;
  final String? attributionText;
  final Map<String, dynamic> metadata;

  const MediaAssetModel({
    required this.id,
    this.kind = MediaAssetKind.unknown,
    this.storageBucket,
    this.storagePath,
    this.externalUrl,
    this.assetPath,
    this.mimeType,
    this.title,
    this.altText = '',
    this.caption,
    this.fsw,
    this.swu,
    this.symbolKey,
    this.sourceId,
    this.sourcePageStart,
    this.sourcePageEnd,
    this.isModified = false,
    this.modificationNotes,
    this.licenseName,
    this.licenseUrl,
    this.attributionText,
    this.metadata = const {},
  });

  /// URL resolvida para exibição (externa ou Storage público).
  String? get resolvedUrl {
    final external = externalUrl?.trim();
    if (external != null && external.isNotEmpty) return external;

    final bucket = storageBucket?.trim();
    final path = storagePath?.trim();
    if (bucket != null &&
        bucket.isNotEmpty &&
        path != null &&
        path.isNotEmpty) {
      // Compatível com buckets públicos do projeto (ex.: learning-content).
      return null; // preenchido no serviço com base na URL do projeto
    }
    return null;
  }

  bool get hasLocalAsset =>
      assetPath != null && assetPath!.trim().isNotEmpty;

  bool get hasFsw => fsw != null && fsw!.trim().isNotEmpty;

  factory MediaAssetModel.fromMap(Map<String, dynamic> map, {String lang = 'pt'}) {
    final isEn = lang.toLowerCase() == 'en';
    return MediaAssetModel(
      id: map['id']?.toString() ?? '',
      kind: _parseKind(map['kind']?.toString()),
      storageBucket: map['storage_bucket']?.toString() ?? map['storageBucket']?.toString(),
      storagePath: map['storage_path']?.toString() ?? map['storagePath']?.toString(),
      externalUrl: map['external_url']?.toString() ?? map['externalUrl']?.toString(),
      assetPath: map['asset_path']?.toString() ?? map['assetPath']?.toString(),
      mimeType: map['mime_type']?.toString() ?? map['mimeType']?.toString(),
      title: map['title']?.toString(),
      altText: _localized(map, 'alt_text', isEn) ?? '',
      caption: _localized(map, 'caption', isEn),
      fsw: map['fsw']?.toString(),
      swu: map['swu']?.toString(),
      symbolKey: map['symbol_key']?.toString() ?? map['symbolKey']?.toString(),
      sourceId: map['source_id']?.toString() ?? map['sourceId']?.toString(),
      sourcePageStart: _asInt(map['source_page_start'] ?? map['sourcePageStart']),
      sourcePageEnd: _asInt(map['source_page_end'] ?? map['sourcePageEnd']),
      isModified: map['is_modified'] == true || map['isModified'] == true,
      modificationNotes: _localized(map, 'modification_notes', isEn),
      licenseName: map['license_name']?.toString() ?? map['licenseName']?.toString(),
      licenseUrl: map['license_url']?.toString() ?? map['licenseUrl']?.toString(),
      attributionText:
          map['attribution_text']?.toString() ?? map['attributionText']?.toString(),
      metadata: _asMap(map['metadata']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kind': kind.name,
      'storage_bucket': storageBucket,
      'storage_path': storagePath,
      'external_url': externalUrl,
      'asset_path': assetPath,
      'mime_type': mimeType,
      'title': title,
      'alt_text': altText,
      'caption': caption,
      'fsw': fsw,
      'swu': swu,
      'symbol_key': symbolKey,
      'source_id': sourceId,
      'source_page_start': sourcePageStart,
      'source_page_end': sourcePageEnd,
      'is_modified': isModified,
      'modification_notes': modificationNotes,
      'license_name': licenseName,
      'license_url': licenseUrl,
      'attribution_text': attributionText,
      'metadata': metadata,
    };
  }

  MediaAssetModel copyWith({
    String? externalUrl,
    String? assetPath,
  }) {
    return MediaAssetModel(
      id: id,
      kind: kind,
      storageBucket: storageBucket,
      storagePath: storagePath,
      externalUrl: externalUrl ?? this.externalUrl,
      assetPath: assetPath ?? this.assetPath,
      mimeType: mimeType,
      title: title,
      altText: altText,
      caption: caption,
      fsw: fsw,
      swu: swu,
      symbolKey: symbolKey,
      sourceId: sourceId,
      sourcePageStart: sourcePageStart,
      sourcePageEnd: sourcePageEnd,
      isModified: isModified,
      modificationNotes: modificationNotes,
      licenseName: licenseName,
      licenseUrl: licenseUrl,
      attributionText: attributionText,
      metadata: metadata,
    );
  }

  static MediaAssetKind _parseKind(String? raw) {
    switch (raw) {
      case 'image':
        return MediaAssetKind.image;
      case 'video':
        return MediaAssetKind.video;
      case 'audio':
        return MediaAssetKind.audio;
      case 'document':
        return MediaAssetKind.document;
      case 'animation':
        return MediaAssetKind.animation;
      case 'signwriting':
        return MediaAssetKind.signwriting;
      default:
        return MediaAssetKind.unknown;
    }
  }

  static String? _localized(Map<String, dynamic> map, String base, bool isEn) {
    final primary = map['${base}_${isEn ? "en" : "pt"}']?.toString();
    if (primary != null && primary.trim().isNotEmpty) return primary;
    final fallback = map['${base}_${isEn ? "pt" : "en"}']?.toString();
    if (fallback != null && fallback.trim().isNotEmpty) return fallback;
    return map[base]?.toString();
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }
}
