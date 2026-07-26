import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// Ergonomic access to localized strings: `context.l10n.dashHouses`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
