import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:popp/src/widgets/title_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../widgets/web_constrained_box.dart';

import '../../api/api_url.dart';
import '../../api/firebase/firebase_api_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/product_utils.dart';
import '../../chat/chat_with_user_widget.dart';
import '../../widgets/full_screen_image_screen.dart';
import '../../widgets/web_image_gallery.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../toolbar/AppBarIconButton.dart';

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
    // String appBarTitle = ProductUtils.getServiceAppBarTitle(widget.category);
    return Scaffold(
      body: kIsWeb ? _buildWebLayout(context) : _buildBody(context),
      bottomNavigationBar: !kIsWeb && isAdmin && !_isApproved
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
                              if (!mounted) return;
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

  Widget _buildWebLayout(BuildContext context) {
    final serviceData = widget.serviceData;
    // Prepare images
    List<String> allImageUrls = [];
    if (serviceData['promoImageUrls'] is List) {
      allImageUrls
          .addAll((serviceData['promoImageUrls'] as List).cast<String>());
    } else if (serviceData['promoImageUrls'] is String &&
        (serviceData['promoImageUrls'] as String).isNotEmpty) {
      allImageUrls.add(serviceData['promoImageUrls']);
    }
    if (serviceData['shopImageUrls'] is List) {
      allImageUrls
          .addAll((serviceData['shopImageUrls'] as List).cast<String>());
    }

    String title = serviceData['businessTitle'] ??
        serviceData['eventName'] ??
        'Service Details';
    String description = serviceData['businessDescription'] ??
        serviceData['eventDetailedDescription'] ??
        'No description available.';

    // Admin check for button
    final isAdmin =
        FirebaseAuth.instance.currentUser?.uid == Constants.adminUserId;

    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section: Images and Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Images
                  Expanded(
                    flex: 1,
                    child: WebImageGallery(
                      imageUrls: allImageUrls,
                      selectedIndexNotifier:
                          ValueNotifier<int>(_selectedImageIndex)
                            ..addListener(() {}),
                    ),
                  ),
                  const SizedBox(width: 40),

                  // Right Column: Details
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Share
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TitleText(
                                title,
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                  _isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red),
                              onPressed:
                                  _favButtonDisabled ? null : _toggleFavorite,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (!_isApproved) ...[
                              const Icon(Icons.info_outline,
                                  color: Colors.orange, size: 18),
                              const SizedBox(width: 4),
                              const Text("Pending Approval",
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 16),
                            ],
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Details Section (Status, Address, Hours, etc.)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWebDetailRow(context, "Status",
                                  serviceData['status'] ?? 'N/A'),
                              if (ProductUtils.isBikeAndOthersCategory(
                                  widget.category)) ...[
                                _buildWebDetailRow(context, "Address",
                                    serviceData['businessAddress'] ?? 'N/A',
                                    isLink: true, isMap: true),
                                _buildWebDetailRow(
                                    context,
                                    "Hours",
                                    serviceData['businessWorkingDaysHours'] ??
                                        'N/A'),
                              ],
                              // Additional Service Details could go here if extracted
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        if (isAdmin && !_isApproved)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                onPressed: () async {
                                  final serviceId =
                                      widget.serviceData['id'] ?? '';
                                  if (serviceId != '') {
                                    await _firebaseApiService
                                        .updateServiceApprovalStatus(
                                            serviceId, true);
                                    setState(() {
                                      _isApproved = true;
                                    });
                                  }
                                },
                                child: const Text("Approve Service"),
                              ),
                            ),
                          ),

                        ChatWithSellerCard(
                          receiverUserName: serviceData['contactName'] ??
                              serviceData['pointOfContactName'] ??
                              '',
                          receiverUserID: serviceData['userId'] ?? '',
                          productId: serviceData['id'] ?? '',
                          productTitle: title,
                          isOwner: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Bottom Section: About This Service
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "About This Service",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(height: 1.6, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebDetailRow(BuildContext context, String label, String value,
      {bool isLink = false, bool isMap = false}) {
    if (value == 'N/A' || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text("$label:",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(
            child: isLink
                ? GestureDetector(
                    onTap: () async {
                      if (isMap) {
                        final encoded = Uri.encodeComponent(value);
                        launchUrlString(
                            'https://www.google.com/maps/search/?api=1&query=$encoded',
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Text(value,
                        style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline)),
                  )
                : Text(value,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
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
        final encoded = Uri.encodeComponent(value);
        launchUrlString(
            'https://www.google.com/maps/search/?api=1&query=$encoded',
            mode: LaunchMode.externalApplication);
      };
    } else if (label.toLowerCase().contains('phone') ||
        label.toLowerCase().contains('contact')) {
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
                style: const TextStyle(
                    color: Colors.grey,
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
                              color: isLink ? Colors.blue : Colors.white,
                              fontSize: 13,
                              decoration:
                                  isLink ? TextDecoration.underline : null))),
                  if (icon != null) ...[
                    const SizedBox(width: 4),
                    Icon(icon,
                        color: isLink ? Colors.blue : Colors.grey, size: 14)
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final serviceData = widget.serviceData;
    final category = widget.category;

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
          ? DateFormat('MMM d')
              .format(DateTime.parse(serviceData['eventStartDate']))
          : '';
      String startTime = serviceData['eventStartTime'] ?? '';

      if (startDate.isNotEmpty) {
        hoursInfo = '$startDate, $startTime';
      } else {
        hoursInfo = serviceData['eventStartTime'] ?? 'N/A';
      }
      if (hoursInfo == 'N/A' || hoursInfo.trim().isEmpty)
        hoursInfo = 'Check details';
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
      backgroundColor: const Color(0xFF121212), // Dark background
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFF121212),
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
                              child: Image.network(
                                allImageUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(color: Colors.grey[900]),
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: Icon(Icons.image_not_supported,
                                color: Colors.white24, size: 50),
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
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xFF121212), Colors.transparent],
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
                      // // Category Tag
                      // Text(category.toUpperCase(),
                      //     style: const TextStyle(
                      //         color: Color(0xFF2ECC71),
                      //         fontSize: 12,
                      //         fontWeight: FontWeight.bold,
                      //         letterSpacing: 1.2)),
                      // const SizedBox(height: 8),
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                          fontFamily: 'Orbitron',
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // 1. Highlight Cards Row (Location, Category, Status)
                      _buildHighlightsRow(city, category, status),

                      const SizedBox(height: 24),

                      // 2. Address Block
                      if (fullAddress != 'N/A' && fullAddress.isNotEmpty)
                        _buildInfoBlock(
                            Icons.location_on_outlined, "ADDRESS", fullAddress),

                      const SizedBox(height: 16),

                      // 3. Business Hours Block
                      if (hoursInfo != 'N/A' && hoursInfo.isNotEmpty)
                        _buildInfoBlock(
                            Icons.access_time, "BUSINESS HOURS", hoursInfo,
                            subText: closedDaysInfo.isNotEmpty
                                ? closedDaysInfo
                                : null),

                      const SizedBox(height: 32),

                      // Description
                      const Text("DESCRIPTION",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic)),
                      const SizedBox(height: 16),
                      Text(
                        description,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14, height: 1.5),
                      ),

                      const SizedBox(height: 24),

                      // Other Details
                      _buildServiceInfoSection(context, serviceData, category),

                      const SizedBox(height: 32),

                      // Chat With Seller Card (original place)
                      ChatWithSellerCard(
                        receiverUserName: contactName,
                        receiverUserID: userId,
                        productId: widget.serviceData['id'] ?? '',
                        productTitle: title,
                      ),

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

  Widget _buildHighlightsRow(String city, String category, String status) {
    return Row(
      children: [
        Expanded(
            child: _buildHighlightCard(
                Icons.location_on_outlined, "LOCATION", city)),
        const SizedBox(width: 12),
        Expanded(
            child:
                _buildHighlightCard(Icons.star_border, "CATEGORY", category)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildHighlightCard(Icons.access_time, "STATUS", status)),
      ],
    );
  }

  Widget _buildInfoBlock(IconData icon, String title, String content,
      {String? subText}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
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
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0)),
                const SizedBox(height: 8),
                Text(content,
                    style: const TextStyle(
                        color: Colors.white,
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

  Widget _buildHighlightCard(IconData icon, String label, String value) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF2ECC71), size: 22),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
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

    // Remove Address/Hours manual additions from here if they exist in standard loop
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
      // Explicitly excluded as shown in blocks
      'businessPromoPicture',
      'shopImageUrls',
      'promoImageUrls',
      'shopGaragePics',
      'category',
      'status',
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
      'maxSlots'
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
        const Text(" DETAILS ",
            style: TextStyle(
                color: Colors.white,
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
}
