import 'content_source_model.dart';

class LessonSourceModel {
  final String id;
  final String lessonId;
  final String sourceId;
  final ContentSourceModel? source;
  final int? pageStart;
  final int? pageEnd;
  final String? adaptationNote;
  final bool isPrimary;

  const LessonSourceModel({
    required this.id,
    required this.lessonId,
    required this.sourceId,
    this.source,
    this.pageStart,
    this.pageEnd,
    this.adaptationNote,
    this.isPrimary = false,
  });

  String? get pageRangeLabel {
    if (pageStart == null && pageEnd == null) return null;
    if (pageStart != null && pageEnd != null && pageStart != pageEnd) {
      return 'pp. $pageStart–$pageEnd';
    }
    final page = pageStart ?? pageEnd;
    return page == null ? null : 'p. $page';
  }

  factory LessonSourceModel.fromMap(
    Map<String, dynamic> map, {
    String lang = 'pt',
    ContentSourceModel? source,
  }) {
    final isEn = lang.toLowerCase() == 'en';
    final nested = map['content_sources'] ?? map['source'];
    ContentSourceModel? resolved = source;
    if (resolved == null && nested is Map) {
      resolved = ContentSourceModel.fromMap(
        Map<String, dynamic>.from(nested),
        lang: lang,
      );
    }

    return LessonSourceModel(
      id: map['id']?.toString() ?? '',
      lessonId: map['lesson_id']?.toString() ?? map['lessonId']?.toString() ?? '',
      sourceId: map['source_id']?.toString() ?? map['sourceId']?.toString() ?? '',
      source: resolved,
      pageStart: _asInt(map['page_start'] ?? map['pageStart']),
      pageEnd: _asInt(map['page_end'] ?? map['pageEnd']),
      adaptationNote: _localized(map, 'adaptation_note', isEn),
      isPrimary: map['is_primary'] == true || map['isPrimary'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'source_id': sourceId,
      'page_start': pageStart,
      'page_end': pageEnd,
      'adaptation_note': adaptationNote,
      'is_primary': isPrimary,
      if (source != null) 'source': source!.toMap(),
    };
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
