import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// Builds the light and dark [ThemeData] for the Kothabhada v2 design system.
///
/// Typography: Manrope (display/headings, 700–800) over Inter (body/labels).
/// Every [ThemeData] carries an [AppTokens] extension so widgets can read the
/// full semantic palette via `context.tokens`.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(AppTokens.lightTokens);
  static ThemeData dark() => _build(AppTokens.darkTokens);

  static ThemeData _build(AppTokens t) {
    final isDark = t.isDark;
    final scheme = ColorScheme(
      brightness: t.brightness,
      primary: t.brand2,
      onPrimary: Colors.white,
      primaryContainer: t.brand1,
      onPrimaryContainer: Colors.white,
      secondary: t.sky,
      onSecondary: Colors.white,
      error: t.due,
      onError: Colors.white,
      surface: t.surface,
      onSurface: t.text,
      surfaceContainerHighest: t.surface2,
      onSurfaceVariant: t.text2,
      outline: t.line,
    );

    final baseText = isDark
        ? ThemeData(brightness: Brightness.dark).textTheme
        : ThemeData(brightness: Brightness.light).textTheme;

    TextStyle manrope(double size, FontWeight weight, {double spacing = -0.4}) =>
        TextStyle(
          fontFamily: 'Manrope',
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          color: t.text,
          height: 1.15,
        );
    TextStyle inter(double size, FontWeight weight, {Color? color}) =>
        TextStyle(
          fontFamily: 'Inter',
          fontSize: size,
          fontWeight: weight,
          color: color ?? t.text,
          height: 1.4,
        );

    final textTheme = baseText.apply(fontFamily: 'Inter').copyWith(
      displayLarge: manrope(34, FontWeight.w800, spacing: -0.8),
      displayMedium: manrope(30, FontWeight.w800, spacing: -0.6),
      displaySmall: manrope(26, FontWeight.w800),
      headlineMedium: manrope(23, FontWeight.w800),
      headlineSmall: manrope(20, FontWeight.w800),
      titleLarge: manrope(18, FontWeight.w700, spacing: -0.2),
      titleMedium: manrope(16, FontWeight.w700, spacing: -0.2),
      titleSmall: manrope(14, FontWeight.w700, spacing: 0),
      bodyLarge: inter(15, FontWeight.w500),
      bodyMedium: inter(14, FontWeight.w400),
      bodySmall: inter(12, FontWeight.w500, color: t.text2),
      labelLarge: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      labelMedium: inter(12, FontWeight.w600, color: t.text2),
      labelSmall: inter(11, FontWeight.w700, color: t.text2),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: t.brightness,
      colorScheme: scheme,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: t.bg,
      canvasColor: t.bg,
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      extensions: [t],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: t.text,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      dividerTheme: DividerThemeData(color: t.line, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: t.text, size: 22),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: t.isDark ? t.surface2 : t.text,
        contentTextStyle: inter(13, FontWeight.w600,
            color: t.isDark ? t.text : Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.rButton),
        ),
      ),
    );
  }
}
