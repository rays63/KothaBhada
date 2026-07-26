import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n_ext.dart';
import '../../../data/providers.dart';
import '../../../widgets/kit/kit.dart';
import '../widgets/screen_header.dart';

/// Language toggle (design screen 34). Switches instantly, fully offline.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = context.l10n;
    final prefs = ref.watch(prefsProvider);
    final isNe = prefs.locale.languageCode == 'ne';

    void select(String code) =>
        ref.read(prefsProvider.notifier).setLocale(Locale(code));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(title: l.langTitle),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: SegmentedControl<bool>(
                value: isNe,
                segments: {false: l.langEnglish, true: l.langNepali},
                onChanged: (v) => select(v ? 'ne' : 'en'),
              ),
            ),
            const SizedBox(height: 16),
            _LangOption(
              title: l.langEnglish,
              subtitle: l.langDefault,
              selected: !isNe,
              onTap: () => select('en'),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: _LangOptionCard(
                title: l.langNepali,
                subtitle: l.langNepaliEn,
                selected: isNe,
                onTap: () => select('ne'),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: AppCard(
                color: t.isDark ? t.surface : t.surface2,
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: t.brand2),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l.langInfo,
                        style: TextStyle(
                            fontSize: 12, height: 1.5, color: t.text2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: _LangOptionCard(
          title: title, subtitle: subtitle, selected: selected, onTap: onTap),
    );
  }
}

class _LangOptionCard extends StatelessWidget {
  const _LangOptionCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, color: t.text2)),
              ],
            ),
          ),
          if (selected)
            Icon(Icons.check_rounded, color: t.brand2, size: 20),
        ],
      ),
    );
  }
}
