class LessonSectionModel {
  final String title;
  final String body;
  final List<String> bullets;
  final String? highlight;

  const LessonSectionModel({
    required this.title,
    required this.body,
    this.bullets = const [],
    this.highlight,
  });

  factory LessonSectionModel.fromMap(Map<String, dynamic> map) {
    return LessonSectionModel(
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      bullets: _parseStringList(map['bullets']),
      highlight: map['highlight']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'bullets': bullets,
      'highlight': highlight,
    };
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }
}
