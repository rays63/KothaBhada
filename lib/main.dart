import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_root.dart';
import 'data/database/app_database.dart';
import 'data/notification_service.dart';
import 'data/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Demo houses/tenants are seeded only in debug/profile. Release builds
  // (Play Store) start with an empty database — no placeholder data.
  final database = AppDatabase(seedOnCreate: !kReleaseMode);
  // Warm the connection so the first frame has data ready.
  await database.db;

  final notifications = NotificationService();
  await notifications.init();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const KothaApp(),
    ),
  );
}
