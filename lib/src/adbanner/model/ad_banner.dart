import 'package:cloud_firestore/cloud_firestore.dart';

class AdBanner {
  final String? id;
  final String imageUrl;
  final String title;
  final String highlight;
  final String subtitle;
  final List<String> points;
  final String buttonText;
  final String buttonLink;
  final bool isActive;
  final bool hideOverlay;

  AdBanner({
    this.id,
    required this.imageUrl,
    required this.title,
    required this.highlight,
    required this.subtitle,
    required this.points,
    required this.buttonText,
    required this.buttonLink,
    required this.isActive,
    required this.hideOverlay,
  });

  factory AdBanner.fromJson(Map<String, dynamic> json) {
    return AdBanner(
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
      highlight: json['highlight'] ?? '',
      subtitle: json['subtitle'] ?? '',
      points: List<String>.from(json['points'] ?? []),
      buttonText: json['buttonText'] ?? 'Learn More',
      buttonLink: json['buttonLink'] ?? '',
      isActive: json['isActive'] ?? true,
      hideOverlay: json['hideOverlay'] ?? false,
    );
  }

  /// Create an AdBanner from a Firestore document snapshot and include the doc id.
  factory AdBanner.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AdBanner(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? '',
      highlight: data['highlight'] ?? '',
      subtitle: data['subtitle'] ?? '',
      points: List<String>.from(data['points'] ?? []),
      buttonText: data['buttonText'] ?? 'Learn More',
      buttonLink: data['buttonLink'] ?? '',
      isActive: data['isActive'] ?? true,
      hideOverlay: data['hideOverlay'] ?? false,
    );
  }
}
