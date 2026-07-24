import 'package:flutter/material.dart';

import '../../../models/lesson_block_model.dart';
import 'lesson_inline_field.dart';

class LessonBlockText extends StatelessWidget {
  final LessonBlockModel block;
  final Color accent;
  final bool isEditing;
  final ValueChanged<LessonBlockModel>? onChanged;

  const LessonBlockText({
    super.key,
    required this.block,
    required this.accent,
    this.isEditing = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (block.type == LessonBlockType.heading) {
      final style = TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: scheme.onSurface,
      );
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 8),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: isEditing
                  ? LessonInlineField(
                      value: block.title,
                      hint: 'Título da seção',
                      style: style,
                      cursorColor: accent,
                      onChanged: (v) =>
                          onChanged?.call(block.copyWith(title: v)),
                    )
                  : Text(block.title, style: style),
            ),
          ],
        ),
      );
    }

    if (block.type == LessonBlockType.bullets) {
      final itemStyle = TextStyle(
        fontSize: 15,
        height: 1.4,
        color: scheme.onSurface.withValues(alpha: 0.85),
      );
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: isEditing
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LessonInlineField(
                      value: block.bullets.join('\n'),
                      hint: 'Um item por linha',
                      style: itemStyle,
                      minLines: 2,
                      cursorColor: accent,
                      onChanged: (v) => onChanged?.call(
                        block.copyWith(
                          bullets: v
                              .split('\n')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: block.bullets
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 18, color: accent),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item, style: itemStyle)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
      );
    }

    final bodyStyle = TextStyle(
      fontSize: 15.5,
      height: 1.55,
      color: scheme.onSurface.withValues(alpha: 0.9),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: isEditing
          ? LessonInlineField(
              value: block.body,
              hint: 'Escreva o conteúdo…',
              style: bodyStyle,
              minLines: 3,
              cursorColor: accent,
              onChanged: (v) => onChanged?.call(block.copyWith(body: v)),
            )
          : Text(block.body, style: bodyStyle),
    );
  }
}
