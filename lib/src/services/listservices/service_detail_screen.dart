import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:popp/src/widgets/title_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../api/api_url.dart';
import '../../api/firebase/firebase_api_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/product_utils.dart';
import '../../chat/chat_with_user_widget.dart';
import '../../widgets/full_screen_image_screen.dart';

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
  bool _isFav = false; // Track favorite state
  bool _favButtonDisabled = false;
  final FirebaseApiService _firebaseApiService = FirebaseApiService();

  @override
  void initState() {
    super.initState();
    _isApproved = widget.serviceData['isApproved'] == true;
    final favoritedBy = widget.serviceData['favoritedBy'] as List<dynamic>?;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (favoritedBy != null && currentUser != null) {
      _isFav = favoritedBy.contains(currentUser.uid);
    } else {
      _isFav = false;
    }
  }

  void _toggleFavorite() async {
    setState(() {
      _isFav = !_isFav;
      _favButtonDisabled = true;
    });
    final prev = _isFav;
    final result = await _firebaseApiService.toggleFavoriteProduct(
        ApiUrl.servicePath, widget.serviceData['id']);
    setState(() {
      _favButtonDisabled = false;
      if (!result) {
        _isFav = !prev; // revert if failed
      }
    });
  }

  // --- NEW: Function to handle sharing ---
  void _shareService() {
    final serviceId = widget.serviceData['id'];
    final serviceName = widget.serviceData['businessTitle'] ??
        widget.serviceData['eventName'] ??
        'an amazing service';

    // This is your deep link. Ensure your domain is correct.
    final String deepLink = "${ApiUrl.servicePath}/$serviceId";

    final String shareText = "Check out $serviceName on Bikerverse! $deepLink";
    AppLogger.i("shareText $shareText");
    SharePlus.instance.share(ShareParams(text: shareText));
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin =
        FirebaseAuth.instance.currentUser?.uid == Constants.adminUserId;
    AppLogger.d("isAdmin $isAdmin and isApproved $_isApproved");
    String appBarTitle = ProductUtils.getServiceAppBarTitle(widget.category);
    return Scaffold(
      appBar: AppBar(
        title: TitleText(appBarTitle),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareService,
            tooltip: 'Share Service',
          ),
        ],
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isApproved
                  ? null
                  : () async {
                final serviceId = widget.serviceData['id'] ?? '';
                AppLogger.d("serviceId $serviceId");
                if (serviceId != '') {
                  await _firebaseApiService
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

    String title = serviceData['businessTitle'] ??
        serviceData['eventName'] ??
        'Service Details';
    String status = serviceData['status'] ?? 'N/A';
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
    final isApproved = serviceData['isApproved'] == true;

    final isBikeRentalCategory =
    (ProductUtils.isBikeAndOthersCategory(category));
    final isTrackOrTrainingDay =
    (ProductUtils.isTrackAndTrainingCategory(category));

    if (isBikeRentalCategory) {
      locationInfo = serviceData['businessAddress'];
      dateTimeInfo = serviceData['businessWorkingDaysHours'] ?? 'N/A';
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
        capacityInfo = '${serviceData['maxSlots']} riders(Max slots)';
      }
    }

    // Build a unified details map from all available fields returned by the API.
    // We exclude a small set of keys that are already displayed separately
    // (title, description, images, ids, location/time fields etc.) to avoid
    // duplication. Any other non-empty field from the API will be shown.
    Map<String, String> allDetails = {};

    // Keys to exclude from the details section because they're shown elsewhere
    final excludeKeys = {
      'searchKeywords',
      'shopName',
      'isActive',
      'createdAt',
      'updatedAt',
      'approvedAt',
      'isFavorite',
      'id',
      'isApproved',
      'favoritedBy',
      'userId',
      'pointOfContactName',
      'countryCode',
      'businessDescription',
      'businessTitle',
      'eventDetailedDescription',
      'eventName',
      'businessWorkingDaysHours',
      'businessAddress',
      'businessPromoPicture',
      'shopImageUrls',
      'promoImageUrls',
      'shopGaragePics',
      'category',
    };

    String formatKeyToLabel(String key) {
      // Replace underscores with spaces, split camel case and capitalize words.
      final withSpaces = key.replaceAll('_', ' ').replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
      final parts = withSpaces.split(' ');
      return parts.map((p) {
        if (p.isEmpty) return p;
        return p[0].toUpperCase() + p.substring(1);
      }).join(' ');
    }

    serviceData.forEach((rawKey, rawValue) {
      try {
        if (excludeKeys.contains(rawKey)) return;
        if (rawValue == null) return;
        String valueStr;
        if (rawValue is List) {
          // Join list values into a comma-separated string
          valueStr = rawValue.map((e) => e.toString()).join(', ');
        } else {
          valueStr = rawValue.toString();
        }
        if (valueStr
            .trim()
            .isEmpty) return;
        if (valueStr.trim().toLowerCase() == 'n/a') return;

        final label = formatKeyToLabel(rawKey.toString());
        allDetails[label] = valueStr;
      } catch (e) {
        // ignore individual conversion errors
      }
    });

    return CustomScrollView(
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
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    color: Colors.grey[300],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (allImageUrls.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) =>
                              FullScreenImageScreen(
                                imageUrls: allImageUrls,
                                initialIndex: _selectedImageIndex,
                              ),
                        ),
                      );
                    }
                  },
                  child: Image.network(
                    allImageUrls.isNotEmpty
                        ? allImageUrls[_selectedImageIndex]
                        : ApiUrl.defaultPlaceholderImage,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          color: Colors.grey[300],
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        ApiUrl.defaultPlaceholderImage,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
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
                Positioned(
                  top: 16,
                  right: 16,
                  child: Row(
                    children: [

                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white70,
                        child: IconButton(
                          iconSize: 25,
                          icon: Icon(
                            _isFav ? Icons.favorite : Icons.favorite_border,
                            color: _isFav ? Colors.red : Colors.red,
                          ),
                          onPressed: _favButtonDisabled
                              ? null
                              : _toggleFavorite,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Thumbnail strip for images (only when there are multiple images)
        if (allImageUrls.length > 1)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allImageUrls.length,
                itemBuilder: (context, index) {
                  final String thumbUrl = allImageUrls[index];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedImageIndex = index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedImageIndex == index
                                  ? Theme
                                  .of(context)
                                  .primaryColor
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: Image.network(
                            thumbUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                ),
                              );
                            },
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
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isApproved)
                        Text(
                          "Status: Pending Approval",
                          style: context.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange),
                        ),
                      const SizedBox(height: 8),
                      TitleText(
                        title,
                        style: context.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (status != 'N/A')
                        _buildInfoRow(context, 'Status:', status, Colors.green),
                      _buildInfoRow(
                          context,
                          isBikeRentalCategory ? 'Address: ' : "Where:",
                          locationInfo),
                      _buildInfoRow(
                          context,
                          isBikeRentalCategory ? 'Hours: ' : "When:",
                          dateTimeInfo),
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
                      // Unified Details section: show any available API fields
                      // (except the excluded ones) under a single header.
                      if (allDetails.isNotEmpty) ...[
                        Text(
                          ProductUtils.getProductDescTitle(widget.category) ==
                              ''
                              ? 'Details'
                              : ProductUtils.getProductDescTitle(
                              widget.category),
                          style: context.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...allDetails.entries.map((entry) =>
                            _buildDetailRow(context, entry.key, entry.value)),
                      ],
                      const SizedBox(height: 20),
                      ChatWithSellerCard(
                        receiverUserName: contactName,
                        receiverUserID: userId,
                        productId: widget.serviceData['id'] ?? '',
                        productTitle: title,
                      ),
                    ],
                  ),
                );
              }
              return null;
            },
            childCount: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value,
      [Color? valueColor]) {
    if (label.toLowerCase().contains('where') &&
        value.isNotEmpty &&
        value != 'N/A') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
    bool isLink = false;
    VoidCallback? onTap;

    if ((label.toLowerCase().contains('google map link') ||
        label.toLowerCase().contains('social media link')) &&
        value.isNotEmpty &&
        value != 'N/A') {
      isLink = true;
      onTap = () async {
        final url = value.startsWith('http') ? value : 'https://$value';
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      };
    } else if ((label.toLowerCase().contains('phone') ||
        label.toLowerCase().contains('mobile') ||
        label.toLowerCase().contains('contact')) &&
        !label.toLowerCase().contains('name') &&
        value.isNotEmpty &&
        value != 'N/A') {
      isLink = true;
      onTap = () async {
        final Uri launchUri = Uri(
          scheme: 'tel',
          path: value,
        );
        await launchUrlString(launchUri.toString());
      };
    }

    if (isLink) {
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
                onTap: onTap,
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
