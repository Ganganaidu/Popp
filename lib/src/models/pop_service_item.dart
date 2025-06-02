enum PopServiceAction {
  sellBike,
  sellAccessory,
  bookService,
  bookTrackTraining,
  findBikeRentals,
  listYourServices,
  premiumBikeInspection,
  comingSoon,
}

class PopServiceItem {
  final String? imageUrl;
  final String title;
  final String assetImageUrl;
  final PopServiceAction action;

  PopServiceItem({
    this.imageUrl,
    required this.title,
    required this.assetImageUrl,
    required this.action,
  });

  factory PopServiceItem.fromJson(Map<String, dynamic> json) {
    return PopServiceItem(
        imageUrl: json['image'],
        title: json['title'],
        assetImageUrl: json['assetImageUrl'],
        action: PopServiceAction.sellBike);
  }

  Map<String, dynamic> toJson() {
    return {
      'image': imageUrl,
      'title': title,
      'assetImageUrl': assetImageUrl,
    };
  }
}

final List<PopServiceItem> items = [
  PopServiceItem(
      imageUrl: null,
      title: 'Sell your bike',
      assetImageUrl: "assets/sell_your_bike.png",
      action: PopServiceAction.sellBike),
  PopServiceItem(
      imageUrl: null,
      title: 'Sell your accessory',
      assetImageUrl: "assets/sell_your_accessories.png",
      action: PopServiceAction.sellAccessory),
  PopServiceItem(
      imageUrl: null,
      title: 'Book your service',
      assetImageUrl: "assets/book_your_services.png",
      action: PopServiceAction.bookService),
  PopServiceItem(
      imageUrl: null,
      title: 'Book track day & Training ',
      assetImageUrl: "assets/book_track_trainings.png",
      action: PopServiceAction.bookTrackTraining),
  PopServiceItem(
      imageUrl: null,
      title: 'Find bike rentals',
      assetImageUrl: "assets/find_bike_rentals.png",
      action: PopServiceAction.findBikeRentals),
  PopServiceItem(
      imageUrl: null,
      title: 'List your services',
      assetImageUrl: "assets/list_your_services.png",
      action: PopServiceAction.listYourServices),
  PopServiceItem(
      imageUrl: null,
      title: 'Premium Bike Inspection',
      assetImageUrl: "assets/premium_bike_inspections.png",
      action: PopServiceAction.premiumBikeInspection),
];
