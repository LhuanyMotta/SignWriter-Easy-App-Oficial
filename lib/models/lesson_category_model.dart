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
      case 'front_hand':
        return Icons.front_hand_rounded;
      case 'auto_stories':
        return Icons.auto_stories_rounded;
      case 'sentiment_satisfied':
        return Icons.sentiment_satisfied_alt_rounded;
      case 'wb_sunny':
        return Icons.wb_sunny_rounded;
      case 'diversity_3':
        return Icons.diversity_3_rounded;
      case 'record_voice_over':
        return Icons.record_voice_over_rounded;
      case 'family_restroom':
        return Icons.family_restroom_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'local_hospital':
        return Icons.local_hospital_rounded;
      case 'travel_explore':
        return Icons.travel_explore_rounded;
      case 'school':
        return Icons.school_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  // Todas as categorias usam a cor primária do app para consistência visual
  Color get color => const Color(0xFF2D78BB);

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
