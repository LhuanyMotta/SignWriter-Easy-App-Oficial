import 'package:flutter/material.dart';

import '../../../models/lesson_block_model.dart';
import 'lesson_block_highlight.dart';
import 'lesson_block_text.dart';
import 'lesson_media_view.dart';

/// Mapeia [LessonBlockModel] para o widget visual correspondente.
class LessonBlockRenderer extends StatelessWidget {
  final LessonBlockModel block;
  final Color accent;
  final bool isEditing;
  final ValueChanged<LessonBlockModel>? onChanged;

  const LessonBlockRenderer({
    super.key,
    required this.block,
    required this.accent,
    this.isEditing = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case LessonBlockType.highlight:
        return LessonBlockHighlight(
          block: block,
          accent: accent,
          isEditing: isEditing,
          onChanged: onChanged,
        );
      case LessonBlockType.image:
      case LessonBlockType.signwriting:
        return LessonMediaView.fromBlock(
          block: block,
          accent: accent,
        );
      case LessonBlockType.comparison:
        return LessonComparisonView(
          block: block,
          accent: accent,
        );
      case LessonBlockType.heading:
      case LessonBlockType.text:
      case LessonBlockType.bullets:
      case LessonBlockType.unknown:
        return LessonBlockText(
          block: block.type == LessonBlockType.unknown
              ? block.copyWith(type: LessonBlockType.text)
              : block,
          accent: accent,
          isEditing: isEditing,
          onChanged: onChanged,
        );
    }
  }
}
