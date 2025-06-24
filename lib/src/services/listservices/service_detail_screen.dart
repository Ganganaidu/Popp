import 'package:flutter/material.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:provider/provider.dart';

import '../../subscription/subscription_provider.dart';
import '../../utils/app_constants.dart'; // Import your build_extensions
import '../../utils/product_content_data.dart';
import '../../widgets/chat_with_user_widget.dart'; // Import serviceCategories

class ServiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> serviceData;
  final String category;

  const ServiceDetailScreen({
    super.key,
    required this.serviceData,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        automaticallyImplyLeading: true, // Show back button only on toolbar
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    // Extract images
    List<String> allImageUrls = [];
    List<dynamic>? promoImages;

    if (serviceData['promoImageUrls'] is List) {
      promoImages = serviceData['promoImageUrls'] as List<dynamic>?;
    } else if (serviceData['promoImageUrls'] is String &&
        (serviceData['promoImageUrls'] as String).isNotEmpty) {
      promoImages = [(serviceData['promoImageUrls'] as String)];
    } else {
      promoImages = null;
    }
    List<dynamic>? shopGarageImages = serviceData['shopImageUrls'] is List
        ? serviceData['shopImageUrls'] as List<dynamic>?
        : null;

    if (promoImages != null && promoImages.isNotEmpty) {
      allImageUrls.addAll(promoImages.cast<String>());
    }
    if (shopGarageImages != null && shopGarageImages.isNotEmpty) {
      allImageUrls.addAll(shopGarageImages.cast<String>());
    }

    String heroImageUrl = allImageUrls.isNotEmpty
        ? allImageUrls.first
        : Constants.defaultPlaceholderImage;

    // Remove the first image from the list for thumbnails, as it's the hero image
    List<String> thumbnailUrls = List.from(allImageUrls);
    if (thumbnailUrls.isNotEmpty) {
      thumbnailUrls.removeAt(0);
    }

    // Determine content based on category
    String title = serviceData['businessTitle'] ??
        serviceData['eventName'] ??
        'Service Details';
    String status =
        serviceData['status'] ?? 'N/A'; // Assuming a 'status' field might exist
    String dateTimeInfo = 'N/A';
    String locationInfo = 'N/A';
    String capacityInfo = 'N/A';
    String description = serviceData['businessDescription'] ??
        serviceData['eventDetailedDescription'] ??
        'No description available.';

    String contactName = (serviceData['contactName'] ?? '') as String;
    if (contactName.isEmpty || contactName == 'N/A') {
      contactName = (serviceData['pointOfContactName'] ?? '') as String;
    }
    String userId = (serviceData['userId'] ?? '') as String;

    Map<String, String> eventDetails = {};
    Map<String, String> bikeRentalDetails = {};

    final isBikeRentalCategory = serviceCategories.contains(category) &&
        (category == 'Book your Bike service' || category == 'Bike Rentals');
    final isTrackOrTrainingDay = serviceCategories.contains(category) &&
        (category == 'Track day' || category == 'Training day');

    if (isBikeRentalCategory) {
      locationInfo =
      '${serviceData['businessAddress'] ?? ''}, ${serviceData['city'] ??
          ''}, ${serviceData['state'] ?? ''}';
      dateTimeInfo = serviceData['businessWorkingDaysHours'] ?? 'N/A';
      final bikeFields = {
        'GST Number': serviceData['gstNumber']?.toString(),
        'PAN Number': serviceData['panNumber']?.toString(),
        'Business Address': serviceData['businessAddress']?.toString(),
        'Area': serviceData['area']?.toString(),
        'City': serviceData['city']?.toString(),
        'State': serviceData['state']?.toString(),
        'Pincode': serviceData['pincode']?.toString(),
        'Do You Inspect Premium Bikes':
        serviceData['doYouInspectPremiumBikes']?.toString(),
        'Google Map Link': serviceData['googleMapLink']?.toString(),
        'Social Media Link': serviceData['socialMediaLink']?.toString(),
        'Business Working Days/Hours':
        serviceData['businessWorkingDaysHours']?.toString(),
      };
      bikeFields.forEach((key, value) {
        if (value != null && value
            .trim()
            .isNotEmpty && value != 'N/A') {
          bikeRentalDetails[key] = value;
        }
      });
    } else if (isTrackOrTrainingDay) {
      locationInfo =
      '${serviceData['locationAddress'] ?? ''}, ${serviceData['city'] ??
          ''}, ${serviceData['state'] ?? ''}';

      String startDate = serviceData['eventStartDate'] != null
          ? DateTime.parse(serviceData['eventStartDate'])
          .toLocal()
          .toIso8601String()
          .split('T')[0]
          : 'N/A';
      String endDate = serviceData['eventEndDate'] != null
          ? DateTime.parse(serviceData['eventEndDate'])
          .toLocal()
          .toIso8601String()
          .split('T')[0]
          : 'N/A';
      String startTime = serviceData['eventStartTime'] ?? 'N/A';
      String endTime = serviceData['eventEndTime'] ?? 'N/A';

      dateTimeInfo = '$startDate at $startTime - $endDate at $endTime';

      if (serviceData['maxSlots'] != null &&
          serviceData['maxSlots'].isNotEmpty) {
        capacityInfo =
        '${serviceData['currentRiders'] ??
            '0'}/${serviceData['maxSlots']} riders';
      }

      eventDetails = {
        'Meeting Point': serviceData['locationName'] ?? 'N/A',
        'Bike Type/Model': serviceData['bikeTypeModel'] ?? 'N/A',
        'Bike Provision': serviceData['bikeProvision'] ?? 'N/A',
        'Rider Skill Level': serviceData['riderSkillLevel'] ?? 'N/A',
        'Max Slots': serviceData['maxSlots'] ?? 'N/A',
      };
      // Adding other fields from the Track Day screenshot
      if (serviceData['pointOfContactName'] != null) {
        eventDetails['Point of Contact'] =
        serviceData['pointOfContactName'];
      }
      if (serviceData['gstNumber'] != null && serviceData['gstNumber'] != '') {
        eventDetails['GST #'] = serviceData['gstNumber'];
      }
      if (serviceData['panNumber'] != null && serviceData['panNumber'] != '') {
        eventDetails['PAN #'] = serviceData['panNumber'];
      }
      if (serviceData['googleFormLink'] != null &&
          serviceData['googleFormLink'] != '') {
        eventDetails['Google Form/Redirect Link'] =
        serviceData['googleFormLink'];
      }
      if (serviceData['socialMediaLink'] != null &&
          serviceData['socialMediaLink'] != '') {
        eventDetails['Social Media Link'] = serviceData['socialMediaLink'];
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            // Remove back button from image area
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    heroImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        Constants.defaultPlaceholderImage,
                        // Fallback to placeholder if hero fails
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  // Gradient Overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7)
                        ],
                      ),
                    ),
                  ),
                  // Thumbnail images overlayed at the bottom
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: SizedBox(
                      height: 80, // Height for the thumbnail scroll view
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: allImageUrls.length,
                        // Show all images including hero
                        itemBuilder: (context, index) {
                          String thumbUrl = allImageUrls[index];
                          return Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                thumbUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.broken_image,
                                        color: Colors.grey[600]),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: context.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (status != 'N/A')
                          _buildInfoRow(
                              context, 'Status:', status, Colors.green),
                        // Example status color
                        _buildInfoRow(context, 'When:', dateTimeInfo),
                        _buildInfoRow(context, 'Where:', locationInfo),
                        if (capacityInfo != 'N/A')
                          _buildInfoRow(context, 'Capacity:', capacityInfo),

                        const SizedBox(height: 20),
                        Text(
                          'Description',
                          style: context.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: context.bodyLarge,
                        ),
                        const SizedBox(height: 20),

                        // Render Event Details or Bike Rental Details based on category
                        if (category == 'Track day' ||
                            category == 'Training day') ...[
                          Text(
                            'Event Details',
                            style: context.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...eventDetails.entries.map((entry) =>
                              _buildDetailRow(context, entry.key, entry.value)),
                        ] else
                          if (category == 'Bike Rentals' ||
                              category == 'Book your Bike service') ...[
                            if (isBikeRentalCategory &&
                                bikeRentalDetails.isNotEmpty) ...[
                              Text(
                                'Bike Rental Details',
                                style: context.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...bikeRentalDetails.entries.map((entry) =>
                                  _buildDetailRow(
                                      context, entry.key, entry.value)),
                            ],
                          ],
                        const SizedBox(height: 20),
                        ChatWithSellerCard(
                          receiverUserName: contactName,
                          receiverUserID: userId,
                        ),
                        const SizedBox(height: 20),
                        // Extra space at the bottom
                      ],
                    ),
                  );
                }
                return null;
              },
              childCount: 1, // Only one main content item in this sliver
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value,
      [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80, // Align labels
            child: Text(
              label,
              style: context.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.bodyLarge?.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: context.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: context.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
