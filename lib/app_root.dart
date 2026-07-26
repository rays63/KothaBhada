import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/providers.dart';
import 'l10n/app_localizations.dart';
import 'screens/v2/security/app_gate.dart';
import 'theme/app_theme.dart';

/// Root of the redesigned (v2) Kothabhada app.
class KothaApp extends ConsumerWidget {
  const KothaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(prefsProvider);
    return MaterialApp(
      title: 'Kothabhada',
      debugShowCheckedModeBanner: false,
      themeMode: prefs.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: prefs.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AppGate(),
    );
  }
}
