import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.dark);

  static const _themeModeKey = 'themeMode';

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeModeKey) ?? true; // Default to dark
    value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggle(bool isDark) async {
    value = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeModeKey, isDark);
  }
}
