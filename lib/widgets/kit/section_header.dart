import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

/// Row with a Manrope section title and an optional trailing text action
/// (design's "Your houses  ·  See all").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: t.brand2,
              ),
            ),
          ),
      ],
    );
  }
}

/// Uppercase brand eyebrow label (design `.eyebrow2`).
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        letterSpacing: 1.3,
        fontWeight: FontWeight.w700,
        color: t.brand2,
      ),
    );
  }
}
