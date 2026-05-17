import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/app_controller.dart';
import 'screens/root_shell.dart';
import 'services/rental_repository.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.repository});

  final RentalRepository repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppController(repository)..load(),
      child: Consumer<AppController>(
        builder: (context, controller, _) {
          return MaterialApp(
            title: 'Kothabhada',
            debugShowCheckedModeBanner: false,
            themeMode: controller.themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const RootShell(),
          );
        },
      ),
    );
  }
}
