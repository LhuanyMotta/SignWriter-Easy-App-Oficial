import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/lesson_source_model.dart';
import '../../../theme/app_radius.dart';

/// Seção de referências estruturadas (fonte, páginas, licença, atribuição).
class LessonSourcesSection extends StatelessWidget {
  final List<LessonSourceModel> sources;
  final List<String> legacyReferences;
  final bool collapsible;

  const LessonSourcesSection({
    super.key,
    required this.sources,
    this.legacyReferences = const [],
    this.collapsible = false,
  });

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty && legacyReferences.isEmpty) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...sources.map((item) => _SourceCard(item: item)),
        ...legacyReferences.map(
          (ref) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '• $ref',
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
        ),
      ],
    );

    if (!collapsible) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Referências e licenças',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        title: Text(
          'Referências e licenças',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        children: [content],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  final LessonSourceModel item;

  const _SourceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final source = item.source;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  source?.title ?? 'Fonte',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (item.isPrimary)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Principal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          if (source != null && source.authors.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Autores: ${source.authors.join(', ')}'),
          ],
          if (source != null && source.translators.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Tradução: ${source.translators.join(', ')}'),
          ],
          if (item.pageRangeLabel != null) ...[
            const SizedBox(height: 4),
            Text('Páginas: ${item.pageRangeLabel}'),
          ],
          if (source != null && source.licenseName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Licença: ${source.licenseName}'),
          ],
          if (item.adaptationNote != null &&
              item.adaptationNote!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Adaptação: ${item.adaptationNote}'),
          ],
          if (source != null && source.attributionText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              source.attributionText,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
          if (source != null && source.sourceUrl.isNotEmpty) ...[
            const SizedBox(height: 8),
            SelectableText(
              'Original: ${source.sourceUrl}',
              style: TextStyle(fontSize: 12, color: scheme.primary),
              onTap: () => Clipboard.setData(
                ClipboardData(text: source.sourceUrl),
              ),
            ),
          ],
          if (source != null && source.licenseUrl.isNotEmpty) ...[
            const SizedBox(height: 4),
            SelectableText(
              'Licença URL: ${source.licenseUrl}',
              style: TextStyle(fontSize: 12, color: scheme.primary),
            ),
          ],
        ],
      ),
    );
  }
}
