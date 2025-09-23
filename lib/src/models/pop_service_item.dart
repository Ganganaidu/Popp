import '../deeplink/DeepLinkConfig.dart';

class PopServiceItem {
  final String? imageUrl;
  final String title;
  final String assetImageUrl;
  final String action;

  PopServiceItem({
    this.imageUrl,
    required this.title,
    required this.assetImageUrl,
    required this.action,
  });
}

final List<PopServiceItem> items = [
  PopServiceItem(
      imageUrl: null,
      title: 'Sell bike',
      assetImageUrl: "assets/sell_your_bike.png",
      action: sellYourBike),
  PopServiceItem(
      imageUrl: null,
      title: 'Sell accessory',
      assetImageUrl: "assets/sell_your_accessories.png",
      action: sellAccessory),
  PopServiceItem(
      imageUrl: null,
      title: 'List your business',
      assetImageUrl: "assets/list_your_services.png",
      action: listYourServices),
  PopServiceItem(
      imageUrl: null,
      title: 'Find Mechanic',
      assetImageUrl: "assets/book_your_services.png",
      action: findYourMechanic),
  PopServiceItem(
      imageUrl: null,
      title: 'Track day & Training ',
      assetImageUrl: "assets/book_track_trainings.png",
      action: findTrackTraining),
  PopServiceItem(
      imageUrl: null,
      title: 'Bike rentals',
      assetImageUrl: "assets/find_bike_rentals.png",
      action: findBikeRentals),
  PopServiceItem(
      imageUrl: null,
      title: 'Premium Bike Inspection',
      assetImageUrl: "assets/premium_bike_inspections.png",
      action: premiumBikeInspection),
];
