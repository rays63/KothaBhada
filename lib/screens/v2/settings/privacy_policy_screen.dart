import 'package:flutter/material.dart';

import '../../../core/l10n_ext.dart';
import '../../../widgets/kit/kit.dart';
import '../widgets/screen_header.dart';

/// In-app privacy policy (required for Play Store even for offline apps that
/// use the camera/storage). Kothabhada is fully offline and collects nothing.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(title: l.privacyTitle),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
                children: [
                  Text(l.privacyUpdated,
                      style: TextStyle(fontSize: 12, color: t.text2)),
                  const SizedBox(height: 16),
                  _Section(title: l.privacyS1Title, body: l.privacyS1Body),
                  _Section(title: l.privacyS2Title, body: l.privacyS2Body),
                  _Section(title: l.privacyS3Title, body: l.privacyS3Body),
                  _Section(title: l.privacyS4Title, body: l.privacyS4Body),
                  _Section(title: l.privacyS5Title, body: l.privacyS5Body),
                  _Section(title: l.privacyS6Title, body: l.privacyS6Body),
                  const SizedBox(height: 8),
                  Text(
                    l.privacyFooter,
                    style: TextStyle(fontSize: 13, height: 1.6, color: t.text2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(body,
              style: TextStyle(fontSize: 14, height: 1.6, color: t.text2)),
        ],
      ),
    );
  }
}
