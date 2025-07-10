import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:popp/src/models/product.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../api/currency_service.dart';
import '../firebase/firebase_save_prodcuts_api.dart';
import '../utils/app_constants.dart';
import '../widgets/chat_with_user_widget.dart';
import '../widgets/expandable_product_details_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productJson;

  const ProductDetailScreen({super.key, required this.productJson});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final ValueNotifier<int> selectedImageIndexNotifier;
  bool isFavorite = false;
  late final PageController _pageController;
  final CurrencyService _currencyService = CurrencyService();
  bool _isApproved = false;
  bool _favButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    selectedImageIndexNotifier = ValueNotifier<int>(0);
    _pageController = PageController(initialPage: 0);
    _isApproved = widget.productJson['isApproved'] == true;
    AppLogger.d("ProductDetailScreen initState: isApproved = $_isApproved");
    // Set initial favorite state based on favoritedBy
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
    });
    final prev = isFavorite;
    setState(() {
      _favButtonDisabled = true;
    });
    final result = await toggleFavoriteProduct(
        Constants.productsPath, widget.productJson['id']);
    setState(() {
      _favButtonDisabled = false;
      if (!result) {
        isFavorite = !prev; // revert if failed
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

  // Function to handle sharing ---
  void _shareProduct(Product product) {
    final serviceId = widget.productJson['id'];
    final serviceName = product.getTitle();

    // This is your deep link. Ensure your domain is correct.
    final String deepLink = "${Constants.productsPath}/$serviceId";

    final String shareText = "Check out $serviceName on POPP! $deepLink";
    AppLogger.i("shareText $shareText");
    Share.share(shareText, subject: 'Check out this product!');
  }

  bool get _isAdmin =>
      FirebaseAuth.instance.currentUser?.uid == Constants.adminUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final product =
        Product.fromJson(widget.productJson, widget.productJson['id']);
    final imageUrls = product.thumbImageUrls ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(product.getBrandAndModelName()),
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
            expandedHeight: 400.0,
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
                          return _buildImage(
                            url,
                            useHero: index == 0,
                          );
                        },
                      );
                    },
                  ),
                  // Fav Icon
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
                  // Bottom Dashes Indicator (overlay on image)
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
                  // Thumbnail Indicator
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
          // Thumbnails
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
                            // Only update the main image, do not call setState
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
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.getTitle(),
                    style: theme.titleLarge?.copyWith(
                        color: Colors.blue[700], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Expected Price:',
                    style: theme.titleMedium?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.expectedPrice,
                    style: theme.titleLarge?.copyWith(
                      color: Colors.green[700],
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
                      // Green if approved
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isApproved
                        ? null
                        : () async {
                            if (product.id != null) {
                              await FirebaseProductsService()
                                  .updateProductApprovalStatus(
                                      product.id ?? '', true);
                              setState(() {
                                _isApproved = true;
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
}
