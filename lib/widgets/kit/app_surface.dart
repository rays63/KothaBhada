import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

/// A surface card: rounded [AppTokens.rCard], soft shadow in light, hairline
/// border in dark. The base container for most content in the design.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTokens.padCard),
    this.radius = AppTokens.rCard,
    this.onTap,
    this.color,
    this.border,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? color;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final decoration = BoxDecoration(
      color: color ?? t.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: t.shadowSm,
      border: border ??
          (t.isDark ? Border.all(color: t.line) : null),
    );
    final content = Padding(padding: padding, child: child);
    if (onTap == null) {
      return DecoratedBox(decoration: decoration, child: content);
    }
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: content,
        ),
      ),
    );
  }
}

/// A rounded 40×40 tinted container holding a small icon (design `.iconpill`).
class IconPill extends StatelessWidget {
  const IconPill({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.iconSize = 18,
    this.tintOpacity = 0.16,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final double tintOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: tintOpacity),
        borderRadius: BorderRadius.circular(AppTokens.rIconPill),
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}

/// A gradient avatar showing initials (design `.avatar`).
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.label,
    this.gradient,
    this.size = 42,
    this.radius = AppTokens.rAvatar,
  });

  final String label;
  final Gradient? gradient;
  final double size;
  final double radius;

  /// Deterministic accent gradient from a seed string, drawn from the
  /// design's accent palette (coral/amber, sky/violet, brand/sky …).
  static Gradient gradientFor(String seed, AppTokens t) {
    final palettes = <List<Color>>[
      [t.coral, t.amber],
      [t.sky, t.violet],
      [t.brand2, t.sky],
      [t.violet, t.coral],
      [t.brand1, t.brand2],
      [t.amber, t.coral],
    ];
    final index = seed.isEmpty ? 0 : seed.codeUnits.reduce((a, b) => a + b);
    final colors = palettes[index % palettes.length];
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  String get _initials {
    final parts = label.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return p.substring(0, p.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: gradient ?? gradientFor(label, t),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        _initials,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// A soft radial "glow" blob used behind gradient hero surfaces
/// (approximates the CSS `filter: blur` glow).
class GlowBlob extends StatelessWidget {
  const GlowBlob({
    super.key,
    required this.color,
    this.size = 160,
    this.opacity = 0.4,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
