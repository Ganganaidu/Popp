import 'package:flutter/material.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  void toggle(bool isDark) => value = isDark ? ThemeMode.dark : ThemeMode.light;
}
