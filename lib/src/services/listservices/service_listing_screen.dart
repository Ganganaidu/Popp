import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_constants.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:popp/src/widgets/title_text.dart';
import 'package:shimmer/shimmer.dart';

import '../../api/api_url.dart';
import '../../api/firebase/firebase_api_service.dart';
import '../../navigation/nav_router.dart';
import '../../utils/product_content_data.dart';
import '../../utils/product_utils.dart';

class ServiceListingScreen extends StatefulWidget {
  final String category;
  final String? subCategory;

  const ServiceListingScreen(
      {super.key, required this.category, required this.subCategory});

  @override
  State<ServiceListingScreen> createState() => _ServiceListingScreenState();
}

class _ServiceListingScreenState extends State<ServiceListingScreen> {
  final FirebaseApiService _productsService = FirebaseApiService();
  late Future<List<Map<String, dynamic>>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    String category = widget.category;
    if (category.contains(ProductUtils.premiumInspection)) {
      // Only display Premium Inspection, and
      // search for 'Book your Bike service' and
      // filter by doYouInspectPremiumBikes == 'Yes'
      _servicesFuture = _productsService
          .fetchServicesByCategories([ProductUtils.findMechanic], true).then(
              (services) => services
                  .where((s) => s['doYouInspectPremiumBikes'] == 'Yes')
                  .toList());
    } else {
      final List<String> categories =
          category.split(',').map((e) => e.trim()).toList();
      _servicesFuture = _productsService.fetchServicesByCategories(
          categories, true,
          subCategory: widget.subCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = ProductUtils.getServiceAppBarTitle(widget.category);
    return Scaffold(
      appBar: AppBar(
        title: TitleText(appBarTitle),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    // Only this icon when NO services found
                    size: 100, // Adjust size as needed
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No services found for this category yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Be the first to list a "${widget.category}" service!',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            final services = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                final isApproved = service['isApproved'] == true;

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
                List<dynamic>? shopGarageImages =
                    service['shopImageUrls'] is List
                        ? service['shopImageUrls'] as List<dynamic>?
                        : null;

                if (promoImages != null && promoImages.isNotEmpty) {
                  imageUrl = promoImages.first as String;
                } else if (shopGarageImages != null &&
                    shopGarageImages.isNotEmpty) {
                  imageUrl = shopGarageImages.first as String;
                }

                // Data extraction based on category type
                String title =
                    service['businessTitle'] ?? service['eventName'] ?? 'N/A';
                String dateTime = 'N/A';
                String location = 'N/A';
                String capacity = 'N/A';

                AppLogger.d("category ${widget.category}");
                if (ProductUtils.isBikeAndOthersCategory(widget.category)) {
                  // For Book Service / Bike Rentals
                  location =
                      '${service['businessAddress'] ?? ''}, ${service['city'] ?? ''}, ${service['state'] ?? ''}';
                  dateTime = service['businessWorkingDaysHours'] ?? 'N/A';
                } else if (ProductUtils.isTrackAndTrainingCategory(widget.category)) {
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

                  if (service['maxSlots'] != null &&
                      service['maxSlots'].isNotEmpty) {
                    // Assuming 'maxSlots' stores the total capacity
                    // You might need to fetch current registered riders from another collection/field
                    capacity =
                        '${service['maxSlots']} riders (Max slots)'; // Placeholder for registered riders
                  }
                }

                return GestureDetector(
                  onTap: () {
                    onServiceDetailsScreenTap(
                        context, service, widget.category);
                  },
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: const EdgeInsets.only(bottom: 16.0),
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
                                    height: 200,
                                    color: Colors.grey[300],
                                  ),
                                ),
                                Image.network(
                                  imageUrl ?? ApiUrl.defaultPlaceholderImage,
                                  width: double.infinity,
                                  height: 200,
                                  // Fixed height for consistency
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: double.infinity,
                                        height: 200,
                                        color: Colors.grey[300],
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                      ApiUrl.defaultPlaceholderImage,
                                      width: double.infinity,
                                      height: 200,
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
                                // Align content to the bottom
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: context.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
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
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: context.bodyMedium?.copyWith(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
