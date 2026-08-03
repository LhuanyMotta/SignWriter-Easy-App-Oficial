import 'package:flutter/material.dart';

import '../../../models/lesson_category_model.dart';
import '../../../models/lesson_model.dart';

/// Linha compacta e responsiva de uma lição no percurso de aprendizagem.
class LearningLessonTile extends StatelessWidget {
  final LessonModel lesson;
  final LessonCategoryModel category;
  final bool isCompleted;
  final bool isInProgress;
  final bool isLast;
  final bool canEdit;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LearningLessonTile({
    super.key,
    required this.lesson,
    required this.category,
    required this.isCompleted,
    required this.isInProgress,
    required this.isLast,
    required this.onTap,
    this.canEdit = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusLabel = isCompleted
        ? 'Concluída'
        : isInProgress
            ? 'Em andamento'
            : 'Não iniciada';
    final statusColor = isCompleted
        ? Colors.green
        : isInProgress
            ? category.color
            : scheme.onSurface.withValues(alpha: 0.55);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 14, 8, isLast ? 16 : 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.play_circle_outline_rounded,
                color: statusColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.check_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 13,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            statusLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (canEdit && lesson.isDraft) ...[
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Rascunho',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (canEdit)
              PopupMenuButton<String>(
                tooltip: 'Opções da lição',
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: category.color,
                  size: 20,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurface.withValues(alpha: 0.3),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
