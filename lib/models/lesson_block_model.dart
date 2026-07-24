import 'lesson_section_model.dart';

enum LessonBlockType {
  heading,
  text,
  bullets,
  highlight,
  image,
  signwriting,
  comparison,
}

class LessonBlockModel {
  final String id;
  final LessonBlockType type;
  final String title;
  final String body;
  final List<String> bullets;
  final String? mediaUrl;
  final String? mediaAsset;
  final String? fsw;
  final String? caption;

  const LessonBlockModel({
    required this.id,
    required this.type,
    this.title = '',
    this.body = '',
    this.bullets = const [],
    this.mediaUrl,
    this.mediaAsset,
    this.fsw,
    this.caption,
  });

  factory LessonBlockModel.fromMap(Map<String, dynamic> map) {
    return LessonBlockModel(
      id: map['id']?.toString() ?? '',
      type: _parseType(map['type']?.toString()),
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      bullets: _parseStringList(map['bullets']),
      mediaUrl: map['mediaUrl']?.toString() ?? map['media_url']?.toString(),
      mediaAsset:
          map['mediaAsset']?.toString() ?? map['media_asset']?.toString(),
      fsw: map['fsw']?.toString(),
      caption: map['caption']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'body': body,
      'bullets': bullets,
      'mediaUrl': mediaUrl,
      'mediaAsset': mediaAsset,
      'fsw': fsw,
      'caption': caption,
    };
  }

  LessonBlockModel copyWith({
    String? id,
    LessonBlockType? type,
    String? title,
    String? body,
    List<String>? bullets,
    String? mediaUrl,
    String? mediaAsset,
    String? fsw,
    String? caption,
  }) {
    return LessonBlockModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      bullets: bullets ?? this.bullets,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaAsset: mediaAsset ?? this.mediaAsset,
      fsw: fsw ?? this.fsw,
      caption: caption ?? this.caption,
    );
  }

  /// Converte seções legadas em blocos visuais.
  static List<LessonBlockModel> fromSections(List<LessonSectionModel> sections) {
    final blocks = <LessonBlockModel>[];
    for (var i = 0; i < sections.length; i++) {
      final section = sections[i];
      final baseId = 'section-$i';

      if (section.title.trim().isNotEmpty) {
        blocks.add(
          LessonBlockModel(
            id: '$baseId-heading',
            type: LessonBlockType.heading,
            title: section.title,
          ),
        );
      }
      if (section.body.trim().isNotEmpty) {
        blocks.add(
          LessonBlockModel(
            id: '$baseId-text',
            type: LessonBlockType.text,
            body: section.body,
          ),
        );
      }
      if (section.bullets.isNotEmpty) {
        blocks.add(
          LessonBlockModel(
            id: '$baseId-bullets',
            type: LessonBlockType.bullets,
            bullets: section.bullets,
          ),
        );
      }
      if (section.highlight != null && section.highlight!.trim().isNotEmpty) {
        blocks.add(
          LessonBlockModel(
            id: '$baseId-highlight',
            type: LessonBlockType.highlight,
            body: section.highlight!,
          ),
        );
      }
    }
    return blocks;
  }

  static LessonBlockType _parseType(String? raw) {
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
      default:
        return LessonBlockType.text;
    }
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }
}
