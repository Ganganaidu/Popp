import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../admin/admin_notification_service.dart';
import '../../api/api_url.dart';
import '../repository/service_repository.dart';
import '../../chat/chat_with_seller_card.dart';
import '../../toolbar/AppBarIconButton.dart';
import '../../utils/app_constants.dart';
import '../../utils/product_utils.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/full_screen_image_screen.dart';
import 'list_service_form_screen.dart';

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
  bool _isSold = false;
  String _status = 'Pending';
  int _selectedImageIndex = 0;
  bool _isFav = false;
  bool _favButtonDisabled = false;
  final ServiceRepository _repository = ServiceRepository();

  @override
  void initState() {
    super.initState();
    _isApproved = widget.serviceData['isApproved'] == true;
    _isSold = widget.serviceData['isSold'] == true || widget.serviceData['status'] == 'Sold';
    final docStatus = widget.serviceData['status'] as String?;
    if (_isSold) {
      _status = 'Sold';
    } else if (_isApproved) {
      _status = 'Approved';
    } else if (docStatus == 'sent_back') {
      _status = 'Sent Back';
    } else if (docStatus == 'rejected') {
      _status = 'Rejected';
    } else {
      _status = 'Pending';
    }
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
    final result = await _repository.toggleFavorite(widget.serviceData['id']);
    if (!mounted) return;
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

    // Path must be singular ("service") to match the intent-filter /
    // AppLinks parsing in main.dart — that's the actual deep link contract,
    // not the Firestore collection name (ApiUrl.servicePath is plural).
    final String deepLink = "${ApiUrl.baseUrl}service/$serviceId";

    final String shareText = "Check out $serviceName on Bikerverse! $deepLink";
    AppLogger.i("shareText $shareText");
    SharePlus.instance.share(ShareParams(text: shareText));
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin =
        FirebaseAuth.instance.currentUser?.uid == Constants.adminUserId;
    AppLogger.d("isAdmin $isAdmin and isApproved $_isApproved");
    // String appBarTitle = ProductUtils.getServiceAppBarTitle(widget.category);
    return Scaffold(
      body: _buildBody(context),
      bottomNavigationBar: _buildServiceBottomBar(isAdmin),
    );
  }
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    IconData? icon;
    VoidCallback? onTap;
    bool isLink = false;

    if (label.toLowerCase().contains('address') ||
        label.toLowerCase().contains('map')) {
      icon = Icons.map;
      isLink = true;
      onTap = () {
        launchUrlString(value, mode: LaunchMode.externalApplication);
      };
    } else if (label.toLowerCase().contains('phone') ||
        label.toLowerCase() == 'business contact') {
      icon = Icons.phone;
      isLink = true;
      onTap = () => launchUrlString('tel:$value');
    } else if (label.toLowerCase().contains('link') ||
        value.startsWith('http')) {
      icon = Icons.link;
      isLink = true;
      onTap =
          () => launchUrlString(value, mode: LaunchMode.externalApplication);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Expanded(
                      child: Text(value,
                          style: TextStyle(
                              color: isLink
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                              fontSize: 13,
                              decoration:
                                  isLink ? TextDecoration.underline : null))),
                  if (icon != null) ...[
                    const SizedBox(width: 4),
                    Icon(icon,
                        color: isLink
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        size: 14)
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Web breadcrumb: back arrow + clickable path segments
  Widget _buildBody(BuildContext context) {
    final serviceData = widget.serviceData;
    final category = widget.category;
    final isAdmin =
        FirebaseAuth.instance.currentUser?.uid == Constants.adminUserId;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = !isAdmin && serviceData['userId'] == currentUid;

    // Prepare images
    List<String> allImageUrls = [];
    List<dynamic>? promoImages;

    if (serviceData['promoImageUrls'] is List) {
      promoImages = serviceData['promoImageUrls'] as List<dynamic>?;
    } else if (serviceData['promoImageUrls'] is String &&
        (serviceData['promoImageUrls'] as String).isNotEmpty) {
      promoImages = [(serviceData['promoImageUrls'] as String)];
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

    // Prepare Data
    String title = serviceData['businessTitle'] ??
        serviceData['eventName'] ??
        'Service Details';
    String description = serviceData['businessDescription'] ??
        serviceData['eventDetailedDescription'] ??
        'No description available.';

    String contactName = (serviceData['contactName'] ?? '') as String;
    if (contactName.isEmpty || contactName == 'N/A') {
      contactName = (serviceData['pointOfContactName'] ?? '') as String;
    }
    String userId = (serviceData['userId'] ?? '') as String;

    // Data for Highlights & Details
    String city = serviceData['city'] ?? 'N/A';
    String state = serviceData['state'] ?? '';
    String status = serviceData['status'] ?? 'Open';

    // Address & Hours
    String fullAddress = 'N/A';
    String hoursInfo = 'N/A';
    String closedDaysInfo = '';

    final isBikeRentalCategory =
        (ProductUtils.isBikeAndOthersCategory(category));
    final isTrackOrTrainingDay =
        (ProductUtils.isTrackAndTrainingCategory(category));

    if (isBikeRentalCategory) {
      fullAddress = serviceData['businessAddress'] ??
          serviceData['locationAddress'] ??
          'N/A';

      final rawHours = serviceData['businessWorkingDaysHours'] ?? 'N/A';
      final parsed = _parseBusinessHours(rawHours);
      hoursInfo = parsed['hours']!;
      closedDaysInfo = parsed['closed']!;
    } else if (isTrackOrTrainingDay) {
      fullAddress =
          '${serviceData['locationAddress'] ?? ''}, ${serviceData['city'] ?? ''}, ${serviceData['state'] ?? ''}';

      String startDate = serviceData['eventStartDate'] != null
          ? DateFormat('d MMM yyyy')
              .format(DateTime.parse(serviceData['eventStartDate']))
          : '';
      String startTime = serviceData['eventStartTime'] ?? '';

      if (startDate.isNotEmpty) {
        hoursInfo = '$startDate, $startTime';
      } else {
        hoursInfo = serviceData['eventStartTime'] ?? 'N/A';
      }
      if (hoursInfo == 'N/A' || hoursInfo.trim().isEmpty) {
        hoursInfo = 'Check details';
      }
    } else {
      // Fallback
      fullAddress =
          serviceData['businessAddress'] ?? serviceData['address'] ?? 'N/A';

      final rawHours = serviceData['workingHours'] ?? 'N/A';
      final parsed = _parseBusinessHours(rawHours);
      hoursInfo = parsed['hours']!;
      closedDaysInfo = parsed['closed']!;
    }

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                expandedHeight: screenHeight * 0.45,
                pinned: true,
                leading: Center(
                  child: AppBarIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                actions: [
                  AppBarIconButton(
                    icon: Icons.share,
                    onTap: _shareService,
                  ),
                  const SizedBox(width: 12),
                  AppBarIconButton(
                      icon: _isFav ? Icons.favorite : Icons.favorite_border,
                      onTap: () {
                        if (!_favButtonDisabled) _toggleFavorite();
                      },
                      iconColor: _isFav ? Colors.red : null),
                  const SizedBox(width: 16),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      if (allImageUrls.isNotEmpty)
                        PageView.builder(
                          itemCount: allImageUrls.length,
                          onPageChanged: (index) {
                            setState(() {
                              _selectedImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    fullscreenDialog: true,
                                    builder: (context) => FullScreenImageScreen(
                                      imageUrls: allImageUrls,
                                      initialIndex: index,
                                    ),
                                  ),
                                );
                              },
                              child: AppNetworkImage(
                                imageUrl: allImageUrls[index],
                                fit: BoxFit.cover,
                                errorWidget: Container(color: Theme.of(context).colorScheme.surface),
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: Center(
                            child: Icon(Icons.image_not_supported,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), size: 50),
                          ),
                        ),

                      // Gradient for top icon visibility
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 100,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Gradient for bottom indicator visibility
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.only(top: 80, bottom: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Theme.of(context).scaffoldBackgroundColor, Colors.transparent],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                List.generate(allImageUrls.length, (index) {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: _selectedImageIndex == index ? 24 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _selectedImageIndex == index
                                      ? const Color(0xFF2ECC71)
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      // Category Tag
                      Text(category.toUpperCase(),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                          fontFamily: 'Orbitron',
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 1. Highlight Cards Row (Location, Map, Social Links)
                      _buildHighlightsRow(city, state, serviceData),

                      const SizedBox(height: 15),

                      // 2. Address Block
                      if (fullAddress != 'N/A' && fullAddress.isNotEmpty)
                        _buildInfoBlock(
                            Icons.location_on_outlined, "ADDRESS", fullAddress),

                      const SizedBox(height: 10),

                      // 3. Business Hours Block
                      if (hoursInfo != 'N/A' && hoursInfo.isNotEmpty)
                        _buildInfoBlock(
                            Icons.access_time, "BUSINESS HOURS", hoursInfo,
                            subText: closedDaysInfo.isNotEmpty
                                ? closedDaysInfo
                                : null),

                      const SizedBox(height: 20),

                      // Description
                      Text("DESCRIPTION",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic)),
                      const SizedBox(height: 16),
                      Text(
                        description,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            height: 1.5),
                      ),

                      const SizedBox(height: 24),

                      // Other Details
                      _buildServiceInfoSection(context, serviceData, category),

                      const SizedBox(height: 32),

                      if (isOwner && !_isSold) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _markAsSold,
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text(
                              'Mark as Sold',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        if (!isOwner)
                          ChatWithSellerCard(
                            receiverUserName: contactName,
                            receiverUserID: userId,
                            productId: widget.serviceData['id'] ?? '',
                            productTitle: title,
                            isAdmin: isAdmin,
                            listingPhone: (widget.serviceData['contactPhone'] ??
                                widget.serviceData['pointOfContactPhone'] ??
                                widget.serviceData['businessContact']) as String?,
                          ),
                      ],

                      const SizedBox(height: 100), // Spacing for bottom overlay
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsRow(String city, String state, Map<String, dynamic> serviceData) {
    final locationValue = state.isNotEmpty ? '$city\n$state' : city;
    // 1. Always show Location
    List<Widget> cards = [
      Expanded(
        child: _buildHighlightCard(
          Icons.location_on_outlined,
          "LOCATION",
          locationValue,
          maxLines: 2,
        ),
      ),
    ];

    // 2. Get Map and Social Links
    final links = _getMapAndSocialLinks(serviceData);
    // 3. Add Links to cards (max 2 more cards to fit row of 3)
    // We prioritize Map > Instagram > Facebook > Others
    for (var link in links.take(2)) {
      cards.add(const SizedBox(width: 12));
      cards.add(
        Expanded(
          child: _buildHighlightCard(
            link['icon'] as IconData,
            link['label'] as String,
            link['value'] as String,
            onTap: () async {
              var url = link['url'] as String;
              final fallback = link['fallbackAddress'] as String? ?? '';
              url = await _resolveMapUrl(url, fallback);
              launchUrlString(url, mode: LaunchMode.externalApplication);
            },
          ),
        ),
      );
    }

    return Row(
      children: cards,
    );
  }

  List<Map<String, dynamic>> _getMapAndSocialLinks(
      Map<String, dynamic> serviceData) {
    List<Map<String, dynamic>> links = [];

    serviceData.forEach((key, value) {
      if (value is! String || value.isEmpty || value == 'N/A') return;

      final lowerKey = key.toLowerCase();
      final lowerValue = value.toLowerCase();

      AppLogger.d("lowerValue $lowerKey - $lowerValue");

      // Check for Map/Location links
      if (lowerKey.contains('googlemaplink')) {
        final fallbackAddress = serviceData['businessAddress'] ??
            serviceData['locationAddress'] ??
            serviceData['address'] ??
            '';
        links.add({
          'label': 'MAP',
          'value': 'Address',
          'icon': Icons.map_outlined,
          'url': value,
          'fallbackAddress': fallbackAddress,
          'priority': 1,
        });
      }
      // Check for Social Links
      else if (lowerValue.contains('instagram.com')) {
        links.add({
          'label': 'SOCIAL',
          'value': 'Instagram',
          'icon': Icons.camera_alt_outlined, // Or custom icon if available
          'url': value,
          'priority': 2,
        });
      } else if (lowerValue.contains('facebook.com')) {
        links.add({
          'label': 'SOCIAL',
          'value': 'Facebook',
          'icon': Icons.facebook,
          'url': value,
          'priority': 3,
        });
      }
      // General links if explicit keys present, though user emphasized social/map
      // We can add more specific detections if needed.
    });

    // Sort by priority
    links
        .sort((a, b) => (a['priority'] as int).compareTo(b['priority'] as int));

    // De-duplicate URLs just in case
    final uniqueLinks = <String>{};
    final distinctLinks = <Map<String, dynamic>>[];
    for (var link in links) {
      if (uniqueLinks.add(link['url'] as String)) {
        distinctLinks.add(link);
      }
    }

    return distinctLinks;
  }

  // Resolves share.google short links to a full maps.google.com URL.
  // Falls back to an address search if DNS can't reach the share.google domain.
  Future<String> _resolveMapUrl(String url, String fallbackAddress) async {
    if (!url.toLowerCase().contains('share.google')) return url;
    try {
      final client = http.Client();
      try {
        final request = http.Request('GET', Uri.parse(url));
        request.followRedirects = false;
        final response =
            await client.send(request).timeout(const Duration(seconds: 5));
        final location = response.headers['location'];
        if (location != null && location.isNotEmpty) return location;
      } finally {
        client.close();
      }
    } catch (_) {}
    // DNS or network failure — fall back to address search
    if (fallbackAddress.isNotEmpty) {
      final encoded = Uri.encodeComponent(fallbackAddress);
      return 'https://www.google.com/maps/search/?api=1&query=$encoded';
    }
    return url;
  }

  Widget _buildInfoBlock(IconData icon, String title, String content,
      {String? subText}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(icon, color: const Color(0xFF2ECC71), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: cs.onSurface.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0)),
                const SizedBox(height: 8),
                Text(content,
                    style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.3)),
                if (subText != null) ...[
                  const SizedBox(height: 4),
                  Text(subText,
                      style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.normal)),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHighlightCard(IconData icon, String label, String value,
      {VoidCallback? onTap, int maxLines = 1}) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: maxLines > 1 ? 130 : 120,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: onTap != null
              ? Border.all(color: const Color(0xFF2ECC71).withOpacity(0.3))
              : Border.all(color: cs.onSurface.withOpacity(0.06)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF2ECC71), size: 22),
            const SizedBox(height: 5),
            Text(label,
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  String? _formatProductDate(dynamic value) {
    DateTime? dt;
    if (value is Timestamp) {
      dt = value.toDate();
    } else if (value is DateTime) {
      dt = value;
    } else if (value is String && value.isNotEmpty) {
      dt = DateTime.tryParse(value);
    }
    if (dt == null) return null;
    return DateFormat('MMMM yyyy').format(dt);
  }

  Widget _buildServiceInfoSection(
      BuildContext context, Map<String, dynamic> serviceData, String category) {
    Map<String, String> allDetails = {};

    // Explicitly add items that were removed from highlights or need priority
    // Status, Address, Hours are now handled elsewhere.

    if (ProductUtils.isTrackAndTrainingCategory(category)) {
      if (serviceData['maxSlots'] != null) {
        allDetails['Max Slots'] = serviceData['maxSlots'].toString();
      }

      final startDate = serviceData['eventStartDate'];
      if (startDate != null) allDetails['Start Date'] = startDate;
      final endDate = serviceData['eventEndDate'];
      if (endDate != null) allDetails['End Date'] = endDate;
    }

    // Accessory / product specific details
    if (serviceData['isProductBikeSpecific'] == true) {
      final bikeBrand = serviceData['bikeBrandName']?.toString() ?? '';
      if (bikeBrand.isNotEmpty) allDetails['Bike Brand'] = bikeBrand;
      final bikeModel = serviceData['bikeModelName']?.toString() ?? '';
      if (bikeModel.isNotEmpty) allDetails['Bike Model'] = bikeModel;
      final bikeMfg = _formatProductDate(serviceData['bikeMfgDate']);
      if (bikeMfg != null) allDetails['Bike MFG Date'] = bikeMfg;
    }

    final productSize = serviceData['productSize']?.toString() ?? '';
    if (productSize.isNotEmpty) allDetails['Product Size'] = productSize;

    final productAging = serviceData['productAging']?.toString() ?? '';
    if (productAging.isNotEmpty) allDetails['Product Aging'] = productAging;

    if (serviceData.containsKey('isBillAvailable')) {
      allDetails['Bill Available'] =
      serviceData['isBillAvailable'] == true ? 'Yes' : 'No';
    }

    final purchaseDate = _formatProductDate(serviceData['billDate']);
    if (purchaseDate != null) allDetails['Purchase Date'] = purchaseDate;

    final warrantyValidTill = _formatProductDate(serviceData['warrantyValidTill']);
    final warrantyLimit = serviceData['warrantyLimit']?.toString() ?? '';
    if (warrantyValidTill != null || warrantyLimit.isNotEmpty) {
      allDetails['Warranty Available'] = 'Yes';
      if (warrantyValidTill != null) {
        allDetails['Warranty Valid Till'] = warrantyValidTill;
      }
      if (warrantyLimit.isNotEmpty) {
        allDetails['Remaining Warranty'] = warrantyLimit;
      }
    }

    // Remove Address/Hours manual additions from here if they exist in standard loop
    final excludeKeys = {
      'socialMediaLink',
      'googleMapLink',
      'searchKeywords',
      'shopName',
      'isActive',
      'createdAt',
      'updatedAt',
      'approvedAt',
      'statusUpdatedAt',
      'adminFeedback',
      'status',
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
      // Explicitly excluded as shown in blocks
      'businessPromoPicture',
      'shopImageUrls',
      'promoImageUrls',
      'shopGaragePics',
      'category',
      // Shown in highlights
      'businessAddress',
      // Shown in blocks
      'promoImage',
      'locationAddress',
      'city',
      'state',
      'eventStartDate',
      'eventEndDate',
      'eventStartTime',
      'eventEndTime',
      'maxSlots',
      // Rendered explicitly in the accessory/product block above
      'isProductBikeSpecific',
      'bikeBrandName',
      'bikeModelName',
      'bikeMfgDate',
      'productSize',
      'productAging',
      'billDate',
      'isBillAvailable',
      'warrantyValidTill',
      'warrantyLimit',
    };

    String formatKeyToLabel(String key) {
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
        String valueStr =
            rawValue is List ? rawValue.join(', ') : rawValue.toString();
        if (valueStr.trim().isEmpty || valueStr.toLowerCase() == 'n/a') return;

        final label = formatKeyToLabel(rawKey);
        if (!allDetails.containsKey(label)) {
          allDetails[label] = valueStr;
        }
      } catch (e) {
        /* ignore */
      }
    });

    if (allDetails.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(" DETAILS ",
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: allDetails.entries
                .map((e) => _buildDetailRow(context, e.key, e.value))
                .toList(),
          ),
        ),
      ],
    );
  }

  Map<String, String> _parseBusinessHours(String raw) {
    if (raw == 'N/A' || raw.isEmpty) {
      return {'hours': 'N/A', 'closed': ''};
    }

    // 1. Process Time: Convert 24h to 12h
    // Match HH:mm only if NOT followed by am or pm
    // logic verified in test_business_hours.dart
    final timeRegex = RegExp(r'(\d{1,2}):(\d{2})(?!\s*[aApP][mM])');
    String processedHours = raw.replaceAllMapped(timeRegex, (match) {
      int h = int.parse(match.group(1)!);
      int m = int.parse(match.group(2)!);

      final dt = DateTime(2022, 1, 1, h, m);
      return DateFormat('h:mm a').format(dt);
    });

    // 2. Calculate Closed Days
    final daysMap = {
      'mon': 'Monday',
      'tue': 'Tuesday',
      'wed': 'Wednesday',
      'thu': 'Thursday',
      'fri': 'Friday',
      'sat': 'Saturday',
      'sun': 'Sunday'
    };
    final allDaysSeq = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    Set<String> presentDays = {};
    String lowerRaw = raw.toLowerCase();

    // Check ranges "Mon-Fri"
    final rangeRegex = RegExp(
        r'(mon|tue|wed|thu|fri|sat|sun)[a-z]*\s*-\s*(mon|tue|wed|thu|fri|sat|sun)[a-z]*');
    final rangeMatch = rangeRegex.firstMatch(lowerRaw);
    if (rangeMatch != null) {
      int startIdx = allDaysSeq.indexOf(rangeMatch.group(1)!);
      int endIdx = allDaysSeq.indexOf(rangeMatch.group(2)!);
      if (startIdx != -1 && endIdx != -1) {
        if (startIdx <= endIdx) {
          for (int i = startIdx; i <= endIdx; i++) {
            presentDays.add(allDaysSeq[i]);
          }
        } else {
          for (int i = startIdx; i < 7; i++) {
            presentDays.add(allDaysSeq[i]);
          }
          for (int i = 0; i <= endIdx; i++) {
            presentDays.add(allDaysSeq[i]);
          }
        }
      }
    }

    // Check individual days
    daysMap.forEach((k, v) {
      if (lowerRaw.contains(k)) presentDays.add(k);
    });

    // Check specific "everyday" keywords
    if (lowerRaw.contains("daily") ||
        lowerRaw.contains("everyday") ||
        lowerRaw.contains("7 days")) {
      for (var d in allDaysSeq) {
        presentDays.add(d);
      }
    }

    // Calculate closed
    List<String> closedList = [];
    if (presentDays.isNotEmpty && presentDays.length < 7) {
      for (var d in allDaysSeq) {
        if (!presentDays.contains(d)) closedList.add(daysMap[d]!);
      }
    }

    String closedStr = '';
    if (closedList.isNotEmpty) {
      closedStr = '${closedList.join(", ")}: Closed';
    }

    return {'hours': processedHours, 'closed': closedStr};
  }

  Widget? _buildServiceBottomBar(bool isAdmin) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = !isAdmin && widget.serviceData['userId'] == currentUid;
    if (isOwner && _status == 'Sent Back') {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListServiceFormScreen(
                    category: widget.category,
                    existingData: widget.serviceData,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit & Resubmit'),
          ),
        ),
      );
    }
    if (isAdmin && _status != 'Approved' && _status != 'Rejected') {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: _buildAdminActionRow(),
        ),
      );
    }
    return null;
  }

  Widget _buildAdminActionRow() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _handleAdminAction('approved'),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Approve'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _handleAdminAction('sent_back'),
            icon: const Icon(Icons.undo_outlined, size: 18),
            label: const Text('Send Back'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _handleAdminAction('rejected'),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Reject'),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAdminAction(String action) async {
    final serviceId = widget.serviceData['id'] as String? ?? '';
    if (serviceId.isEmpty) return;

    String? reason;
    if (action == 'sent_back' || action == 'rejected') {
      reason = await _showReasonDialog(action);
      if (reason == null) return;
    }

    final listingRef = _repository.serviceDoc(serviceId);

    try {
      switch (action) {
        case 'approved':
          await AdminNotificationService.approveListing(
              listingRef: listingRef);
          if (!mounted) return;
          setState(() {
            _isApproved = true;
            _status = 'Approved';
          });
        case 'sent_back':
          await AdminNotificationService.sendBackListing(
              listingRef: listingRef, feedback: reason);
          if (!mounted) return;
          setState(() => _status = 'Sent Back');
        case 'rejected':
          await AdminNotificationService.rejectListing(
              listingRef: listingRef, reason: reason);
          if (!mounted) return;
          setState(() => _status = 'Rejected');
      }
      if (mounted) {
        final msg = switch (action) {
          'approved' => 'Service approved. User will be notified.',
          'sent_back' => 'Sent back to user for corrections.',
          _ => 'Listing rejected. User will be notified.',
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Action failed: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<String?> _showReasonDialog(String action) async {
    final controller = TextEditingController();
    final isSendBack = action == 'sent_back';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            Text(isSendBack ? 'Send Back for Corrections' : 'Reject Listing'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isSendBack
                  ? 'Provide feedback so the user knows what to correct:'
                  : 'Provide a reason why this listing is not eligible for Bikerverse:'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: isSendBack
                      ? 'e.g. Please upload clearer photos of the service.'
                      : 'e.g. Does not meet Bikerverse guidelines.',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSendBack ? Colors.orange : Colors.red,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              isSendBack ? 'Send Back' : 'Reject',
              style: TextStyle(
                  color: Theme.of(ctx).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );

    // Read text before any cleanup — do NOT dispose here because the dialog's
    // exit animation may still be running and the TextField listener would fire
    // on an already-disposed controller.
    final text = controller.text;
    if (confirmed != true) return null;
    return text;
  }

  Future<void> _markAsSold() async {
    final serviceId = widget.serviceData['id'] as String? ?? '';
    if (serviceId.isEmpty) return;

    final success = await AppDialogs.confirmAndMarkAsSold(
      context: context,
      docRef: _repository.serviceDoc(serviceId),
      successMessage: 'Service marked as sold.',
    );

    if (success && mounted) {
      setState(() {
        _isSold = true;
        _status = 'Sold';
      });
    }
  }
}
