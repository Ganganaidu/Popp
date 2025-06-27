import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:popp/src/models/product.dart';
import 'package:popp/src/utils/app_loger.dart';
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
  int selectedImageIndex = 0;
  bool isFavorite = false;
  late final PageController _pageController;
  final CurrencyService _currencyService = CurrencyService();
  bool _isApproved = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedImageIndex);
    _isApproved = widget.productJson['isApproved'] == true;
    AppLogger.d("ProductDetailScreen initState: isApproved = $_isApproved");
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
      widget.productJson['isFavorite'] = isFavorite;
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

  /// Gets the localized price based on the user's country using the CurrencyService.
  Future<String> _getLocalizedPrice(String priceStr) async {
    // 1. Parse the input price string to a double. Assumes base price is in INR.
    final double? priceInRupees =
        double.tryParse(priceStr.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (priceInRupees == null) {
      return priceStr; // Return original string if parsing fails.
    }

    // 2. Get the device's locale to determine the country.
    if (!mounted) return priceStr;
    final locale = Localizations.localeOf(context);
    final String countryCode =
        locale.countryCode ?? 'US'; // Default to 'US' if null.

    // 3. Check if the country is India.
    if (countryCode == 'IN') {
      final format = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      );
      return format.format(priceInRupees);
    } else {
      // For all other countries, fetch the conversion rate via the service.
      final usdRate = await _currencyService.getInrToUsdRate();
      double priceInUSD;
      String suffix = '';

      if (usdRate != null) {
        // If API call is successful, use the live rate.
        priceInUSD = priceInRupees * usdRate;
      } else {
        // If API call fails, use a hardcoded fallback rate.
        const double fallbackConversionRate = 1 / 83.0;
        priceInUSD = priceInRupees * fallbackConversionRate;
        suffix = ' (est.)'; // Indicate that the price is an estimate
      }

      final format = NumberFormat.currency(
        locale: 'en_US',
        symbol: '\$',
        decimalDigits: 2,
      );
      return format.format(priceInUSD) + suffix;
    }
  }

  bool get _isAdmin =>
      FirebaseAuth.instance.currentUser?.uid == Constants.adminUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final product =
        Product.fromJson(widget.productJson, widget.productJson['id']);

    return Scaffold(
      appBar: AppBar(title: Text(product.getBrandAndModelName())),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Main Image Carousel
            Stack(
              children: [
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: product.thumbImageUrls?.length,
                    onPageChanged: (index) {
                      setState(() {
                        selectedImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final url = product.thumbImageUrls?[index] ?? '';
                      return _buildImage(
                        url,
                        useHero: index == 0,
                      );
                    },
                  ),
                ),

                // 🔹 Fav Icon
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),

                // 🔹 Bottom Dashes Indicator (overlay on image)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          product.thumbImageUrls?.length ?? 0, (index) {
                        bool isActive = index == selectedImageIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 20 : 12,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white54 : Colors.black26,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                // 🔹 Thumbnail Indicator
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${selectedImageIndex + 1} / ${product.thumbImageUrls?.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 🔹 Thumbnails
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: product.thumbImageUrls?.length,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  final url = product.thumbImageUrls?[index] ?? '';
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedImageIndex = index;
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      });
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
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 Title and Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.getTitle(),
                    style: theme.titleLarge?.copyWith(
                        color: Colors.blue[700], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<String>(
                    future: _getLocalizedPrice(product.expectedPrice),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 150,
                            height: 28,
                            color: Colors.white,
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text('Error loading price',
                            style: TextStyle(color: Colors.red[700]));
                      }
                      return Text(
                        snapshot.data ?? product.expectedPrice,
                        style: theme.headlineSmall?.copyWith(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.bold),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  Text(
                    "Product Details",
                    style: theme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ExpandableProductDetails(
                    product: product,
                  ),
                  const SizedBox(height: 16),
                  // 🔹 Seller Contact Card
                  ChatWithSellerCard(
                    receiverUserName: product.sellerName,
                    receiverUserID: product.userId ?? '',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
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
