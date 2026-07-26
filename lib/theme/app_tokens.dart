import 'package:flutter/material.dart';

/// Design tokens for the Kothabhada v2 design system.
///
/// Values are transcribed 1:1 from the Claude Design mockup
/// ("Kothabhada App.dc.html" — Component & Token Reference). Every screen and
/// shared widget reads its colors, gradients and elevation from here via
/// `Theme.of(context).tokens`, so light and dark stay perfectly in sync.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.text,
    required this.text2,
    required this.line,
    required this.brand1,
    required this.brand2,
    required this.paid,
    required this.paidBg,
    required this.due,
    required this.dueBg,
    required this.partial,
    required this.partialBg,
    required this.coral,
    required this.sky,
    required this.violet,
    required this.amber,
    required this.shadow,
    required this.shadowSm,
  });

  final Brightness brightness;

  final Color bg;
  final Color surface;
  final Color surface2;
  final Color text;
  final Color text2;

  /// Hairline border color (used for card/nav borders, dividers).
  final Color line;

  /// Brand gradient stops (deep teal → emerald).
  final Color brand1;
  final Color brand2;

  final Color paid;
  final Color paidBg;
  final Color due;
  final Color dueBg;
  final Color partial;
  final Color partialBg;

  // Accents.
  final Color coral;
  final Color sky;
  final Color violet;
  final Color amber;

  /// Card / floating-element elevation. Empty in dark (borders + glows instead).
  final List<BoxShadow> shadow;
  final List<BoxShadow> shadowSm;

  bool get isDark => brightness == Brightness.dark;

  /// Primary brand gradient, top-left → bottom-right (≈135°).
  LinearGradient get brandGradient => LinearGradient(
        colors: [brand1, brand2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// The coral→amber danger gradient used by DangerButton.
  LinearGradient get dangerGradient => LinearGradient(
        colors: isDark
            ? const [Color(0xFFE5484D), Color(0xFFF87171)]
            : const [Color(0xFFE5484D), Color(0xFFF87171)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// A translucent tint of any accent (mirrors CSS `color-mix(... 15%)`).
  Color tint(Color color, [double opacity = 0.15]) =>
      color.withValues(alpha: opacity);

  // ── Radius scale (px) ─────────────────────────────────────────────
  static const double rCard = 18;
  static const double rStat = 16;
  static const double rButton = 14;
  static const double rInput = 12;
  static const double rAvatar = 13;
  static const double rIconPill = 12;
  static const double rNav = 26;
  static const double rPill = 999;

  // ── Spacing scale (px) ────────────────────────────────────────────
  static const double padScreen = 22;
  static const double padCard = 16;
  static const double gap = 12;

  static const AppTokens lightTokens = AppTokens(
    brightness: Brightness.light,
    bg: Color(0xFFF6F7FB),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFFBFDFC),
    text: Color(0xFF1C1F26),
    text2: Color(0xFF8B93A1),
    line: Color(0x141C1F26), // rgba(28,31,38,0.08)
    brand1: Color(0xFF0F6E5C),
    brand2: Color(0xFF12A66E),
    paid: Color(0xFF1FAE64),
    paidBg: Color(0x1F1FAE64), // 0.12
    due: Color(0xFFE5484D),
    dueBg: Color(0x1FE5484D), // 0.12
    partial: Color(0xFFF5A623),
    partialBg: Color(0x24F5A623), // 0.14
    coral: Color(0xFFFF6B6B),
    sky: Color(0xFF4D96FF),
    violet: Color(0xFF8B5CF6),
    amber: Color(0xFFFFB020),
    shadow: [
      BoxShadow(
        color: Color(0x1A1C1F26), // rgba(28,31,38,0.10)
        blurRadius: 30,
        offset: Offset(0, 10),
      ),
    ],
    shadowSm: [
      BoxShadow(
        color: Color(0x0F1C1F26), // rgba(28,31,38,0.06)
        blurRadius: 14,
        offset: Offset(0, 4),
      ),
    ],
  );

  static const AppTokens darkTokens = AppTokens(
    brightness: Brightness.dark,
    bg: Color(0xFF0F1115),
    surface: Color(0xFF1A1D24),
    surface2: Color(0xFF20242C),
    text: Color(0xFFF2F4F7),
    text2: Color(0xFF8B93A1),
    line: Color(0x17FFFFFF), // rgba(255,255,255,0.09)
    brand1: Color(0xFF14A085),
    brand2: Color(0xFF34D399),
    paid: Color(0xFF34D399),
    paidBg: Color(0x2934D399), // 0.16
    due: Color(0xFFF87171),
    dueBg: Color(0x29F87171),
    partial: Color(0xFFFBBF24),
    partialBg: Color(0x29FBBF24),
    coral: Color(0xFFFF8787),
    sky: Color(0xFF6DAAFF),
    violet: Color(0xFFA78BFA),
    amber: Color(0xFFFFC94D),
    shadow: [
      BoxShadow(
        color: Color(0x66000000), // rgba(0,0,0,0.4)
        blurRadius: 30,
        offset: Offset(0, 10),
      ),
    ],
    shadowSm: [], // dark uses borders + glows, no soft shadow
  );

  @override
  AppTokens copyWith({
    Brightness? brightness,
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? text,
    Color? text2,
    Color? line,
    Color? brand1,
    Color? brand2,
    Color? paid,
    Color? paidBg,
    Color? due,
    Color? dueBg,
    Color? partial,
    Color? partialBg,
    Color? coral,
    Color? sky,
    Color? violet,
    Color? amber,
    List<BoxShadow>? shadow,
    List<BoxShadow>? shadowSm,
  }) {
    return AppTokens(
      brightness: brightness ?? this.brightness,
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      text: text ?? this.text,
      text2: text2 ?? this.text2,
      line: line ?? this.line,
      brand1: brand1 ?? this.brand1,
      brand2: brand2 ?? this.brand2,
      paid: paid ?? this.paid,
      paidBg: paidBg ?? this.paidBg,
      due: due ?? this.due,
      dueBg: dueBg ?? this.dueBg,
      partial: partial ?? this.partial,
      partialBg: partialBg ?? this.partialBg,
      coral: coral ?? this.coral,
      sky: sky ?? this.sky,
      violet: violet ?? this.violet,
      amber: amber ?? this.amber,
      shadow: shadow ?? this.shadow,
      shadowSm: shadowSm ?? this.shadowSm,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      brightness: t < 0.5 ? brightness : other.brightness,
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      text: Color.lerp(text, other.text, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      line: Color.lerp(line, other.line, t)!,
      brand1: Color.lerp(brand1, other.brand1, t)!,
      brand2: Color.lerp(brand2, other.brand2, t)!,
      paid: Color.lerp(paid, other.paid, t)!,
      paidBg: Color.lerp(paidBg, other.paidBg, t)!,
      due: Color.lerp(due, other.due, t)!,
      dueBg: Color.lerp(dueBg, other.dueBg, t)!,
      partial: Color.lerp(partial, other.partial, t)!,
      partialBg: Color.lerp(partialBg, other.partialBg, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      sky: Color.lerp(sky, other.sky, t)!,
      violet: Color.lerp(violet, other.violet, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      shadow: t < 0.5 ? shadow : other.shadow,
      shadowSm: t < 0.5 ? shadowSm : other.shadowSm,
    );
  }
}

/// Ergonomic access: `Theme.of(context).tokens` and `context.tokens`.
extension AppTokensThemeData on ThemeData {
  AppTokens get tokens => extension<AppTokens>() ?? AppTokens.lightTokens;
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens =>
      Theme.of(this).extension<AppTokens>() ?? AppTokens.lightTokens;

  /// Convenience for the app's Manrope display styles.
  TextTheme get texts => Theme.of(this).textTheme;
}
