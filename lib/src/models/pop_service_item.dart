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
      assetImageUrl: "assets/prem_bikes.png"),
  PopServiceItem(
      imageUrl: null,
      title: 'Sell your accessory',
      assetImageUrl: "assets/prem_bikes.png"),
  PopServiceItem(
      imageUrl: null,
      title: 'Book your service',
      assetImageUrl: "assets/prem_bikes.png"),
  PopServiceItem(
      imageUrl: null,
      title: 'Book track day & Training ',
      assetImageUrl: "assets/prem_bikes.png"),
  PopServiceItem(
      imageUrl: null,
      title: 'Find bike rentals',
      assetImageUrl: "assets/prem_bikes.png"),
  PopServiceItem(
      imageUrl: null,
      title: 'List your services',
      assetImageUrl: "assets/prem_bikes.png"),
  PopServiceItem(
      imageUrl: null,
      title: 'Premium Bike Inspection',
      assetImageUrl: "assets/prem_bikes.png"),
];
