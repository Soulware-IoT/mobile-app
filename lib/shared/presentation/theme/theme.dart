import 'package:flutter/material.dart';

class AppTheme {
  static const seedColor = Color(0xFFDC652D);

  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      surface: Color(0xFFFBF6F2),
      brightness: Brightness.light,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      surface: Color(0xFF181611),
      brightness: Brightness.dark,
    ),
  );
}
