class PopServiceItem {
  final String? imageUrl;
  final String title;
  final String assetImageUrl;

  PopServiceItem(
      {this.imageUrl, required this.title, required this.assetImageUrl});

  factory PopServiceItem.fromJson(Map<String, dynamic> json) {
    return PopServiceItem(
      imageUrl: json['image'],
      title: json['title'],
      assetImageUrl: json['assetImageUrl'],
    );
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
      assetImageUrl: "assets/sell_your_bike.png"),
  PopServiceItem(
      imageUrl: null,
      title: 'Sell your accessory',
      assetImageUrl: "assets/sell_your_accessories.png"),
  PopServiceItem(
      imageUrl: null,
      title: 'Book your service',
      assetImageUrl: "assets/book_your_services.png"),
  PopServiceItem(
      imageUrl: null,
      title: 'Book track day & Training ',
      assetImageUrl: "assets/book_track_trainings.png"),
  PopServiceItem(
      imageUrl: null,
      title: 'Find bike rentals',
      assetImageUrl: "assets/find_bike_rentals.png"),
  PopServiceItem(
      imageUrl: null,
      title: 'List your services',
      assetImageUrl: "assets/list_your_services.png"),
  PopServiceItem(
      imageUrl: null,
      title: 'Premium Bike Inspection',
      assetImageUrl: "assets/premium_bike_inspections.png"),
];
