import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tcompro/shared/presentation/di/dependency_injector_widget.dart';
import 'package:tcompro/shared/presentation/session/session_guard.dart';

import 'shared/infrastructure/remote/supabase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await initializeSupabase();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DependencyInjectorWidget(
      child: MaterialApp(
        title: "T'Compro",
        debugShowCheckedModeBanner: true,
        home: SessionGuard(),
      ),
    );
  }
}
