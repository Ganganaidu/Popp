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
    color: const Color(0xFF2E7D32), // Green
  ),
  PopServiceItem(
    imageUrl: null,
    title: 'SELL',
    subTitle: "Accessory",
    action: sellAccessory,
    // Icon: Shopping Bag
    icon: Icons.shopping_bag_outlined,
    customIconPainter: null,
    // Gradient: Dark Blue to Light Blue
    color: const Color(0xFF1565C0), // Blue
  ),
  PopServiceItem(
    imageUrl: null,
    title: 'LIST',
    subTitle: "Business",
    action: listYourServices,
    // Icon: Briefcase / Business Center
    icon: Icons.work_outline,
    customIconPainter: null,
    // Gradient: Purple to Pinkish
    color: const Color(0xFF9006E3), // Purple
  ),
  PopServiceItem(
    imageUrl: null,
    title: 'FIND',
    subTitle: "Mechanic",
    action: findMechanic,
    icon: Icons.speed, 
    customIconPainter: null, 
    // Gradient: Brown/Orange
    color: const Color(0xFFD84315), // Burnt Orange/Brown
  ),
  PopServiceItem(
    imageUrl: null,
    title: 'TRACK DAY',
    subTitle: "Training",
    action: findTrackTraining,
    customIconPainter: FlagIconPainter(color: Colors.white),
    color: const Color(0xFFC62828), // Red
  ),
  PopServiceItem(
    imageUrl: null,
    title: 'BIKE',
    subTitle: "Rentals",
    action: findBikeRentals,
    customIconPainter: CalendarIconPainter(color: Colors.white),
    color: const Color(0xFF455A64), // Blue Grey
  ),
  PopServiceItem(
    imageUrl: null,
    title: 'PREMIUM',
    subTitle: "Inspection",
    action: premiumBikeInspection,
    customIconPainter: VerifiedIconPainter(color: Colors.white),
    color: const Color(0xFF064302), // Green
  ),
  PopServiceItem(
    imageUrl: null,
    title: 'TYRE',
    subTitle: "Shops",
    action: tyreShop,
    customIconPainter: TyreIconPainter(color: Colors.white),
    color: const Color(0xFF1565C0), // Blue
  ),
  PopServiceItem(
    imageUrl: null,
    title: 'ACCESSORY',
    subTitle: "Store",
    action: accessoryStore,
    customIconPainter: StorefrontIconPainter(color: Colors.white),
    color: const Color(0xFF610283), // Purple
  ),
];
