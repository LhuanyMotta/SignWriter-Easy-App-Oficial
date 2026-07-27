import 'media_asset_model.dart';

enum LessonBlockType {
  heading,
  text,
  bullets,
  highlight,
  image,
  signwriting,
  comparison,
  unknown,
}

class LessonBlockModel {
  final String id;
  final String lessonId;
  final LessonBlockType type;
  final String title;
  final String body;
  final List<String> bullets;
  final String? caption;
  final String? mediaId;
  final String? mediaUrl;
  final String? mediaAsset;
  final String? fsw;
  final String? swu;
  final Map<String, dynamic> payload;
  final int orderIndex;
  final MediaAssetModel? media;

  const LessonBlockModel({
    required this.id,
    this.lessonId = '',
    required this.type,
    this.title = '',
    this.body = '',
    this.bullets = const [],
    this.caption,
    this.mediaId,
    this.mediaUrl,
    this.mediaAsset,
    this.fsw,
    this.swu,
    this.payload = const {},
    this.orderIndex = 0,
    this.media,
  });

  bool get hasMedia =>
      (mediaUrl != null && mediaUrl!.trim().isNotEmpty) ||
      (mediaAsset != null && mediaAsset!.trim().isNotEmpty) ||
      media != null;

  bool get hasFsw =>
      (fsw != null && fsw!.trim().isNotEmpty) ||
      (media?.fsw != null && media!.fsw!.trim().isNotEmpty);

  String? get effectiveFsw {
    final local = fsw?.trim();
    if (local != null && local.isNotEmpty) return local;
    return media?.fsw?.trim();
  }

  String? get effectiveSwu {
    final local = swu?.trim();
    if (local != null && local.isNotEmpty) return local;
    return media?.swu?.trim();
  }

  String? get effectiveCaption {
    final local = caption?.trim();
    if (local != null && local.isNotEmpty) return local;
    return media?.caption?.trim();
  }

  String get effectiveAltText {
    final fromMedia = media?.altText.trim() ?? '';
    if (fromMedia.isNotEmpty) return fromMedia;
    return effectiveCaption ?? title;
  }

  factory LessonBlockModel.fromMap(
    Map<String, dynamic> map, {
    String lang = 'pt',
    MediaAssetModel? media,
  }) {
    final isEn = lang.toLowerCase() == 'en';
    return LessonBlockModel(
      id: map['id']?.toString() ?? '',
      lessonId: map['lesson_id']?.toString() ?? map['lessonId']?.toString() ?? '',
      type: parseType(map['type']?.toString()),
      title: _localized(map, 'title', isEn) ?? '',
      body: _localized(map, 'body', isEn) ?? '',
      bullets: _localizedList(map, 'bullets', isEn),
      caption: _localized(map, 'caption', isEn),
      mediaId: map['media_id']?.toString() ?? map['mediaId']?.toString(),
      mediaUrl: map['media_url']?.toString() ?? map['mediaUrl']?.toString(),
      mediaAsset: map['media_asset']?.toString() ?? map['mediaAsset']?.toString(),
      fsw: map['fsw']?.toString(),
      swu: map['swu']?.toString(),
      payload: _asMap(map['payload']),
      orderIndex: _asInt(map['order_index'] ?? map['orderIndex']) ?? 0,
      media: media,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'type': type == LessonBlockType.unknown ? 'text' : type.name,
      'title': title,
      'body': body,
      'bullets': bullets,
      'caption': caption,
      'media_id': mediaId,
      'media_url': mediaUrl,
      'media_asset': mediaAsset,
      'fsw': fsw,
      'swu': swu,
      'payload': payload,
      'order_index': orderIndex,
      if (media != null) 'media': media!.toMap(),
    };
  }

  LessonBlockModel copyWith({
    String? id,
    String? lessonId,
    LessonBlockType? type,
    String? title,
    String? body,
    List<String>? bullets,
    String? caption,
    String? mediaId,
    String? mediaUrl,
    String? mediaAsset,
    String? fsw,
    String? swu,
    Map<String, dynamic>? payload,
    int? orderIndex,
    MediaAssetModel? media,
  }) {
    return LessonBlockModel(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      bullets: bullets ?? this.bullets,
      caption: caption ?? this.caption,
      mediaId: mediaId ?? this.mediaId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaAsset: mediaAsset ?? this.mediaAsset,
      fsw: fsw ?? this.fsw,
      swu: swu ?? this.swu,
      payload: payload ?? this.payload,
      orderIndex: orderIndex ?? this.orderIndex,
      media: media ?? this.media,
    );
  }

  static LessonBlockType parseType(String? raw) {
    switch (raw) {
      case 'heading':
        return LessonBlockType.heading;
      case 'bullets':
        return LessonBlockType.bullets;
      case 'highlight':
        return LessonBlockType.highlight;
      case 'image':
        return LessonBlockType.image;
      case 'signwriting':
        return LessonBlockType.signwriting;
      case 'comparison':
        return LessonBlockType.comparison;
      case 'text':
        return LessonBlockType.text;
      default:
        return LessonBlockType.unknown;
    }
  }

  static String? _localized(Map<String, dynamic> map, String base, bool isEn) {
    final primaryKey = '${base}_${isEn ? "en" : "pt"}';
    final primary = map[primaryKey]?.toString();
    if (primary != null && primary.trim().isNotEmpty) return primary;
    final fallbackKey = '${base}_${isEn ? "pt" : "en"}';
    final fallback = map[fallbackKey]?.toString();
    if (fallback != null && fallback.trim().isNotEmpty) return fallback;
    final plain = map[base]?.toString();
    if (plain != null && plain.trim().isNotEmpty) return plain;
    return null;
  }

  static List<String> _localizedList(
    Map<String, dynamic> map,
    String base,
    bool isEn,
  ) {
    final primary = map['${base}_${isEn ? "en" : "pt"}'];
    final fallback = map['${base}_${isEn ? "pt" : "en"}'];
    final plain = map[base];
    for (final candidate in [primary, fallback, plain]) {
      if (candidate is List && candidate.isNotEmpty) {
        return candidate.map((e) => e.toString()).toList();
      }
    }
    return const [];
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
