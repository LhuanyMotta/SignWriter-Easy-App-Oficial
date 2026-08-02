import 'package:flutter/material.dart';

enum AppStatusBannerTone { info, warning, error }

/// Banner persistente (offline, aviso, erro inline).
class AppStatusBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final AppStatusBannerTone tone;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionTooltip;

  const AppStatusBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.tone = AppStatusBannerTone.info,
    this.icon,
    this.onAction,
    this.actionTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      AppStatusBannerTone.error => Colors.red,
      AppStatusBannerTone.warning => Colors.orange,
      AppStatusBannerTone.info => Theme.of(context).colorScheme.primary,
    };

    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        leading: Icon(icon ?? Icons.info_outline, color: color),
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: onAction == null
            ? null
            : IconButton(
                tooltip: actionTooltip,
                icon: const Icon(Icons.refresh_rounded),
                onPressed: onAction,
              ),
      ),
    );
  }
}
