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
      title: 'Sell your bike',
      assetImageUrl: "assets/sell_your_bike.png",
      action: sellYourBike),
  PopServiceItem(
      imageUrl: null,
      title: 'Sell your accessory',
      assetImageUrl: "assets/sell_your_accessories.png",
      action: sellAccessory),
  PopServiceItem(
      imageUrl: null,
      title: 'Find your Mechanic',
      assetImageUrl: "assets/book_your_services.png",
      action: findYourMechanic),
  PopServiceItem(
      imageUrl: null,
      title: 'Find track day & Training ',
      assetImageUrl: "assets/book_track_trainings.png",
      action: findTrackTraining),
  PopServiceItem(
      imageUrl: null,
      title: 'Find bike rentals',
      assetImageUrl: "assets/find_bike_rentals.png",
      action: findBikeRentals),
  PopServiceItem(
      imageUrl: null,
      title: 'Premium Bike Inspection',
      assetImageUrl: "assets/premium_bike_inspections.png",
      action: premiumBikeInspection),
  PopServiceItem(
      imageUrl: null,
      title: 'List your services',
      assetImageUrl: "assets/list_your_services.png",
      action: listYourServices)
];
