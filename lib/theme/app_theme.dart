import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  final double spacingScale;
  final double contrastLevel;
  final Color surface;
  final Color surfaceMuted;
  final Color onSurfaceMuted;
  final Color border;

  const AppThemeTokens({
    required this.spacingScale,
    required this.contrastLevel,
    required this.surface,
    required this.surfaceMuted,
    required this.onSurfaceMuted,
    required this.border,
  });

  @override
  AppThemeTokens copyWith({
    double? spacingScale,
    double? contrastLevel,
    Color? surface,
    Color? surfaceMuted,
    Color? onSurfaceMuted,
    Color? border,
  }) {
    return AppThemeTokens(
      spacingScale: spacingScale ?? this.spacingScale,
      contrastLevel: contrastLevel ?? this.contrastLevel,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      border: border ?? this.border,
    );
  }

  @override
  AppThemeTokens lerp(covariant ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) return this;
    return AppThemeTokens(
      spacingScale: lerpDouble(spacingScale, other.spacingScale, t)!,
      contrastLevel: lerpDouble(contrastLevel, other.contrastLevel, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

class AppTheme {
  static const Color _brandPrimary = Color(0xFF2D78BB);
  static const Color _brandSecondary = Color(0xFF4EB1F0);

  static ThemeData light({
    required double fontScale,
    required double contrastLevel,
    required double spacingScale,
  }) {
    final contrastT = _contrastNormalized(contrastLevel);
    final baseScheme = ColorScheme.fromSeed(
      seedColor: _brandPrimary,
      primary: _brandPrimary,
      secondary: _brandSecondary,
      brightness: Brightness.light,
    );
    const surface = Colors.white;
    final surfaceMuted = Color.lerp(
      const Color(0xFFF8FAFC),
      const Color(0xFFF2F4F7),
      contrastT,
    )!;
    // Contraste progressivo: quanto maior o nível, mais escura a borda.
    final border = Color.lerp(
      const Color(0xFFD1D5DB),
      const Color(0xFF374151),
      contrastT,
    )!;
    final onSurface = Color.lerp(
      const Color(0xFF1F2937),
      const Color(0xFF000000),
      contrastT,
    )!;
    final onSurfaceMuted = Color.lerp(
      const Color(0xFF4B5563),
      const Color(0xFF111827),
      contrastT,
    )!;
    final base = ThemeData(
      brightness: Brightness.light,
      colorScheme: baseScheme.copyWith(
        surface: surface,
        onSurface: onSurface,
        outline: border,
        outlineVariant: Color.lerp(
          const Color(0xFFE5E7EB),
          const Color(0xFF6B7280),
          contrastT,
        ),
      ),
      useMaterial3: true,
    );

    final textTheme = _scaledTextTheme(base.textTheme, fontScale).apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    );

    return base.copyWith(
      textTheme: textTheme,
      visualDensity: _visualDensity(spacingScale),
      extensions: [
        AppThemeTokens(
          spacingScale: spacingScale,
          contrastLevel: contrastLevel,
          surface: surface,
          surfaceMuted: surfaceMuted,
          onSurfaceMuted: onSurfaceMuted,
          border: border,
        ),
      ],
      cardTheme: base.cardTheme.copyWith(
        color: surface,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: _brandPrimary,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      listTileTheme: base.listTileTheme.copyWith(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * spacingScale.clamp(0.8, 2.0),
          vertical: 2 * spacingScale.clamp(0.8, 2.0),
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: surfaceMuted,
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * spacingScale.clamp(0.8, 2.0),
          vertical: 14 * spacingScale.clamp(0.8, 2.0),
        ),
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        selectedItemColor: _brandPrimary,
        unselectedItemColor: onSurfaceMuted,
      ),
      dividerTheme: DividerThemeData(
        color: border,
      ),
    );
  }

  static ThemeData dark({
    required double fontScale,
    required double contrastLevel,
    required double spacingScale,
  }) {
    final contrastT = _contrastNormalized(contrastLevel);
    final border = Color.lerp(
      const Color(0xFF374151),
      const Color(0xFFD1D5DB),
      contrastT,
    )!;
    final surface = Color.lerp(
      const Color(0xFF111827),
      const Color(0xFF000000),
      contrastT,
    )!;
    final surfaceMuted = Color.lerp(
      const Color(0xFF1F2937),
      const Color(0xFF0B1220),
      contrastT,
    )!;
    final base = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: _brandPrimary,
        onPrimary: Colors.white,
        secondary: _brandSecondary,
        onSecondary: Colors.black,
        error: const Color(0xFFEF4444),
        onError: Colors.white,
        surface: surface,
        onSurface: Color.lerp(
          const Color(0xFFE5E7EB),
          const Color(0xFFFFFFFF),
          contrastT,
        )!,
        outline: border,
        outlineVariant: Color.lerp(
          const Color(0xFF4B5563),
          const Color(0xFF9CA3AF),
          contrastT,
        ),
      ),
      useMaterial3: true,
    );

    final onSurface = Color.lerp(
      const Color(0xFFE5E7EB),
      const Color(0xFFFFFFFF),
      contrastT,
    )!;

    final textTheme = _scaledTextTheme(base.textTheme, fontScale).apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    );

    return base.copyWith(
      textTheme: textTheme,
      visualDensity: _visualDensity(spacingScale),
      scaffoldBackgroundColor: Color.lerp(
        const Color(0xFF030712),
        const Color(0xFF000000),
        contrastT,
      ),
      canvasColor: Color.lerp(
        const Color(0xFF030712),
        const Color(0xFF000000),
        contrastT,
      ),
      extensions: [
        AppThemeTokens(
          spacingScale: spacingScale,
          contrastLevel: contrastLevel,
          surface: surface,
          surfaceMuted: surfaceMuted,
          onSurfaceMuted: Color.lerp(
            const Color(0xFF9CA3AF),
            const Color(0xFFFFFFFF),
            contrastT,
          )!,
          border: border,
        ),
      ],
      cardTheme: base.cardTheme.copyWith(
        color: surface,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: surface,
        foregroundColor: onSurface,
      ),
      listTileTheme: base.listTileTheme.copyWith(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * spacingScale.clamp(0.8, 2.0),
          vertical: 2 * spacingScale.clamp(0.8, 2.0),
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: surfaceMuted,
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * spacingScale.clamp(0.8, 2.0),
          vertical: 14 * spacingScale.clamp(0.8, 2.0),
        ),
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        backgroundColor: surface,
        selectedItemColor: _brandSecondary,
        unselectedItemColor: Color.lerp(
          const Color(0xFF9CA3AF),
          const Color(0xFFE5E7EB),
          contrastT,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
      ),
    );
  }

  static TextTheme _scaledTextTheme(TextTheme theme, double scale) {
    return theme.copyWith(
      displayLarge: theme.displayLarge?.copyWith(
        fontSize: (theme.displayLarge?.fontSize ?? 57) * scale,
      ),
      displayMedium: theme.displayMedium?.copyWith(
        fontSize: (theme.displayMedium?.fontSize ?? 45) * scale,
      ),
      displaySmall: theme.displaySmall?.copyWith(
        fontSize: (theme.displaySmall?.fontSize ?? 36) * scale,
      ),
      headlineLarge: theme.headlineLarge?.copyWith(
        fontSize: (theme.headlineLarge?.fontSize ?? 32) * scale,
      ),
      headlineMedium: theme.headlineMedium?.copyWith(
        fontSize: (theme.headlineMedium?.fontSize ?? 28) * scale,
      ),
      headlineSmall: theme.headlineSmall?.copyWith(
        fontSize: (theme.headlineSmall?.fontSize ?? 24) * scale,
      ),
      titleLarge: theme.titleLarge?.copyWith(
        fontSize: (theme.titleLarge?.fontSize ?? 22) * scale,
      ),
      titleMedium: theme.titleMedium?.copyWith(
        fontSize: (theme.titleMedium?.fontSize ?? 16) * scale,
      ),
      titleSmall: theme.titleSmall?.copyWith(
        fontSize: (theme.titleSmall?.fontSize ?? 14) * scale,
      ),
      bodyLarge: theme.bodyLarge?.copyWith(
        fontSize: (theme.bodyLarge?.fontSize ?? 16) * scale,
      ),
      bodyMedium: theme.bodyMedium?.copyWith(
        fontSize: (theme.bodyMedium?.fontSize ?? 14) * scale,
      ),
      bodySmall: theme.bodySmall?.copyWith(
        fontSize: (theme.bodySmall?.fontSize ?? 12) * scale,
      ),
      labelLarge: theme.labelLarge?.copyWith(
        fontSize: (theme.labelLarge?.fontSize ?? 14) * scale,
      ),
      labelMedium: theme.labelMedium?.copyWith(
        fontSize: (theme.labelMedium?.fontSize ?? 12) * scale,
      ),
      labelSmall: theme.labelSmall?.copyWith(
        fontSize: (theme.labelSmall?.fontSize ?? 11) * scale,
      ),
    );
  }

  static VisualDensity _visualDensity(double spacingScale) {
    // Efeito de espaçamento mais perceptível no app inteiro.
    final adjustment = ((spacingScale - 1.0) * 1.6).clamp(-0.3, 1.2);
    return VisualDensity(horizontal: adjustment, vertical: adjustment);
  }

  static double _contrastNormalized(double contrastLevel) {
    return ((contrastLevel.clamp(1.0, 2.0) - 1.0) / 1.0).clamp(0.0, 1.0);
  }
}
