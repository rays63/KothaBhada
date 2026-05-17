import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.title, this.actionLabel});

  final String title;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        if (actionLabel != null)
          Text(
            actionLabel!,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppTheme.primary),
          ),
      ],
    );
  }
}
