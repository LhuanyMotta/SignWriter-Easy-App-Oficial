import 'package:flutter/material.dart';

import 'app_theme.dart';

class AppSpacing {
  static double scale(BuildContext context) {
    return Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0;
  }

  static double value(BuildContext context, num base) {
    return base.toDouble() * scale(context).clamp(0.8, 2.0);
  }

  static EdgeInsets all(BuildContext context, num value) {
    return EdgeInsets.all(AppSpacing.value(context, value));
  }

  static EdgeInsets symmetric(
    BuildContext context, {
    num horizontal = 0,
    num vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: AppSpacing.value(context, horizontal),
      vertical: AppSpacing.value(context, vertical),
    );
  }

  static EdgeInsets only(
    BuildContext context, {
    num left = 0,
    num top = 0,
    num right = 0,
    num bottom = 0,
  }) {
    return EdgeInsets.only(
      left: AppSpacing.value(context, left),
      top: AppSpacing.value(context, top),
      right: AppSpacing.value(context, right),
      bottom: AppSpacing.value(context, bottom),
    );
  }
}
