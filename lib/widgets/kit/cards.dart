import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';
import 'app_surface.dart';

/// Compact metric tile with a tinted icon, big value and caption
/// (design `.stat`). Used in the dashboard stat row.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    this.valueColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(AppTokens.rStat),
        boxShadow: t.shadowSm,
        border: t.isDark ? Border.all(color: t.line) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconPill(icon: icon, color: accent),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: valueColor ?? t.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: t.text2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic list-row card: leading widget, title/subtitle, trailing widget
/// (design `.card.listrow`). HouseCard / RoomCard / TenantCard build on it.
class ListRowCard extends StatelessWidget {
  const ListRowCard({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: t.text2),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}
