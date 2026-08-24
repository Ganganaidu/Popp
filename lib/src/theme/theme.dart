import 'package:flutter/material.dart';
import 'package:popp/src/theme/bikerverse_colors.dart';

final ThemeData bikerverseDarkTheme = ThemeData(
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
    onPrimary: BikerverseColors.onGreen,
    onSecondary: BikerverseColors.onGreen,
    onSurface: BikerverseColors.textPrimary,
    onBackground: BikerverseColors.textPrimary,
    error: Color(0xFFE25C5C),
    onError: Colors.white,
    outline: BikerverseColors.outline,
    outlineVariant: BikerverseColors.divider,
    surfaceContainerHighest: BikerverseColors.card,
    shadow: Colors.black,
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
      foregroundColor: BikerverseColors.onGreen,
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

final ThemeData bikerverseLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: BikerverseColors.accent,
  scaffoldBackgroundColor: BikerverseColors.lightBackground,
  cardColor: BikerverseColors.lightCard,
  dividerColor: BikerverseColors.lightOutline,
  appBarTheme: const AppBarTheme(
    backgroundColor: BikerverseColors.lightBackground,
    foregroundColor: BikerverseColors.lightTextPrimary,
    elevation: 0,
    centerTitle: false,
  ),
  colorScheme: const ColorScheme.light(
    primary: BikerverseColors.accent,
    secondary: BikerverseColors.accent,
    surface: BikerverseColors.lightSurface,
    background: BikerverseColors.lightBackground,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: BikerverseColors.lightTextPrimary,
    onBackground: BikerverseColors.lightTextPrimary,
    error: Color(0xFFE25C5C),
    onError: Colors.white,
    outline: BikerverseColors.lightOutline,
    outlineVariant: Color(0xFFEEEEEE),
    surfaceContainerHighest: BikerverseColors.lightCardElevated,
    shadow: Colors.black,
  ),
  textTheme: const TextTheme(
    displayMedium: TextStyle(
      color: BikerverseColors.lightTextPrimary,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.4,
    ),
    titleLarge: TextStyle(
      color: BikerverseColors.lightTextPrimary,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
    titleMedium: TextStyle(
      color: BikerverseColors.lightTextPrimary,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      color: BikerverseColors.lightTextSecondary,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: BikerverseColors.lightTextPrimary,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      color: BikerverseColors.lightTextSecondary,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      color: BikerverseColors.lightTextMuted,
    ),
    labelLarge: TextStyle(
      color: BikerverseColors.lightTextPrimary,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.1,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: BikerverseColors.lightBackground,
    selectedItemColor: BikerverseColors.accent,
    unselectedItemColor: BikerverseColors.lightTextMuted,
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
    color: BikerverseColors.lightCard,
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
      foregroundColor: BikerverseColors.lightTextPrimary,
      side: const BorderSide(color: BikerverseColors.lightOutline),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: BikerverseColors.lightChipBg,
    selectedColor: BikerverseColors.lightChipBorder, // Use border color as accent for light
    labelStyle: const TextStyle(
      color: BikerverseColors.accentSoft,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
    ),
    side: const BorderSide(color: BikerverseColors.lightChipBorder),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: BikerverseColors.lightCardElevated,
    hintStyle: const TextStyle(color: BikerverseColors.lightTextMuted),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: BikerverseColors.lightOutline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: BikerverseColors.accent, width: 1.2),
    ),
  ),
  iconTheme: const IconThemeData(color: BikerverseColors.lightTextPrimary),
);
