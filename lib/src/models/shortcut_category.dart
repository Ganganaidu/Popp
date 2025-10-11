import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/product_utils.dart';

class ShortcutCategory {
  final String title;
  final IconData icon;
  final Color color;

  const ShortcutCategory({
    required this.title,
    required this.icon,
    required this.color,
  });
}

final List<ShortcutCategory> shortcutCategories = <ShortcutCategory>[
  const ShortcutCategory(
    title: ProductUtils.premiumBikes,
    icon: Icons.workspace_premium_outlined,
    color: Colors.amber,
  ),
  const ShortcutCategory(
    title: 'Bike Rentals',
    icon: Icons.two_wheeler_outlined,
    color: Colors.blueAccent,
  ),
  const ShortcutCategory(
    title: 'Accessories store',
    icon: Icons.event_available_outlined,
    color: Colors.deepPurpleAccent,
  ),
  const ShortcutCategory(
    title: ProductUtils.findMechanic,
    icon: Icons.headset_mic_outlined,
    color: Colors.teal,
  ),
  const ShortcutCategory(
    title: 'Track day',
    icon: Icons.flag_outlined,
    color: Colors.redAccent,
  ),
  const ShortcutCategory(
    title: 'Training day',
    icon: Icons.school_outlined,
    color: Colors.green,
  ),
];
