import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:popp/src/api/currency_service.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:popp/src/utils/product_utils.dart';
import 'package:share_plus/share_plus.dart';

import '../admin/admin_notification_service.dart';
import '../api/api_url.dart';
import '../api/firebase/firebase_api_service.dart';
import '../chat/chat_with_seller_card.dart';
import '../services/accessories/sell_your_accessories.dart';
import '../services/bikes/sell_your_bike.dart';
import '../toolbar/AppBarIconButton.dart';
import '../utils/app_constants.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/app_network_image.dart';
import '../widgets/expandable_product_details_widget.dart';
import '../widgets/full_screen_image_screen.dart';
import '../widgets/web_constrained_box.dart';

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
  bool _hasPendingUpdate = false;
  Map<String, dynamic>? _pendingUpdate;
  bool _favButtonDisabled = false;
  String _status = '';
  String localizedPrice = '';
  bool _didInitPrice = false;
  String countryCode = '';

  // Populated by _buildHighlightsRow so ExpandableProductDetails can check
  // whether the location card was already rendered there.
  final List<Widget> _highlightCards = [];

  @override
  void initState() {
    super.initState();
    selectedImageIndexNotifier = ValueNotifier<int>(0);
    _pageController = PageController(initialPage: 0);

    _isApproved = widget.productJson['isApproved'] == true;
    _isSold = widget.productJson['isSold'] == true;
    _hasPendingUpdate = widget.productJson['hasPendingUpdate'] == true;
    _pendingUpdate = widget.productJson['pendingUpdate'] as Map<String, dynamic>?;
    final docStatus = widget.productJson['status'] as String?;
    if (_isSold) {
      _status = 'Sold';
    } else if (_isApproved && _hasPendingUpdate) {
      _status = 'Pending Update';
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

  void _shareProduct(Map<String, dynamic> product) {
    final serviceId = product['id'];
    final serviceName = ProductUtils.getTitle(product);
    // Path must be singular ("product") to match the intent-filter /
    // AppLinks parsing in main.dart — that's the actual deep link contract,
    // not the Firestore collection name (ApiUrl.productsPath is plural).
    final String deepLink = "${ApiUrl.baseUrl}product/$serviceId";
    final String shareText = "Check out $serviceName on Bikerverse! $deepLink";
    AppLogger.i("shareText $shareText");
    SharePlus.instance.share(
      ShareParams(text: shareText, subject: 'Check out this product!'),
    );
  }

  bool get _isAdmin =>
      FirebaseAuth.instance.currentUser?.uid == Constants.adminUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    // Admin reviews the proposed changes (pending update content) instead of live content
    final product = (_isAdmin && _hasPendingUpdate && _pendingUpdate != null)
        ? {...widget.productJson, ..._pendingUpdate!}
        : widget.productJson;
    final imageUrls =
        (product['thumbImageUrls'] as List<dynamic>? ?? []).cast<String>();

    return Scaffold(
      body: _buildMobileLayout(context, imageUrls, product, theme),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<String> imageUrls,
      Map<String, dynamic> product, TextTheme theme) {
    final screenHeight = MediaQuery.of(context).size.height;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = !_isAdmin && product['userId'] == currentUid;

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      body: CustomScrollView(
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
                          errorWidget: Container(color: Colors.grey[900]),
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

                  // Admin: highlight that this is a pending update review
                  if (_isAdmin && _hasPendingUpdate)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.sync_outlined, color: Colors.orange, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Reviewing pending update — approve to publish these changes, or reject to keep the current listing.',
                              style: TextStyle(color: Colors.orange, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Title
                  Text(
                    ProductUtils.getTitle(product),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
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
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  ExpandableProductDetails(
                    productJson: product,
                    // _highlightCards is populated by _buildHighlightsRow above.
                    // Location is added there only when cards.length <= 2, so
                    // show it in the details section only when it was NOT shown above.
                    showLocationDetails: _highlightCards.length > 2,
                  ),

                  if (product['additionalDetails'].isNotEmpty)
                    const Text("DESCRIPTION",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(
                    product['additionalDetails'],
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, height: 1.5),
                  ),

                  const SizedBox(height: 20),

                  if (isOwner && !_isSold) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
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
                    // Edit & Resubmit — visible for approved listings with no pending update
                    if (_isApproved && !_hasPendingUpdate) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _openEditScreen,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text(
                            'Edit & Resubmit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                    // Pending update notice — shown while an update awaits admin review
                    if (_isApproved && _hasPendingUpdate) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.pending_outlined,
                                color: Colors.blue, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your update is pending admin review. Current listing is still live.',
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ] else ...[
                    if (!isOwner)
                      ChatWithSellerCard(
                        receiverUserName: product['sellerName'],
                        receiverUserID: product['userId'],
                        productTitle: ProductUtils.getTitle(product),
                        productId: product['id'],
                        isAdmin: _isAdmin,
                        listingPhone: product['sellerContactNumber'] as String?,
                      ),
                  ],

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
    _highlightCards.clear();

    final sellerCategory = product['sellerCategory']?.toString();
    if (sellerCategory != null && sellerCategory.isNotEmpty) {
      _highlightCards.add(Expanded(
          child: _buildHighlightCard(
              Icons.person_outline, "SELLER TYPE", '$sellerCategory\n')));
    }

    final kmDriven = product['kmDriven'];
    if (kmDriven != null && kmDriven.toString() != '-') {
      _highlightCards.add(Expanded(
          child:
              _buildHighlightCard(Icons.history, "DRIVEN", "$kmDriven KM\n")));
    }

    final mfgDate = product['mfgDate'];
    if (mfgDate != null) {
      final formattedMfg = _formatDate(mfgDate, true);
      if (formattedMfg != '-') {
        _highlightCards.add(Expanded(
            child: _buildHighlightCard(
                Icons.calendar_today_outlined, "MFG DATE", '$formattedMfg\n')));
      }
    }

    String city = product['city'] ?? '';
    String state = product['state'] ?? '';
    final locationValue = state.isNotEmpty ? '$city\n$state' : city;
    if (_highlightCards.length <= 2) {
      _highlightCards.add(Expanded(
          child: _buildHighlightCard(
              Icons.location_on_outlined, "LOCATION", locationValue)));
    }

    if (_highlightCards.isEmpty) return const SizedBox.shrink();

    final children = <Widget>[];
    for (int i = 0; i < _highlightCards.length; i++) {
      children.add(_highlightCards[i]);
      if (i < _highlightCards.length - 1) {
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
              maxLines: 2,
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
    if (_isAdmin && !_isSold) {
      // Show admin bar for first-time pending reviews and for pending update reviews
      final needsReview = _status != 'Approved' && _status != 'Rejected';
      if (needsReview || _hasPendingUpdate) {
        return _buildAdminBottomBar();
      }
      // For approved listings show a standalone Mark as Sold button
      if (_status == 'Approved') {
        return _buildAdminMarkSoldBar();
      }
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final category = widget.productJson['category'] as String? ?? '';
              if (category == ProductUtils.premiumBikes) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SellYourBike(existingData: widget.productJson),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SellYourAccessories(existingData: widget.productJson),
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

  Widget _buildAdminMarkSoldBar() {
    return WebConstrainedBox(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _adminMarkAsSold,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text(
                'Mark as Sold',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _adminMarkAsSold() async {
    final productId = widget.productJson['id'] as String? ?? '';
    if (productId.isEmpty) return;

    final success = await AppDialogs.confirmAndMarkAsSold(
      context: context,
      docRef: FirebaseFirestore.instance
          .collection(ApiUrl.productsPath)
          .doc(productId),
      successMessage: 'Product marked as sold.',
    );

    if (success && mounted) {
      setState(() {
        _isSold = true;
        _status = 'Sold';
      });
    }
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
    if (_hasPendingUpdate) {
      // Reviewing a pending update on an already-approved listing
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
              onPressed: () => _handleAdminAction('approve_update'),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Approve Update'),
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
              onPressed: () => _handleAdminAction('reject_update'),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Reject Update'),
            ),
          ),
        ],
      );
    }

    // Standard first-time review buttons
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
    if (action == 'sent_back' || action == 'rejected' || action == 'reject_update') {
      reason = await _showReasonDialog(action);
      if (reason == null) return;
    }

    final listingRef = FirebaseFirestore.instance
        .collection(ApiUrl.productsPath)
        .doc(productId);

    try {
      switch (action) {
        case 'approved':
          await AdminNotificationService.approveListing(listingRef: listingRef);
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
        case 'approve_update':
          await AdminNotificationService.approvePendingUpdate(
              listingRef: listingRef, pendingUpdate: _pendingUpdate!);
          if (!mounted) return;
          setState(() {
            _hasPendingUpdate = false;
            _pendingUpdate = null;
            _status = 'Approved';
          });
        case 'reject_update':
          await AdminNotificationService.rejectPendingUpdate(
              listingRef: listingRef, feedback: reason);
          if (!mounted) return;
          setState(() {
            _hasPendingUpdate = false;
            _pendingUpdate = null;
            _status = 'Approved';
          });
      }
      if (mounted) {
        final msg = switch (action) {
          'approved' => 'Product approved. User will be notified.',
          'sent_back' => 'Sent back to user for corrections.',
          'approve_update' => 'Update approved and published.',
          'reject_update' => 'Update rejected. Original listing remains live.',
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
              content: Text('Action failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<String?> _showReasonDialog(String action) async {
    final controller = TextEditingController();
    final isSendBack = action == 'sent_back';
    final isRejectUpdate = action == 'reject_update';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isSendBack
            ? 'Send Back for Corrections'
            : isRejectUpdate
                ? 'Reject Update'
                : 'Reject Listing'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isSendBack
                  ? 'Provide feedback so the user knows what to correct:'
                  : isRejectUpdate
                      ? 'Provide a reason for rejecting this update (optional):'
                      : 'Provide a reason why this listing is not eligible for Bikerverse:'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: isSendBack
                      ? 'e.g. Please upload clearer photos of the item.'
                      : isRejectUpdate
                          ? 'e.g. Price update not within guidelines.'
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
              isSendBack ? 'Send Back' : isRejectUpdate ? 'Reject Update' : 'Reject',
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

  Future<void> _markAsSold() async {
    final productId = widget.productJson['id'] as String? ?? '';
    if (productId.isEmpty) return;

    final success = await AppDialogs.confirmAndMarkAsSold(
      context: context,
      docRef: FirebaseFirestore.instance
          .collection(ApiUrl.productsPath)
          .doc(productId),
      successMessage: 'Item marked as sold.',
    );

    if (success && mounted) {
      setState(() {
        _isSold = true;
        _status = 'Sold';
      });
    }
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
        selectOnlyMonthYear ? 'MMMM yyyy' : 'd MMM yyyy';
    return DateFormat(displayFormat).format(dt);
  }

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
      case 'pending update':
        return (Colors.purple.shade600, Icons.sync_outlined);
      default:
        return (Colors.orange.shade700, Icons.hourglass_top_outlined);
    }
  }

  void _openEditScreen() {
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
