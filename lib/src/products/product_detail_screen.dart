import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:popp/src/api/currency_service.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:popp/src/utils/product_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../admin/admin_notification_service.dart';
import '../api/api_url.dart';
import '../api/firebase/firebase_api_service.dart';
import '../chat/chat_with_seller_card.dart';
import '../services/accessories/sell_your_accessories.dart';
import '../services/bikes/sell_your_bike.dart';
import '../toolbar/AppBarIconButton.dart';
import '../utils/app_constants.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/expandable_product_details_widget.dart';
import '../widgets/full_screen_image_screen.dart';
import '../widgets/web_constrained_box.dart';
import '../widgets/web_image_gallery.dart';
import '../widgets/web_product_specs.dart';
import '../widgets/app_network_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productJson;
  final bool showStatus;

  const ProductDetailScreen({
    super.key,
    required this.productJson,
    this.showStatus = false,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FirebaseApiService _firebaseApiService = FirebaseApiService();

  late final ValueNotifier<int> selectedImageIndexNotifier;
  bool isFavorite = false;
  late final PageController _pageController;
  bool _isApproved = false;
  bool _isSold = false;
  bool _favButtonDisabled = false;
  String _status = '';
  String localizedPrice = '';
  bool _didInitPrice = false;
  String countryCode = '';

  @override
  void initState() {
    super.initState();
    selectedImageIndexNotifier = ValueNotifier<int>(0);
    _pageController = PageController(initialPage: 0);

    _isApproved = widget.productJson['isApproved'] == true;
    _isSold = widget.productJson['isSold'] == true;
    final docStatus = widget.productJson['status'] as String?;
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

    AppLogger.d("ProductDetailScreen initState: status = $_status");

    final favoritedBy = widget.productJson['favoritedBy'] as List<dynamic>?;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (favoritedBy != null && currentUser != null) {
      isFavorite = favoritedBy.contains(currentUser.uid);
    } else {
      isFavorite = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitPrice) {
      countryCode = Localizations.localeOf(context).countryCode ?? 'US';
      _didInitPrice = true;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    selectedImageIndexNotifier.dispose();
    super.dispose();
  }

  void _toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
      _favButtonDisabled = true;
    });
    final prev = isFavorite;
    final result = await _firebaseApiService.toggleFavoriteProduct(
        ApiUrl.productsPath, widget.productJson['id']);
    if (!mounted) return;
    setState(() {
      _favButtonDisabled = false;
      if (!result) {
        isFavorite = !prev;
      }
    });
  }

  Widget _buildImage(String url, {bool useHero = false}) {
    final imageWidget = AppNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 400,
      placeholder: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          color: Colors.white,
          width: double.infinity,
          height: 400,
        ),
      ),
      errorWidget: Container(
        color: Colors.grey[200],
        width: double.infinity,
        height: 400,
        child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
      ),
    );

    return useHero
        ? Hero(
            tag: widget.productJson['imageUrl'] ?? '',
            child: imageWidget,
          )
        : imageWidget;
  }

  void _shareProduct(Map<String, dynamic> product) {
    final serviceId = product['id'];
    final serviceName = product['title'] ?? '';
    final String deepLink = "${ApiUrl.productsPath}/$serviceId";
    final String shareText = "Check out $serviceName on Bikerverse! $deepLink";
    AppLogger.i("shareText $shareText");
    Share.share(shareText, subject: 'Check out this product!');
  }

  bool get _isAdmin =>
      FirebaseAuth.instance.currentUser?.uid == Constants.adminUserId;

  (Color, IconData) _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'sold':
        return (Colors.grey.shade700, Icons.money_off_outlined);
      case 'approved':
        return (Colors.green.shade600, Icons.check_circle_outline);
      case 'sent back':
        return (Colors.blue.shade600, Icons.undo_outlined);
      case 'rejected':
        return (Colors.red.shade700, Icons.cancel_outlined);
      default:
        return (Colors.orange.shade700, Icons.hourglass_top_outlined);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final product = widget.productJson;
    final imageUrls =
        (product['thumbImageUrls'] as List<dynamic>? ?? []).cast<String>();

    return Scaffold(
      body: kIsWeb
          ? _buildWebLayout(context, imageUrls, product, theme)
          : _buildMobileLayout(context, imageUrls, product, theme),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildWebLayout(BuildContext context, List<String> imageUrls,
      Map<String, dynamic> product, TextTheme theme) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section: Images and Key Details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Images
                  Expanded(
                    flex: 1,
                    child: WebImageGallery(
                      imageUrls: imageUrls,
                      selectedIndexNotifier: selectedImageIndexNotifier,
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
                              child: Text(
                                ProductUtils.getTitle(product),
                                style: theme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed:
                                  _favButtonDisabled ? null : _toggleFavorite,
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Status and Location
                        Row(
                          children: [
                            if (widget.showStatus) ...[
                              Icon(_getStatusStyle(_status).$2,
                                  color: _getStatusStyle(_status).$1, size: 18),
                              const SizedBox(width: 4),
                              Text(_status,
                                  style: TextStyle(
                                      color: _getStatusStyle(_status).$1,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 16),
                            ],
                            const Icon(Icons.location_on_outlined,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${product['city']}, ${product['state']}',
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Price Card
                        Container(
                          width: double.infinity,
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
                              Text(
                                CurrencyService.getProductPrice(
                                    product['expectedPrice'], countryCode),
                                style: theme.displayMedium?.copyWith(
                                  color: Colors.green, // Match design green
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Posted on ${_formatDate(product['createdAt']?.toDate(), false)}",
                                style: const TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Specifications
                        const Text(
                          "Specifications",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // Web version of specs
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: WebProductSpecs(productJson: product),
                        ),

                        const SizedBox(height: 24),

                        // Chat Button
                        ChatWithSellerCard(
                          receiverUserName: product['sellerName'],
                          receiverUserID: product['userId'],
                          productTitle: ProductUtils.getTitle(product),
                          productId: product['id'],
                        ),

                        const SizedBox(height: 16),

                        if (_isAdmin && _status != 'Approved' && _status != 'Rejected' && _status != 'Sold')
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: _buildAdminActionRow(),
                          ),
                        if (!_isAdmin &&
                            _status == 'Sent Back' &&
                            widget.productJson['userId'] ==
                                FirebaseAuth.instance.currentUser?.uid)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: _buildUserEditButton(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Bottom Section: About This Product
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
                      "About This Product",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product['additionalDetails'] ??
                          'No description available.',
                      style:
                          theme.bodyLarge?.copyWith(height: 1.6, fontSize: 16),
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

  Widget _buildBreadcrumbTitle(BuildContext context, List<String> crumbs) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < crumbs.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.chevron_right_rounded,
                    size: 14, color: Colors.white54),
              ),
            Text(
              crumbs[i],
              style: TextStyle(
                fontSize: 12,
                fontWeight: i == crumbs.length - 1
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: i == crumbs.length - 1
                    ? Colors.white
                    : Colors.orange.shade300,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<String> imageUrls,
      Map<String, dynamic> product, TextTheme theme) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Build breadcrumb: Home / Category / SubCategory? / Title
    final category = (product['category'] as String? ?? '');
    final subCategory = (product['subCategory'] as String? ?? '');
    final title = ProductUtils.getTitle(product);
    final List<String> crumbs = ['Home'];
    if (category.isNotEmpty) crumbs.add(category);
    if (subCategory.isNotEmpty) crumbs.add(subCategory);
    if (title.isNotEmpty) crumbs.add(title);

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF121212),
            expandedHeight: screenHeight * 0.45,
            pinned: true,
            title: _buildBreadcrumbTitle(context, crumbs),
            leading: Center(
              child: AppBarIconButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              AppBarIconButton(
                icon: Icons.share,
                onTap: () => _shareProduct(product),
              ),
              const SizedBox(width: 12),
              AppBarIconButton(
                  icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                  onTap: () {
                    // Ensure we call the toggle function immediately.
                    if (!_favButtonDisabled) _toggleFavorite();
                  },
                  iconColor: isFavorite ? Colors.red : null),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: imageUrls.length,
                    onPageChanged: (index) {
                      selectedImageIndexNotifier.value = index;
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (imageUrls.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) => FullScreenImageScreen(
                                  imageUrls: imageUrls,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          }
                        },
                        child: AppNetworkImage(
                          imageUrl: imageUrls[index],
                          fit: BoxFit.cover,
                          errorWidget:
                              Container(color: Colors.grey[900]),
                        ),
                      );
                    },
                  ),
                  // Gradient for better icon visibility on bright images
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
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
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
                          colors: [
                            Color(0xFF121212),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: ValueListenableBuilder<int>(
                        valueListenable: selectedImageIndexNotifier,
                        builder: (context, selectedIndex, _) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(imageUrls.length, (index) {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: selectedIndex == index ? 24 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: selectedIndex == index
                                      ? const Color(0xFF2ECC71)
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          );
                        },
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
                  // Title
                  Text(
                    ProductUtils.getTitle(product),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Price
                  Text(
                    CurrencyService.getProductPrice(
                        product['expectedPrice'], countryCode),
                    style: const TextStyle(
                      color: Color(0xFF2ECC71), // Bright Green
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 32),
                  // Highlights Row
                  _buildHighlightsRow(product),

                  const SizedBox(height: 32),

                  const Text(" DETAILS ",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  const SizedBox(height: 24),

                  ExpandableProductDetails(productJson: product),

                  if (product['additionalDetails'].isNotEmpty)
                    const Text("DESCRIPTION",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic)),
                  const SizedBox(height: 16),
                  Text(
                    product['additionalDetails'],
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, height: 1.5),
                  ),

                  const SizedBox(height: 20),

                  ChatWithSellerCard(
                    receiverUserName: product['sellerName'],
                    receiverUserID: product['userId'],
                    productTitle: ProductUtils.getTitle(product),
                    productId: product['id'],
                  ),

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsRow(Map<String, dynamic> product) {
    final cards = <Widget>[];

    final sellerCategory = product['sellerCategory']?.toString();
    if (sellerCategory != null && sellerCategory.isNotEmpty) {
      cards.add(Expanded(
          child: _buildHighlightCard(
              Icons.person_outline, "SELLER TYPE", sellerCategory)));
    }

    final kmDriven = product['kmDriven'];
    if (kmDriven != null && kmDriven.toString() != '-') {
      cards.add(Expanded(
          child: _buildHighlightCard(Icons.history, "DRIVEN", "$kmDriven KM")));
    }

    final firstOwner = product['firstOwner'];
    if (firstOwner != null && firstOwner.toString() != '-') {
      cards.add(Expanded(
          child: _buildHighlightCard(
              Icons.settings_outlined, "OWNERSHIP", "$firstOwner Owner")));
    }

    if (cards.isEmpty) return const SizedBox.shrink();

    final children = <Widget>[];
    for (int i = 0; i < cards.length; i++) {
      children.add(cards[i]);
      if (i < cards.length - 1) {
        children.add(const SizedBox(width: 12));
      }
    }

    return Row(children: children);
  }

  Widget _buildHighlightCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget? _buildBottomBar() {
    if (kIsWeb) return null;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = !_isAdmin && widget.productJson['userId'] == currentUid;
    if (isOwner && _status == 'Sent Back') {
      return _buildUserEditButton();
    }
    if (_isAdmin && _status != 'Approved' && _status != 'Rejected' && _status != 'Sold') {
      return _buildAdminBottomBar();
    }
    return null;
  }

  Widget _buildUserEditButton() {
    return WebConstrainedBox(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final category = widget.productJson['category'] as String? ?? '';
              if (category == ProductUtils.premiumBikes) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SellYourBike(existingData: widget.productJson),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SellYourAccessories(existingData: widget.productJson),
                  ),
                );
              }
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit & Resubmit'),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminBottomBar() {
    return WebConstrainedBox(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: _buildAdminActionRow(),
        ),
      ),
    );
  }

  Widget _buildAdminActionRow() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
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
              foregroundColor: Colors.white,
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
              foregroundColor: Colors.white,
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
    final productId = widget.productJson['id'] as String? ?? '';
    if (productId.isEmpty) return;

    String? reason;
    if (action == 'sent_back' || action == 'rejected') {
      reason = await _showReasonDialog(action);
      if (reason == null) return;
    }

    final listingRef = FirebaseFirestore.instance
        .collection(ApiUrl.productsPath)
        .doc(productId);

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
          'approved' => 'Product approved. User will be notified.',
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
        title: Text(isSendBack ? 'Send Back for Corrections' : 'Reject Listing'),
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
                      ? 'e.g. Please upload clearer photos of the item.'
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
              style: const TextStyle(color: Colors.white),
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

  String _formatDate(dynamic date, bool selectOnlyMonthYear) {
    if (date == null) return "-";
    DateTime dt;
    if (date is DateTime) {
      dt = date;
    } else {
      try {
        dt = date.toDate();
      } catch (e) {
        return "-";
      }
    }
    final String displayFormat =
        selectOnlyMonthYear ? 'MMMM yyyy' : 'dd/MM/yyyy';
    return DateFormat(displayFormat).format(dt);
  }

  Widget _buildStatusBanner() {
    final (color, icon) = _getStatusStyle(_status);
    return Positioned(
      top: 0,
      left: 0,
      child: GestureDetector(
        onTap: () {
          AppDialogs.showProductSuccessDialog(context, () {}, () {},
              title: 'Product Status: $_status',
              cancelText: null,
              confirmText: 'okay');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(0),
              bottomRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 5,
                offset: const Offset(2, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                _status,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
