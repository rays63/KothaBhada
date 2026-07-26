import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

enum StatusKind { paid, due, partial, neutral, brand }

/// Pill status chip (design `.chip`) — paid / due / partial / neutral / brand.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.kind, this.icon});

  final String label;
  final StatusKind kind;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (Color bg, Color fg) = switch (kind) {
      StatusKind.paid => (t.paidBg, t.paid),
      StatusKind.due => (t.dueBg, t.due),
      StatusKind.partial => (t.partialBg, t.partial),
      StatusKind.neutral => (t.text2.withValues(alpha: 0.16), t.text2),
      StatusKind.brand => (t.brand2.withValues(alpha: 0.15), t.brand2),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTokens.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
