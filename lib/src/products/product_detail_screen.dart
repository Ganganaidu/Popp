import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:popp/src/api/currency_service.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:popp/src/utils/product_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../api/api_url.dart';
import '../api/firebase/firebase_api_service.dart';
import '../chat/chat_with_user_widget.dart';
import '../toolbar/AppBarIconButton.dart';
import '../utils/app_constants.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/expandable_product_details_widget.dart';
import '../widgets/full_screen_image_screen.dart';
import '../widgets/web_constrained_box.dart';
import '../widgets/web_image_gallery.dart';
import '../widgets/web_product_specs.dart';

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
    if (_isSold) {
      _status = 'Sold';
    } else if (_isApproved) {
      _status = 'Approved';
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
    final imageWidget = Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 400,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            color: Colors.white,
            width: double.infinity,
            height: 400,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          width: double.infinity,
          height: 400,
          child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
        );
      },
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
      bottomNavigationBar:
          !kIsWeb && _isAdmin && !_isApproved ? _buildAdminBottomBar() : null,
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

                        // Admin Approve Button
                        if (_isAdmin && !_isApproved)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () async {
                                  await FirebaseApiService()
                                      .updateProductApprovalStatus(
                                          product['id'], true);
                                  setState(() {
                                    _isApproved = true;
                                    _status = 'Approved';
                                  });
                                },
                                child: const Text("Approve Product"),
                              ),
                            ),
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

  Widget _buildMobileLayout(BuildContext context, List<String> imageUrls,
      Map<String, dynamic> product, TextTheme theme) {
    final screenHeight = MediaQuery.of(context).size.height;

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
                        child: Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
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

    final mfgDate = _formatDate(product['mfgDate'], true);
    if (mfgDate != "-") {
      cards.add(Expanded(
          child: _buildHighlightCard(
              Icons.calendar_today_outlined, "MANUFACTURING", mfgDate)));
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

  Widget _buildAdminBottomBar() {
    return WebConstrainedBox(
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isApproved ? Colors.green : Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isApproved
                  ? null
                  : () async {
                      if (widget.productJson['id'] != null) {
                        await FirebaseApiService().updateProductApprovalStatus(
                            widget.productJson['id'], true);
                        if (!mounted) return;
                        setState(() {
                          _isApproved = true;
                          _status = 'Approved';
                        });
                        if (_isApproved) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Product "${widget.productJson['brandName'] ?? widget.productJson['title']}" approved successfully!',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
              child: Text(_isApproved ? 'Approved' : 'Approve'),
            ),
          ),
        ),
      ),
    );
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
        selectOnlyMonthYear ? 'MMMM yyyy' : 'd MMMM yyyy';
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
