import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/models/product.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../api/api_url.dart';
import '../firebase/firebase_api_service.dart';
import '../utils/app_constants.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/chat_with_user_widget.dart';
import '../widgets/expandable_product_details_widget.dart';
import '../widgets/expandable_text_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productJson;
  final bool showStatus;

  const ProductDetailScreen(
      {super.key, required this.productJson, this.showStatus = false});

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

  void _shareProduct(Product product) {
    final serviceId = widget.productJson['id'];
    final serviceName = product.getTitle();
    final String deepLink = "${ApiUrl.productsPath}/$serviceId";
    final String shareText = "Check out $serviceName on POPP! $deepLink";
    AppLogger.i("shareText $shareText");
    Share.share(shareText, subject: 'Check out this product!');
  }

  bool get _isAdmin =>
      FirebaseAuth.instance.currentUser?.uid == Constants.adminUserId;

  // Helper to get styling for status (reused from ListingCard) ---
  (Color, IconData) _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'sold':
        return (Colors.grey.shade700, Icons.money_off_outlined);
      case 'approved':
        return (Colors.green.shade600, Icons.check_circle_outline);
      default: // 'Pending'
        return (Colors.orange.shade700, Icons.hourglass_top_outlined);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final product =
        Product.fromJson(widget.productJson, widget.productJson['id']);
    final imageUrls = product.thumbImageUrls ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(product.subCategory != null &&
                product.subCategory.toString().isNotEmpty
            ? '${product.category} - ${product.subCategory}'
            : product.category),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareProduct(product),
            tooltip: 'Share Product',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ValueListenableBuilder<int>(
                    valueListenable: selectedImageIndexNotifier,
                    builder: (context, selectedImageIndex, _) {
                      return PageView.builder(
                        controller: _pageController,
                        itemCount: imageUrls.length,
                        onPageChanged: (index) {
                          selectedImageIndexNotifier.value = index;
                        },
                        itemBuilder: (context, index) {
                          final url =
                              imageUrls.isNotEmpty ? imageUrls[index] : '';
                          return _buildImage(url, useHero: index == 0);
                        },
                      );
                    },
                  ),
                  // --- NEW: Status Banner on the main image ---
                  if (widget.showStatus) _buildStatusBanner(),
                  Positioned(
                    top: 32,
                    right: 16,
                    child: GestureDetector(
                      onTap: _favButtonDisabled ? null : _toggleFavorite,
                      child: CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 32,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ValueListenableBuilder<int>(
                        valueListenable: selectedImageIndexNotifier,
                        builder: (context, selectedImageIndex, _) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(imageUrls.length, (index) {
                              bool isActive = index == selectedImageIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: isActive ? 20 : 12,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.white54
                                      : Colors.black26,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 12,
                    child: ValueListenableBuilder<int>(
                      valueListenable: selectedImageIndexNotifier,
                      builder: (context, selectedImageIndex, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${selectedImageIndex + 1} / ${imageUrls.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (imageUrls.length > 1)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    final url = imageUrls[index];
                    return ValueListenableBuilder<int>(
                      valueListenable: selectedImageIndexNotifier,
                      builder: (context, selectedImageIndex, _) {
                        return GestureDetector(
                          onTap: () {
                            selectedImageIndexNotifier.value = index;
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: selectedImageIndex == index
                                      ? Colors.blue
                                      : Colors.transparent,
                                  width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                url,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // --- Product Title with expandable logic ---
                  ExpandableText(
                    text: product.getTitle(),
                    style: theme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.expectedPrice,
                    style: theme.titleLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ExpandableProductDetails(product: product),
                  const SizedBox(height: 20),
                  ChatWithSellerCard(
                    receiverUserName: product.sellerName,
                    receiverUserID: product.sellerContactNumber,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isAdmin && !_isApproved
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
                            if (product.id != null) {
                              await FirebaseApiService()
                                  .updateProductApprovalStatus(
                                      product.id ?? '', true);
                              setState(() {
                                _isApproved = true;
                                _status = 'Approved';
                              });
                              if (_isApproved) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Product "${product.getBrandAndModelName()}" approved successfully!',
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
            )
          : null,
    );
  }

  // --- NEW: Widget for the status banner on the image ---
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
              topLeft: Radius.circular(0), // Aligns with corner
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
