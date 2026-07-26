import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';
import 'app_surface.dart';

/// A brand-gradient panel with an optional soft glow — the base for the
/// dashboard "Collected this month" hero and gradient screens.
class GradientPanel extends StatelessWidget {
  const GradientPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 20,
    this.glow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(
        gradient: t.brandGradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: t.brand2.withValues(alpha: 0.36),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            if (glow)
              Positioned(
                top: -60,
                right: -30,
                child: GlowBlob(color: const Color(0xFF5EEAD4), opacity: 0.4),
              ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// Rounded progress bar (design's collection-rate meter). On a gradient
/// surface pass [onBrand] for the white-on-translucent variant.
class BrandProgressBar extends StatelessWidget {
  const BrandProgressBar({
    super.key,
    required this.value,
    this.height = 7,
    this.onBrand = false,
  });

  /// 0.0 – 1.0
  final double value;
  final double height;
  final bool onBrand;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final track = onBrand
        ? Colors.white.withValues(alpha: 0.25)
        : t.text2.withValues(alpha: 0.18);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(height: height, color: track),
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: onBrand ? Colors.white : null,
                gradient: onBrand ? null : t.brandGradient,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
