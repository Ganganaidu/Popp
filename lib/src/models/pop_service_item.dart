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
  final double width;
  final double height;

  PopServiceItem({
    this.imageUrl,
    required this.title,
    required this.subTitle,
    required this.action,
    this.icon,
    this.color,
    this.customIconPainter,
    this.width = 80,
    this.height = 80,
  });
}

final List<PopServiceItem> popServiceItemList = [
  PopServiceItem(
    imageUrl: "assets/sell_your_bike.png",
    title: 'SELL',
    subTitle: "Bike",
    icon: Icons.motorcycle_outlined,
    action: sellYourBike,
    color: const Color(0xFF2E7D32), // Green
  ),
  PopServiceItem(
      imageUrl: "assets/sell_your_accessory.png",
      title: 'SELL',
      subTitle: "Accessory",
      action: sellAccessory,
      // Icon: Shopping Bag
      icon: Icons.shopping_bag_outlined,
      customIconPainter: null,
      // Gradient: Dark Blue to Light Blue
      color: const Color(0xFF1565C0),
      // Blue
      width: 90,
      height: 90),
  PopServiceItem(
    imageUrl: "assets/list_your_business.png",
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
      imageUrl: "assets/find_mechanic.png",
      title: 'FIND',
      subTitle: "Mechanic",
      action: findMechanic,
      icon: Icons.speed,
      customIconPainter: null,
      color: const Color(0xFFD84315),
      width: 120,
      height: 120),
  PopServiceItem(
      imageUrl: 'assets/track_training_day.png',
      title: 'TRACK DAY',
      subTitle: "Training",
      action: findTrackTraining,
      customIconPainter: FlagIconPainter(color: Colors.white),
      color: const Color(0xFFC62828),
      // Red
      width: 120,
      height: 120),
  PopServiceItem(
      imageUrl: 'assets/bike_rentals.png',
      title: 'BIKE',
      subTitle: "Rentals",
      action: findBikeRentals,
      color: const Color(0xFF455A64),
      // Blue Grey
      width: 120,
      height: 120),
  PopServiceItem(
    imageUrl: "assets/premium_bike_inspection.png",
    title: 'SUPER BIKE',
    subTitle: "Inspection",
    action: premiumBikeInspection,
    customIconPainter: VerifiedIconPainter(color: Colors.white),
    color: const Color(0xFF064302), // Green
  ),
  PopServiceItem(
    imageUrl: "assets/tyre_shops.png",
    title: 'TYRE',
    subTitle: "Shops",
    action: tyreShop,
    customIconPainter: TyreIconPainter(color: Colors.white),
    color: const Color(0xFF1565C0), // Blue
  ),
  PopServiceItem(
    imageUrl: "assets/accessory_store.png",
    title: 'ACCESSORY',
    subTitle: "Store",
    action: accessoryStore,
    customIconPainter: StorefrontIconPainter(color: Colors.white),
    color: const Color(0xFF610283), // Purple
  ),
  PopServiceItem(
      imageUrl: "assets/towing_service.png",
      title: 'TOWING',
      subTitle: "service",
      action: towingService,
      customIconPainter: StorefrontIconPainter(color: Colors.white),
      color: const Color(0xFF4F6E02),
      width: 120,
      height: 120),
];
