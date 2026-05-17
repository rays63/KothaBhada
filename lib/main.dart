import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'database/app_database.dart';
import 'services/rental_repository.dart';

export 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final database = AppDatabase();
  final repository = SqliteRentalRepository(database);

  runApp(MyApp(repository: repository));
}
