import 'package:flutter/material.dart';

import '../../../core/l10n_ext.dart';
import '../../../widgets/kit/kit.dart';
import '../widgets/screen_header.dart';
import 'privacy_policy_screen.dart';

/// About (design screen 38).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _version = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(title: l.settingsAbout),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: t.brandGradient,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: t.brand2.withValues(alpha: 0.34),
                            blurRadius: 26,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.home_work_rounded,
                          color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text('Kothabhada',
                        style: Theme.of(context).textTheme.headlineMedium),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(l.aboutVersion(_version),
                        style: TextStyle(fontSize: 13, color: t.text2)),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _aboutLine(
                            context, Icons.wifi_off_rounded, l.aboutOffline),
                        const SizedBox(height: 12),
                        _aboutLine(
                            context, Icons.lock_outline_rounded, l.aboutData),
                        const SizedBox(height: 12),
                        _aboutLine(context, Icons.favorite_border_rounded,
                            l.aboutMade),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton.outline(
                    label: l.aboutPrivacy,
                    icon: Icons.privacy_tip_outlined,
                    block: true,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(l.aboutCopyright,
                        style: TextStyle(fontSize: 12, color: t.text2)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aboutLine(BuildContext context, IconData icon, String text) {
    final t = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: t.brand2),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 13, height: 1.5, color: t.text)),
        ),
      ],
    );
  }
}
