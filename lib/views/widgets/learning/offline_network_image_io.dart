import 'dart:io';

import 'package:flutter/material.dart';

import '../../../services/learning_image_cache.dart';

class OfflineNetworkImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? semanticLabel;
  final WidgetBuilder? placeholder;
  final ImageErrorWidgetBuilder? errorBuilder;

  const OfflineNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.semanticLabel,
    this.placeholder,
    this.errorBuilder,
  });

  @override
  State<OfflineNetworkImage> createState() => _OfflineNetworkImageState();
}

class _OfflineNetworkImageState extends State<OfflineNetworkImage> {
  late Future<String?> _localPath;

  @override
  void initState() {
    super.initState();
    _localPath = LearningImageCache().resolve(widget.url);
  }

  @override
  void didUpdateWidget(covariant OfflineNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _localPath = LearningImageCache().resolve(widget.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _localPath,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.placeholder?.call(context) ??
              const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
        }

        final path = snapshot.data;
        if (path == null || path.isEmpty) {
          return widget.errorBuilder?.call(
                context,
                StateError('Imagem indisponível offline: ${widget.url}'),
                snapshot.stackTrace,
              ) ??
              const Center(child: Icon(Icons.broken_image_outlined));
        }

        return Image.file(
          File(path),
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
          semanticLabel: widget.semanticLabel,
          errorBuilder: widget.errorBuilder,
        );
      },
    );
  }
}
