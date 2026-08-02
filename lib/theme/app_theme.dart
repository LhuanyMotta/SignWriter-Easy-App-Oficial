import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';
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

    // Escala de fonte fica só no MediaQuery (TextScaler) — evita escala dupla.
    final textTheme = base.textTheme.apply(
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
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border.withValues(alpha: 0.6), width: 1),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: _brandPrimary,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.10),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: -0.2,
        ),
        toolbarHeight: 60,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: _brandPrimary, width: 1.5),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _brandPrimary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        pressElevation: 0,
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brandPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * spacingScale.clamp(0.8, 2.0),
          vertical: 14 * spacingScale.clamp(0.8, 2.0),
        ),
        labelStyle: TextStyle(color: onSurfaceMuted),
        hintStyle: TextStyle(color: onSurfaceMuted.withValues(alpha: 0.7)),
        prefixIconColor: onSurfaceMuted,
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        selectedItemColor: _brandPrimary,
        unselectedItemColor: onSurfaceMuted,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: DividerThemeData(
        color: border.withValues(alpha: 0.7),
        thickness: 1,
        space: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData dark({
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

    // Escala de fonte fica só no MediaQuery (TextScaler) — evita escala dupla.
    final textTheme = base.textTheme.apply(
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
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border.withValues(alpha: 0.5), width: 1),
        ),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        titleTextStyle: TextStyle(
          color: onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: -0.2,
        ),
        toolbarHeight: 60,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandSecondary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: _brandSecondary, width: 1.5),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _brandSecondary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        pressElevation: 0,
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brandSecondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * spacingScale.clamp(0.8, 2.0),
          vertical: 14 * spacingScale.clamp(0.8, 2.0),
        ),
        hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.4)),
        prefixIconColor: onSurface.withValues(alpha: 0.5),
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        backgroundColor: surface,
        selectedItemColor: _brandSecondary,
        unselectedItemColor: Color.lerp(
          const Color(0xFF9CA3AF),
          const Color(0xFFE5E7EB),
          contrastT,
        ),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: DividerThemeData(
        color: border.withValues(alpha: 0.6),
        thickness: 1,
        space: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static VisualDensity _visualDensity(double spacingScale) {
    // Efeito de espaçamento mais perceptível no app inteiro.
    final adjustment = ((spacingScale - 1.0) * 1.6).clamp(-0.3, 1.2);
    return VisualDensity(horizontal: adjustment, vertical: adjustment);
  }

  /// Normaliza o contraste na mesma faixa da tela de acessibilidade (0.8–1.5).
  static double _contrastNormalized(double contrastLevel) {
    const minContrast = 0.8;
    const maxContrast = 1.5;

    final value = contrastLevel.clamp(minContrast, maxContrast);

    return ((value - minContrast) / (maxContrast - minContrast)).clamp(0.0, 1.0);
  }
}
