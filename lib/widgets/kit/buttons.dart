import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

enum AppButtonVariant { primary, outline, ghost, danger }

/// The design's button family — PrimaryButton (gradient), OutlineButton,
/// GhostButton and DangerButton — behind one widget with a [variant].
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.block = false,
    this.loading = false,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.block = false,
    this.loading = false,
  }) : variant = AppButtonVariant.primary;

  const AppButton.outline({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.block = false,
    this.loading = false,
  }) : variant = AppButtonVariant.outline;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.block = false,
    this.loading = false,
  }) : variant = AppButtonVariant.ghost;

  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.block = false,
    this.loading = false,
  }) : variant = AppButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool block;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final disabled = onPressed == null || loading;

    final Gradient? gradient;
    final Color fg;
    final Border? border;
    final List<BoxShadow> shadow;

    switch (variant) {
      case AppButtonVariant.primary:
        gradient = t.brandGradient;
        fg = Colors.white;
        border = null;
        shadow = [
          BoxShadow(
            color: t.brand2.withValues(alpha: 0.34),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ];
      case AppButtonVariant.danger:
        gradient = t.dangerGradient;
        fg = Colors.white;
        border = null;
        shadow = [
          BoxShadow(
            color: const Color(0xFFE5484D).withValues(alpha: 0.32),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ];
      case AppButtonVariant.outline:
        gradient = null;
        fg = t.brand2;
        border = Border.all(
          color: t.brand2.withValues(alpha: 0.55),
          width: 1.5,
        );
        shadow = const [];
      case AppButtonVariant.ghost:
        gradient = null;
        fg = t.text2;
        border = null;
        shadow = const [];
    }

    final child = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: fg,
                  ),
                ),
              ),
            ],
          );

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? Colors.transparent : null,
            borderRadius: BorderRadius.circular(AppTokens.rButton),
            border: border,
            boxShadow: disabled ? const [] : shadow,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTokens.rButton),
            onTap: disabled ? null : onPressed,
            child: Container(
              width: block ? double.infinity : null,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
