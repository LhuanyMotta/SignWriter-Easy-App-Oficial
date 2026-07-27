import 'package:flutter/material.dart';

import '../../../models/lesson_block_model.dart';
import '../../../services/signmaker_bridge_service.dart';
import '../../../theme/app_radius.dart';

/// Renderiza mídia de bloco: asset local, URL (incl. learning-content) ou FSW.
class LessonMediaView extends StatelessWidget {
  final String? mediaUrl;
  final String? mediaAsset;
  final String? fsw;
  final String? swu;
  final String altText;
  final String? caption;
  final String? attribution;
  final Color accent;
  final double height;
  final IconData emptyIcon;

  const LessonMediaView({
    super.key,
    this.mediaUrl,
    this.mediaAsset,
    this.fsw,
    this.swu,
    this.altText = '',
    this.caption,
    this.attribution,
    required this.accent,
    this.height = 200,
    this.emptyIcon = Icons.image_outlined,
  });

  factory LessonMediaView.fromBlock({
    required LessonBlockModel block,
    required Color accent,
    double height = 200,
  }) {
    return LessonMediaView(
      mediaUrl: block.mediaUrl ?? block.media?.externalUrl,
      mediaAsset: block.mediaAsset ?? block.media?.assetPath,
      fsw: block.effectiveFsw,
      swu: block.effectiveSwu,
      altText: block.effectiveAltText,
      caption: block.effectiveCaption,
      attribution: block.media?.attributionText,
      accent: accent,
      height: height,
      emptyIcon: block.type == LessonBlockType.signwriting
          ? Icons.sign_language_rounded
          : Icons.image_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bridge = SignMakerBridgeService();
    final hasAsset = mediaAsset != null && mediaAsset!.trim().isNotEmpty;
    final hasUrl = mediaUrl != null && mediaUrl!.trim().isNotEmpty;
    final validFsw = fsw != null && bridge.isValidFsw(fsw!);

    return Semantics(
      label: altText.isNotEmpty ? altText : (caption ?? 'Mídia da lição'),
      image: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(color: accent.withValues(alpha: 0.25)),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasAsset
                ? Image.asset(
                    mediaAsset!,
                    fit: BoxFit.contain,
                    semanticLabel: altText,
                    errorBuilder: (_, __, ___) => _Fallback(
                      accent: accent,
                      icon: emptyIcon,
                      fsw: validFsw ? fsw : null,
                      swu: swu,
                    ),
                  )
                : hasUrl
                    ? Image.network(
                        mediaUrl!,
                        fit: BoxFit.contain,
                        semanticLabel: altText,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => _Fallback(
                          accent: accent,
                          icon: emptyIcon,
                          fsw: validFsw ? fsw : null,
                          swu: swu,
                        ),
                      )
                    : _Fallback(
                        accent: accent,
                        icon: emptyIcon,
                        fsw: validFsw ? fsw : null,
                        swu: swu,
                      ),
          ),
          if (caption != null && caption!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              caption!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
          if (attribution != null && attribution!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              attribution!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String? fsw;
  final String? swu;

  const _Fallback({
    required this.accent,
    required this.icon,
    this.fsw,
    this.swu,
  });

  @override
  Widget build(BuildContext context) {
    if (fsw != null && fsw!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sign_language_rounded, size: 36, color: accent),
            const SizedBox(height: 12),
            SelectableText(
              fsw!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (swu != null && swu!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              SelectableText(
                swu!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Icon(icon, size: 56, color: accent.withValues(alpha: 0.45)),
    );
  }
}

class LessonComparisonView extends StatelessWidget {
  final LessonBlockModel block;
  final Color accent;

  const LessonComparisonView({
    super.key,
    required this.block,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final payload = block.payload;
    final leftTitle = payload['leftTitle']?.toString() ??
        payload['left_title']?.toString() ??
        'Correto';
    final rightTitle = payload['rightTitle']?.toString() ??
        payload['right_title']?.toString() ??
        'Incorreto';
    final leftUrl = payload['leftMediaUrl']?.toString() ??
        payload['left_media_url']?.toString();
    final rightUrl = payload['rightMediaUrl']?.toString() ??
        payload['right_media_url']?.toString();
    final leftFsw = payload['leftFsw']?.toString() ?? payload['left_fsw']?.toString();
    final rightFsw =
        payload['rightFsw']?.toString() ?? payload['right_fsw']?.toString();
    final leftBody = payload['leftBody']?.toString() ??
        payload['left_body']?.toString() ??
        block.body;
    final rightBody =
        payload['rightBody']?.toString() ?? payload['right_body']?.toString() ?? '';

    final left = _ComparisonPanel(
      title: leftTitle,
      color: Colors.green,
      mediaUrl: leftUrl,
      fsw: leftFsw,
      body: leftBody,
    );
    final right = _ComparisonPanel(
      title: rightTitle,
      color: Colors.redAccent,
      mediaUrl: rightUrl,
      fsw: rightFsw,
      body: rightBody,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 520;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: stacked
              ? Column(
                  children: [
                    left,
                    const SizedBox(height: 12),
                    right,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: 12),
                    Expanded(child: right),
                  ],
                ),
        );
      },
    );
  }
}

class _ComparisonPanel extends StatelessWidget {
  final String title;
  final Color color;
  final String? mediaUrl;
  final String? fsw;
  final String body;

  const _ComparisonPanel({
    required this.title,
    required this.color,
    this.mediaUrl,
    this.fsw,
    this.body = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          if (mediaUrl != null && mediaUrl!.isNotEmpty)
            SizedBox(
              height: 100,
              child: Image.network(
                mediaUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: color),
              ),
            )
          else if (fsw != null && fsw!.isNotEmpty)
            SelectableText(
              fsw!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            )
          else
            Icon(Icons.image_outlined, color: color.withValues(alpha: 0.7)),
          if (body.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
