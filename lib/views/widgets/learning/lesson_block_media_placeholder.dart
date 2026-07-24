import 'package:flutter/material.dart';

import '../../../models/lesson_block_model.dart';
import '../../../theme/app_radius.dart';
import 'lesson_inline_field.dart';

class LessonBlockMediaPlaceholder extends StatelessWidget {
  final LessonBlockModel? block;
  final Color accent;
  final String label;
  final IconData icon;
  final double height;
  final bool isEditing;
  final ValueChanged<LessonBlockModel>? onChanged;
  final VoidCallback? onReplaceMedia;

  const LessonBlockMediaPlaceholder({
    super.key,
    this.block,
    required this.accent,
    this.label = 'Observe o sinal',
    this.icon = Icons.sign_language_rounded,
    this.height = 180,
    this.isEditing = false,
    this.onChanged,
    this.onReplaceMedia,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final asset = block?.mediaAsset;
    final url = block?.mediaUrl;
    final caption = block?.caption ??
        (block?.fsw != null && block!.fsw!.isNotEmpty
            ? 'FSW: ${block!.fsw}'
            : null);
    final captionText = caption ?? label;

    return Container(
      width: double.infinity,
      height: height,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (asset != null && asset.isNotEmpty)
            Image.asset(
              asset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _Empty(icon: icon, accent: accent),
            )
          else if (url != null && url.isNotEmpty)
            Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _Empty(icon: icon, accent: accent),
            )
          else
            _Empty(icon: icon, accent: accent),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isEditing && block != null
                  ? LessonInlineField(
                      value: captionText,
                      hint: 'Legenda da mídia',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      cursorColor: Colors.white,
                      showUnderline: false,
                      textAlign: TextAlign.center,
                      onChanged: (v) =>
                          onChanged?.call(block!.copyWith(caption: v)),
                    )
                  : Text(
                      captionText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
          if (block?.type == LessonBlockType.signwriting ||
              (block?.fsw == null && asset == null && url == null))
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'FSW em breve',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ),
          if (isEditing)
            Positioned(
              top: 10,
              left: 10,
              child: Material(
                color: scheme.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: onReplaceMedia,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.photo_camera_rounded,
                        size: 18, color: accent),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final Color accent;

  const _Empty({required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(icon, size: 64, color: accent.withValues(alpha: 0.45)),
    );
  }
}

class LessonBlockComparisonPlaceholder extends StatelessWidget {
  final Color accent;
  final bool isEditing;

  const LessonBlockComparisonPlaceholder({
    super.key,
    required this.accent,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _Panel(
                  title: 'Correto',
                  color: Colors.green,
                  scheme: scheme,
                  isEditing: isEditing,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Panel(
                  title: 'Incorreto',
                  color: Colors.redAccent,
                  scheme: scheme,
                  isEditing: isEditing,
                ),
              ),
            ],
          ),
          if (isEditing) ...[
            const SizedBox(height: 8),
            Text(
              'Comparação visual — mídia do SignBank em breve',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final Color color;
  final ColorScheme scheme;
  final bool isEditing;

  const _Panel({
    required this.title,
    required this.color,
    required this.scheme,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isEditing ? Icons.add_photo_alternate_outlined : Icons.image_outlined,
            color: color.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          Text(
            isEditing ? 'Toque quando disponível' : 'Exemplo visual',
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
