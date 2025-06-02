class AdBanner {
  final String imageUrl;
  final String title;
  final String highlight;
  final String subtitle;
  final List<String> points;
  final String buttonText;
  final String buttonLink;

  AdBanner({
    required this.imageUrl,
    required this.title,
    required this.highlight,
    required this.subtitle,
    required this.points,
    required this.buttonText,
    required this.buttonLink,
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
    );
  }
}
