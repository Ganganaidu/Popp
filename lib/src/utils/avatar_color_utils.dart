import 'package:flutter/material.dart';

/// Deterministic color/initials assignment for name-only data (brands,
/// states, cities, …) that has no real logo/color of its own. The same
/// string always maps to the same color and initials within a run.
class AvatarColorUtils {
  AvatarColorUtils._();

  // Curated, dark-theme-safe palette. Deliberately excludes green so an
  // avatar is never confused with the app's "selected" accent color.
  static const List<Color> _palette = [
    Color(0xFFE57373), // red
    Color(0xFFFFB74D), // orange
    Color(0xFF64B5F6), // blue
    Color(0xFFBA68C8), // purple
    Color(0xFF4DB6AC), // teal
    Color(0xFFF06292), // pink
    Color(0xFF9575CD), // indigo
    Color(0xFFA1887F), // brown
  ];

  static Color colorFor(String key) {
    if (key.isEmpty) return _palette.first;
    return _palette[key.hashCode.abs() % _palette.length];
  }

  static String initialsFor(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';

    final words = trimmed.split(RegExp(r'\s+'));
    if (words.length > 1) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }

    final word = words.first;
    // Short, already-acronym-looking brand names (KTM, TVS, BMW, ...) read
    // better shown in full than truncated to their first letter.
    final isAcronymLike = word.length <= 4 && word == word.toUpperCase();
    if (isAcronymLike) return word;

    return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
  }
}
