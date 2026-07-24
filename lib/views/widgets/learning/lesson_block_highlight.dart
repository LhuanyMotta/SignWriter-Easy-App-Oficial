import 'package:flutter/material.dart';

import '../../../models/lesson_block_model.dart';
import '../../../theme/app_radius.dart';
import 'lesson_inline_field.dart';

class LessonBlockHighlight extends StatelessWidget {
  final LessonBlockModel block;
  final Color accent;
  final bool isEditing;
  final ValueChanged<LessonBlockModel>? onChanged;

  const LessonBlockHighlight({
    super.key,
    required this.block,
    required this.accent,
    this.isEditing = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 15,
      height: 1.45,
      fontWeight: FontWeight.w600,
      color: accent.withValues(alpha: 0.95),
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border(
          left: BorderSide(color: accent, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_rounded, color: accent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: isEditing
                ? LessonInlineField(
                    value: block.body,
                    hint: 'Dica ou destaque…',
                    style: textStyle,
                    minLines: 2,
                    cursorColor: accent,
                    showUnderline: false,
                    onChanged: (v) =>
                        onChanged?.call(block.copyWith(body: v)),
                  )
                : Text(block.body, style: textStyle),
          ),
        ],
      ),
    );
  }
}
