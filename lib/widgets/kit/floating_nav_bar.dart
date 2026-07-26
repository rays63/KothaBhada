import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

class NavDestination {
  const NavDestination({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// The floating rounded bottom navigation bar (design `.navbar`). The selected
/// item becomes a gradient pill with icon + label.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelected,
    required this.destinations,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;
  final List<NavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: t.isDark
            ? Color.alphaBlend(Colors.black.withValues(alpha: 0.08), t.surface)
            : t.surface,
        borderRadius: BorderRadius.circular(AppTokens.rNav),
        boxShadow: t.shadow,
        border: t.isDark ? Border.all(color: t.line) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < destinations.length; i++)
            _NavItem(
              destination: destinations[i],
              selected: i == currentIndex,
              onTap: () => onSelected(i),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? t.brandGradient : null,
          borderRadius: BorderRadius.circular(AppTokens.rPill),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: t.brand2.withValues(alpha: 0.34),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              destination.icon,
              size: 20,
              color: selected ? Colors.white : t.text2,
            ),
            const SizedBox(height: 3),
            Text(
              destination.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : t.text2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
