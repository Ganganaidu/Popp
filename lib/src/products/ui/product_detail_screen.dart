import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:popp/src/api/currency_service.dart';
import 'package:popp/src/utils/product_utils.dart';
import 'package:provider/provider.dart';

import '../../chat/chat_with_seller_card.dart';
import '../../navigation/app_routes.dart';
import '../../toolbar/AppBarIconButton.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/expandable_product_details_widget.dart';
import '../../widgets/full_screen_image_screen.dart';
import '../../widgets/web_constrained_box.dart';
import '../viewmodel/product_detail_viewmodel.dart';

/// Product detail screen. All state and Firestore work lives in
/// [ProductDetailViewModel], provided at the route (see `app_router.dart`). This
/// widget only renders that state and forwards user intent.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final ValueNotifier<int> selectedImageIndexNotifier;
  late final PageController _pageController;
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductDetailViewModel>();
    final theme = Theme.of(context).textTheme;
    final product = vm.product;
    final imageUrls =
        (product['thumbImageUrls'] as List<dynamic>? ?? []).cast<String>();

    return Scaffold(
      body: _buildMobileLayout(context, vm, imageUrls, product, theme),
      bottomNavigationBar: _buildBottomBar(vm),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ProductDetailViewModel vm,
      List<String> imageUrls, Map<String, dynamic> product, TextTheme theme) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isOwner = vm.isOwner;

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
                onTap: vm.shareProduct,
              ),
              const SizedBox(width: 12),
              AppBarIconButton(
                  icon: vm.isFavorite ? Icons.favorite : Icons.favorite_border,
                  onTap: vm.toggleFavorite,
                  iconColor: vm.isFavorite ? Colors.red : null),
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

                  if (isOwner && !vm.isSold) ...[
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
                        onPressed: () => _markAsSold(vm),
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
                        receiverUserName: product['sellerName'],
                        receiverUserID: product['userId'],
                        productTitle: ProductUtils.getTitle(product),
                        productId: product['id'],
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

  Widget? _buildBottomBar(ProductDetailViewModel vm) {
    if (kIsWeb) return null;
    if (vm.isOwner && vm.status == 'Sent Back') {
      return _buildUserEditButton(vm);
    }
    if (vm.isAdmin &&
        vm.status != 'Approved' &&
        vm.status != 'Rejected' &&
        vm.status != 'Sold') {
      return _buildAdminBottomBar(vm);
    }
    return null;
  }

  Widget _buildUserEditButton(ProductDetailViewModel vm) {
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
              final category = vm.product['category'] as String? ?? '';
              if (category == ProductUtils.premiumBikes) {
                context.pushSellBike(existingData: vm.product);
              } else {
                context.pushSellAccessories(existingData: vm.product);
              }
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit & Resubmit'),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminBottomBar(ProductDetailViewModel vm) {
    return WebConstrainedBox(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: _buildAdminActionRow(vm),
        ),
      ),
    );
  }

  Widget _buildAdminActionRow(ProductDetailViewModel vm) {
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
            onPressed: () => _handleAdminAction(vm, 'approved'),
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
            onPressed: () => _handleAdminAction(vm, 'sent_back'),
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
            onPressed: () => _handleAdminAction(vm, 'rejected'),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Reject'),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAdminAction(
      ProductDetailViewModel vm, String action) async {
    String? reason;
    if (action == 'sent_back' || action == 'rejected') {
      reason = await _showReasonDialog(action);
      if (reason == null) return;
    }

    try {
      final msg = await vm.runAdminAction(action, reason: reason);
      if (mounted && msg != null) {
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

  Future<void> _markAsSold(ProductDetailViewModel vm) async {
    if (vm.productId.isEmpty) return;

    final success = await AppDialogs.confirmAndMarkAsSold(
      context: context,
      docRef: vm.repository.productDoc(vm.productId),
      successMessage: 'Item marked as sold.',
    );

    if (success && mounted) {
      vm.onMarkedSold();
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
}
