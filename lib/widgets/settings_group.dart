import 'package:flutter/material.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 18),
          ..._withSpacing(children),
        ],
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> items) {
    final spaced = <Widget>[];
    for (var index = 0; index < items.length; index++) {
      spaced.add(items[index]);
      if (index != items.length - 1) {
        spaced.add(const SizedBox(height: 18));
      }
    }
    return spaced;
  }
}
