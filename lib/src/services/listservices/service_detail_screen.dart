import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../firebase/firebase_save_prodcuts_api.dart';
import '../../utils/app_constants.dart'; // Import your build_extensions
import '../../utils/product_content_data.dart';
import '../../widgets/chat_with_user_widget.dart'; // Import serviceCategories

class ServiceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> serviceData;
  final String category;

  const ServiceDetailScreen({
    super.key,
    required this.serviceData,
    required this.category,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late bool _isApproved;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _isApproved = widget.serviceData['isApproved'] == true;
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin =
        FirebaseAuth.instance.currentUser?.uid == Constants.adminUserId;
    String appBarTitle = widget.category;
    if (appBarTitle.contains("Track")) {
      appBarTitle = "Track and Training day";
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        automaticallyImplyLeading: true, // Show back button only on toolbar
      ),
      body: _buildBody(context),
      bottomNavigationBar: isAdmin && !_isApproved
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isApproved ? Colors.green : Colors.orange,
                      // Green if approved
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isApproved
                        ? null
                        : () async {
                            final serviceId = widget.serviceData['id'] ?? '';
                            if (serviceId != '') {
                              await FirebaseProductsService()
                                  .updateServiceApprovalStatus(serviceId, true);
                              setState(() {
                                _isApproved = true;
                              });
                              if (_isApproved) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Product approved successfully!',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                    child: Text(_isApproved ? 'Approved' : 'Approve'),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context) {
    final serviceData = widget.serviceData;
    final category = widget.category;

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

    final isBikeRentalCategory = (category == serviceCategories[0] ||
        category == serviceCategories[1] ||
        category == Constants.premiumInspection);
    final isTrackOrTrainingDay = (category == serviceCategories[2] ||
        category == serviceCategories[3] ||
        category == [serviceCategories[2], serviceCategories[3]].join(','));

    if (isBikeRentalCategory) {
      locationInfo =
          '${serviceData['businessAddress'] ?? ''}, ${serviceData['city'] ?? ''}, ${serviceData['state'] ?? ''}';
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
        if (value != null && value.trim().isNotEmpty && value != 'N/A') {
          bikeRentalDetails[key] = value;
        }
      });
    } else if (isTrackOrTrainingDay) {
      locationInfo =
          '${serviceData['locationAddress'] ?? ''}, ${serviceData['city'] ?? ''}, ${serviceData['state'] ?? ''}';

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
        capacityInfo = '${serviceData['maxSlots']} riders(Max slots)';
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
        eventDetails['Point of Contact'] = serviceData['pointOfContactName'];
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

    return Container(
      color: Colors.white, // Set background for the whole scroll area
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    allImageUrls.isNotEmpty
                        ? allImageUrls[_selectedImageIndex]
                        : Constants.defaultPlaceholderImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        Constants.defaultPlaceholderImage,
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
                          Colors.black.withAlpha((0.7 * 255).toInt())
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Only show thumbnails if there are more than 1 image
          if (allImageUrls.length > 1)
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: allImageUrls.length,
                    itemBuilder: (context, index) {
                      String thumbUrl = allImageUrls[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImageIndex = index;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedImageIndex == index
                                      ? Colors.orange
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
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
                          ),
                        ),
                      );
                    },
                  ),
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
                        if (isTrackOrTrainingDay) ...[
                          Text(
                            'Event Details',
                            style: context.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...eventDetails.entries.map((entry) =>
                              _buildDetailRow(context, entry.key, entry.value)),
                        ] else if (isBikeRentalCategory &&
                            bikeRentalDetails.isNotEmpty) ...[
                          Text(
                            'Bike Rental Details',
                            style: context.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...bikeRentalDetails.entries.map((entry) =>
                              _buildDetailRow(context, entry.key, entry.value)),
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
    // Special handling for location row to make it clickable and open Google Maps
    if (label.toLowerCase().contains('where') &&
        value.isNotEmpty &&
        value != 'N/A') {
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
              child: GestureDetector(
                onTap: () async {
                  final encodedLocation = Uri.encodeComponent(value);
                  final url =
                      'https://www.google.com/maps/search/?api=1&query=$encodedLocation';
                  await launchUrlString(url,
                      mode: LaunchMode.externalApplication);
                },
                child: Text(
                  value,
                  style: context.bodyLarge?.copyWith(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    // Default row
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
    // Special handling for Google Map Link or Social Media Link
    if (label.toLowerCase().contains('google map link') ||
        label.toLowerCase().contains('social media link') &&
            value.isNotEmpty &&
            value != 'N/A') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '$label:',
                style:
                    context.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: () async {
                  final url =
                      value.startsWith('http') ? value : 'https://$value';
                  await launchUrlString(url,
                      mode: LaunchMode.externalApplication);
                },
                child: Text(
                  value,
                  style: context.bodyMedium?.copyWith(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    // Default row
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
