import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../api/api_url.dart';
import '../../utils/product_utils.dart';

class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final String category;
  final double width;
  final VoidCallback onTap;
  final bool isApproved;

  const ServiceCard({
    super.key,
    required this.service,
    required this.category,
    required this.width,
    required this.onTap,
    this.isApproved = true,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the background image
    String? imageUrl;
    List<dynamic>? promoImages;
    if (service['promoImageUrls'] is List) {
      promoImages = service['promoImageUrls'] as List<dynamic>?;
    } else if (service['promoImageUrls'] is String &&
        (service['promoImageUrls'] as String).isNotEmpty) {
      promoImages = [(service['promoImageUrls'] as String)];
    } else {
      promoImages = null;
    }
    List<dynamic>? shopGarageImages = service['shopImageUrls'] is List
        ? service['shopImageUrls'] as List<dynamic>?
        : null;

    if (promoImages != null && promoImages.isNotEmpty) {
      imageUrl = promoImages.first as String;
    } else if (shopGarageImages != null && shopGarageImages.isNotEmpty) {
      imageUrl = shopGarageImages.first as String;
    }

    // Data extraction based on category type
    String title = service['businessTitle'] ?? service['eventName'] ?? 'N/A';
    String dateTime = 'N/A';
    String location = 'N/A';
    String capacity = 'N/A';

    if (ProductUtils.isBikeAndOthersCategory(category)) {
      // For Book Service / Bike Rentals
      location =
          '${service['businessAddress'] ?? ''}, ${service['city'] ?? ''}, ${service['state'] ?? ''}';
      dateTime = service['businessWorkingDaysHours'] ?? 'N/A';
    } else if (ProductUtils.isTrackAndTrainingCategory(category)) {
      // For Track Day / Training Day
      location =
          '${service['locationAddress'] ?? ''}, ${service['city'] ?? ''}, ${service['state'] ?? ''}';

      String startDate = service['eventStartDate'] != null
          ? 'From ${DateTime.parse(service['eventStartDate']).toLocal().toIso8601String().split('T')[0]}'
          : '';
      String endDate = service['eventEndDate'] != null
          ? 'To ${DateTime.parse(service['eventEndDate']).toLocal().toIso8601String().split('T')[0]}'
          : '';
      String startTime = service['eventStartTime'] ?? '';
      String endTime = service['eventEndTime'] ?? '';

      dateTime = [startDate, endDate, startTime, endTime]
          .where((s) => s.isNotEmpty)
          .join(' ');

      if (service['maxSlots'] != null && service['maxSlots'].isNotEmpty) {
        capacity = '${service['maxSlots']} riders (Max slots)';
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Stack(
              children: [
                // Background Image with shadow
                ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ).createShader(
                        Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  blendMode: BlendMode.darken,
                  child: Stack(
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey[300],
                        ),
                      ),
                      Image.network(
                        imageUrl ?? ApiUrl.defaultPlaceholderImage,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.grey[300],
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            ApiUrl.defaultPlaceholderImage,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Content Overlay
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          context,
                          Icons.calendar_today,
                          dateTime,
                        ),
                        _buildInfoRow(
                          context,
                          Icons.location_on,
                          location,
                        ),
                        if (capacity != 'N/A')
                          _buildInfoRow(
                            context,
                            Icons.people,
                            capacity,
                          ),
                      ],
                    ),
                  ),
                ),
                if (!isApproved)
                  Positioned(
                    top: 12.0,
                    right: 12.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text(
                        'Pending',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
