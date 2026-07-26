import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

/// A row of PIN dots that fill as digits are entered (design `.pdot`).
class PinDots extends StatelessWidget {
  const PinDots({
    super.key,
    required this.length,
    required this.filled,
    this.onBrand = false,
    this.error = false,
  });

  final int length;
  final int filled;

  /// When shown on a gradient (brand) background, dots are white.
  final bool onBrand;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final activeColor =
        error ? t.due : (onBrand ? Colors.white : t.brand2);
    final idleColor = onBrand
        ? Colors.white.withValues(alpha: 0.35)
        : t.text2.withValues(alpha: 0.3);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final on = i < filled;
        return Container(
          width: 13,
          height: 13,
          margin: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on ? activeColor : idleColor,
          ),
        );
      }),
    );
  }
}

/// The numeric keypad (design `.pinpad` / `.key`). Emits digits and a
/// backspace; an optional [trailing] slot holds a biometric shortcut.
class PinPad extends StatelessWidget {
  const PinPad({
    super.key,
    required this.onKey,
    required this.onBackspace,
    this.onBrand = false,
    this.trailing,
  });

  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;
  final bool onBrand;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var col = 0; col < 3; col++)
                  _Key(
                    label: keys[row * 3 + col],
                    onTap: () => onKey(keys[row * 3 + col]),
                    onBrand: onBrand,
                  ),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: Center(child: trailing ?? const SizedBox.shrink()),
            ),
            const SizedBox(width: 18),
            _Key(label: '0', onTap: () => onKey('0'), onBrand: onBrand),
            const SizedBox(width: 18),
            _Key(
              icon: Icons.backspace_outlined,
              onTap: onBackspace,
              onBrand: onBrand,
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({this.label, this.icon, required this.onTap, required this.onBrand});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool onBrand;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final bg = onBrand ? Colors.white.withValues(alpha: 0.16) : t.surface;
    final fg = onBrand ? Colors.white : t.text;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              boxShadow: onBrand ? null : t.shadowSm,
              border: (t.isDark && !onBrand) ? Border.all(color: t.line) : null,
            ),
            child: icon != null
                ? Icon(icon, color: fg, size: 24)
                : Text(
                    label!,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
