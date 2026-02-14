import 'package:flutter/material.dart';
import 'package:popp/src/theme/bikerverse_colors.dart';

final ThemeData poppLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.green,
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
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(Colors.green),
    trackColor: WidgetStateProperty.all(Colors.green.shade200),
  ),
  iconTheme: const IconThemeData(color: Colors.green),
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
  primaryColor: Colors.green,
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
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(Colors.green),
    trackColor: WidgetStateProperty.all(Colors.green.shade300),
  ),
  iconTheme: const IconThemeData(color: Colors.green),
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


final ThemeData bikerverseMobileTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: BikerverseColors.accent,
  scaffoldBackgroundColor: BikerverseColors.background,
  cardColor: BikerverseColors.card,
  dividerColor: BikerverseColors.outline,
  appBarTheme: const AppBarTheme(
    backgroundColor: BikerverseColors.background,
    foregroundColor: BikerverseColors.textPrimary,
    elevation: 0,
    centerTitle: false,
  ),
  colorScheme: const ColorScheme.dark(
    primary: BikerverseColors.accent,
    secondary: BikerverseColors.accent,
    surface: BikerverseColors.surface,
    background: BikerverseColors.background,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: BikerverseColors.textPrimary,
    onBackground: BikerverseColors.textPrimary,
    error: Color(0xFFE25C5C),
    onError: Colors.white,
  ),
  textTheme: const TextTheme(
    displayMedium: TextStyle(
      color: BikerverseColors.textPrimary,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.4,
    ),
    titleLarge: TextStyle(
      color: BikerverseColors.textPrimary,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
    titleMedium: TextStyle(
      color: BikerverseColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      color: BikerverseColors.textSecondary,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: BikerverseColors.textPrimary,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      color: BikerverseColors.textSecondary,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      color: BikerverseColors.textMuted,
    ),
    labelLarge: TextStyle(
      color: BikerverseColors.textPrimary,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.1,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: BikerverseColors.background,
    selectedItemColor: BikerverseColors.accent,
    unselectedItemColor: BikerverseColors.textMuted,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: BikerverseColors.card,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: BikerverseColors.accent,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: BikerverseColors.textPrimary,
      side: const BorderSide(color: BikerverseColors.outline),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: BikerverseColors.chipBg,
    selectedColor: BikerverseColors.accentSoft,
    labelStyle: const TextStyle(
      color: BikerverseColors.accent,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
    ),
    side: const BorderSide(color: BikerverseColors.chipBorder),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: BikerverseColors.cardElevated,
    hintStyle: const TextStyle(color: BikerverseColors.textMuted),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: BikerverseColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: BikerverseColors.accent, width: 1.2),
    ),
  ),
  iconTheme: const IconThemeData(color: BikerverseColors.textPrimary),
);
