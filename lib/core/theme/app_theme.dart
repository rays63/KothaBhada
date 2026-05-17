import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF006565);
  static const Color primaryContainer = Color(0xFF008080);
  static const Color secondary = Color(0xFF35D66B);
  static const Color background = Color(0xFFF6F7FB);
  static const Color surfaceLow = Color(0xFFEEF2FF);
  static const Color surfaceHigh = Color(0xFFE2E9FB);
  static const Color ink = Color(0xFF141B2B);
  static const Color muted = Color(0xFF607087);
  static const Color due = Color(0xFFC71D29);
  static const Color partial = Color(0xFFF0A53A);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      surface: background,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    ).textTheme;

    final textTheme = GoogleFonts.interTextTheme(base).copyWith(
      headlineLarge: GoogleFonts.manrope(
        textStyle: base.headlineLarge,
        color: ink,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.4,
      ),
      headlineMedium: GoogleFonts.manrope(
        textStyle: base.headlineMedium,
        color: ink,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      ),
      headlineSmall: GoogleFonts.manrope(
        textStyle: base.headlineSmall,
        color: ink,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      titleLarge: GoogleFonts.manrope(
        textStyle: base.titleLarge,
        color: ink,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.manrope(
        textStyle: base.titleMedium,
        color: ink,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: GoogleFonts.inter(
        textStyle: base.bodyLarge,
        color: ink,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: GoogleFonts.inter(textStyle: base.bodyMedium, color: ink),
      bodySmall: GoogleFonts.inter(textStyle: base.bodySmall, color: muted),
      labelLarge: GoogleFonts.inter(
        textStyle: base.labelLarge,
        color: ink,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: GoogleFonts.inter(
        textStyle: base.labelMedium,
        color: muted,
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: GoogleFonts.inter(color: muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: surfaceHigh.withValues(alpha: 0.55)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: surfaceHigh.withValues(alpha: 0.55)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: primary.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
      ),
      dividerColor: Colors.transparent,
    );
  }

  static ThemeData dark() {
    final lightTheme = light();
    final darkScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: const Color(0xFF7DE2DF),
      secondary: secondary,
      surface: const Color(0xFF0F1725),
    );

    return lightTheme.copyWith(
      colorScheme: darkScheme,
      scaffoldBackgroundColor: const Color(0xFF0B1220),
      cardTheme: CardThemeData(
        color: const Color(0xFF131D2C),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            headlineLarge: GoogleFonts.manrope(
              textStyle: ThemeData.dark().textTheme.headlineLarge,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.4,
            ),
            headlineMedium: GoogleFonts.manrope(
              textStyle: ThemeData.dark().textTheme.headlineMedium,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
            ),
            headlineSmall: GoogleFonts.manrope(
              textStyle: ThemeData.dark().textTheme.headlineSmall,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            titleLarge: GoogleFonts.manrope(
              textStyle: ThemeData.dark().textTheme.titleLarge,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            titleMedium: GoogleFonts.manrope(
              textStyle: ThemeData.dark().textTheme.titleMedium,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            bodySmall: GoogleFonts.inter(
              textStyle: ThemeData.dark().textTheme.bodySmall,
              color: const Color(0xFFA6B2C6),
            ),
            labelMedium: GoogleFonts.inter(
              textStyle: ThemeData.dark().textTheme.labelMedium,
              color: const Color(0xFFA6B2C6),
              fontWeight: FontWeight.w600,
            ),
          ),
      inputDecorationTheme: lightTheme.inputDecorationTheme.copyWith(
        fillColor: const Color(0xFF131D2C),
      ),
    );
  }
}
