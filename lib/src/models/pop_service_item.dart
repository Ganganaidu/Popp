import 'package:flutter/material.dart';

import '../deeplink/DeepLinkConfig.dart';
import '../services/shortcuts/shortcut_widgets.dart';

class PopServiceItem {
  final String? imageUrl;
  final String title;
  final String subTitle;
  final String action;
  final IconData? icon;
  final Color? color;
  final CustomPainter? customIconPainter;

  PopServiceItem({
    this.imageUrl,
    required this.title,
    required this.subTitle,
    required this.action,
    this.icon,
    this.color,
    this.customIconPainter,
  });
}

final List<PopServiceItem> items = [
  PopServiceItem(
    imageUrl: null,
    title: 'SELL',
    subTitle: "Bike",
    icon: Icons.motorcycle_outlined,
    action: sellYourBike,
    color: const Color(0xFF1B4332), // Dark Green
  ),
  PopServiceItem(
    imageUrl: null,
    title: 'SELL',
    subTitle: "Accessory",
    action: sellAccessory,
    icon: Icons.shopping_bag_outlined, // Bag icon
    customIconPainter: null,
    color: const Color(0xFF1E3A5F), // Dark Blue
  ),
  PopServiceItem(
    imageUrl: null,
    title: 'LIST',
    subTitle: "Business",
    action: listYourServices,
    icon: Icons.store_outlined, // Building icon
    customIconPainter: null,
    color: const Color(0xFF4A1E5C), // Dark Purple
  ),
  PopServiceItem(
    imageUrl: null,
    title: 'FIND',
    subTitle: "Mechanic",
    action: findMechanic,
    customIconPainter: SpeedometerIconPainter(color: Colors.white), // Keep custom if no good outline Icon
    color: const Color(0xFF6B4423), // Dark Brown
  ),
  PopServiceItem(
    imageUrl: null,
    title: 'TRACK DAY',
    subTitle: "Training",
    action: findTrackTraining,
    customIconPainter: FlagIconPainter(color: Colors.white),
    color: const Color(0xFF6B1E2E), // Dark Red
  ),
  PopServiceItem(
    imageUrl: null,
    title: 'BIKE',
    subTitle: "Rentals",
    action: findBikeRentals,
    customIconPainter: CalendarIconPainter(color: Colors.white),
    color: const Color(0xFF2E3A4A), // Dark Slate
  ),
  PopServiceItem(
    imageUrl: null,
    title: 'PREMIUM',
    subTitle: "Inspection",
    action: premiumBikeInspection,
    customIconPainter: VerifiedIconPainter(color: Colors.white),
    color: const Color(0xFF1B4332), // Dark Green
  ),
  PopServiceItem(
    imageUrl: null,
    title: 'TYRE',
    subTitle: "Shops",
    action: tyreShop,
    customIconPainter: TyreIconPainter(color: Colors.white),
    color: const Color(0xFF1E3A5F), // Dark Blue
  ),
  PopServiceItem(
    imageUrl: null,
    title: 'ACCESSORY',
    subTitle: "Store",
    action: accessoryStore,
    customIconPainter: StorefrontIconPainter(color: Colors.white),
    color: const Color(0xFF4A1E5C), // Dark Purple
  ),
];
