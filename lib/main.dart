import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tcompro/shared/infrastructure/local/database.dart';
import 'package:tcompro/shared/infrastructure/local/database_key_store.dart';
import 'package:tcompro/shared/presentation/di/dependency_injector_widget.dart';
import 'package:tcompro/shared/presentation/router/app_router.dart';
import 'package:tcompro/shared/presentation/theme/theme.dart';

import 'shared/infrastructure/remote/supabase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  final String supabaseUrl = await initializeSupabase();

  const secureStorage = FlutterSecureStorage();
  final database = await openAppDatabase(const DatabaseKeyStore(secureStorage));

  runApp(
    MainApp(
      supabaseUrl: supabaseUrl,
      secureStorage: secureStorage,
      database: database,
    ),
  );
}

class MainApp extends StatelessWidget {
  final String supabaseUrl;
  final FlutterSecureStorage secureStorage;
  final AppDatabase database;

  const MainApp({
    super.key,
    required this.supabaseUrl,
    required this.secureStorage,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    return DependencyInjectorWidget(
      supabaseUrl: supabaseUrl,
      secureStorage: secureStorage,
      database: database,
      child: Builder(
        builder: (context) => MaterialApp.router(
          title: "T'Compro",
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          debugShowCheckedModeBanner: true,
          routerConfig: createRouter(context),
        ),
      ),
    );
  }
}
