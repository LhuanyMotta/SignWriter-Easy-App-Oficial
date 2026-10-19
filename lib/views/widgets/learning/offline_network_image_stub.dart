import 'package:flutter/material.dart';

class OfflineNetworkImage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      semanticLabel: semanticLabel,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return placeholder?.call(context) ??
            const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
      },
      errorBuilder: errorBuilder,
    );
  }
}
