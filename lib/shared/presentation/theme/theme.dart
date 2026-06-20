import 'package:flutter/material.dart';

class AppTheme {
  // Color primario de la marca Cocina360 (navy), tomado del web-application.
  static const seedColor = Color(0xFF0E3B63);

  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      surface: Color(0xFFF7F9FC),
      brightness: Brightness.light,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      surface: Color(0xFF0F141A),
      brightness: Brightness.dark,
    ),
  );
}
