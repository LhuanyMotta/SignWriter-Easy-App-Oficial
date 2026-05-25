import 'package:flutter/material.dart';

import 'lesson_model.dart';

class LessonCategoryModel {
  final String id;
  final String title;
  final String description;
  final String iconKey;
  final String colorHex;
  final List<LessonModel> lessons;

  const LessonCategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.colorHex,
    this.lessons = const [],
  });

  IconData get icon {
    switch (iconKey) {
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'sign_language':
        return Icons.sign_language_rounded;
      case 'swipe':
        return Icons.swipe_rounded;
      case 'face':
        return Icons.face_retouching_natural_rounded;
      case 'translate':
        return Icons.translate_rounded;
      case 'gesture':
        return Icons.gesture_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  Color get color {
    final sanitized = colorHex.replaceAll('#', '');
    final buffer = StringBuffer();
    if (sanitized.length == 6) {
      buffer.write('ff');
    }
    buffer.write(sanitized);
    return Color(int.tryParse(buffer.toString(), radix: 16) ?? 0xFF2D78BB);
  }

  factory LessonCategoryModel.fromMap(Map<String, dynamic> map) {
    return LessonCategoryModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      iconKey: map['icon']?.toString() ?? 'school',
      colorHex: map['color']?.toString() ?? '#2D78BB',
      lessons: _parseLessons(map['lessons']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': iconKey,
      'color': colorHex,
      'lessons': lessons.map((lesson) => lesson.toMap()).toList(),
    };
  }

  static List<LessonModel> _parseLessons(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (item) => LessonModel.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }
    return const [];
  }
}
