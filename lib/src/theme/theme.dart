import 'package:flutter/material.dart';

final ThemeData poppLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.orange,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87, //#0C0F0E
    elevation: 0,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black87),
    titleLarge: TextStyle(color: Colors.black87),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(Colors.orange),
    trackColor: WidgetStateProperty.all(Colors.orange.shade200),
  ),
  iconTheme: const IconThemeData(color: Colors.orange),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(color: Colors.black54),
  ),
  cardTheme: const CardThemeData(elevation: 2, color: Colors.white),
);

final ThemeData poppDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.orange,
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900],
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    titleLarge: TextStyle(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(Colors.orange),
    trackColor: WidgetStateProperty.all(Colors.orange.shade300),
  ),
  iconTheme: const IconThemeData(color: Colors.orange),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[800],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(color: Colors.white54),
  ),
  cardTheme: const CardThemeData(elevation: 2, color: Colors.black),
);
