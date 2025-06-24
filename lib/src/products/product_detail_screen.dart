import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:popp/src/models/product.dart';
import 'package:shimmer/shimmer.dart';

import '../api/currency_service.dart';
import '../navigation/nav_router.dart';
import '../widgets/chat_with_user_widget.dart';
import '../widgets/expandable_product_details_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedImageIndex = 0;
  bool isFavorite = false;
  late final PageController _pageController;
  final CurrencyService _currencyService = CurrencyService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedImageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openChatWithSeller() async {
    onUserToUserChatTap(
        context, widget.product.sellerName, widget.product.userId ?? "");
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
      widget.product.isFavorite = isFavorite;
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
            tag: widget.product.imageUrl ?? '',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
        appBar: AppBar(title: Text(widget.product.getBrandAndModelName())),
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
                      itemCount: widget.product.thumbImageUrls?.length,
                      onPageChanged: (index) {
                        setState(() {
                          selectedImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final url = widget.product.thumbImageUrls?[index] ?? '';
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
                            widget.product.thumbImageUrls?.length ?? 0,
                            (index) {
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${selectedImageIndex + 1} / ${widget.product.thumbImageUrls?.length}',
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
                  itemCount: widget.product.thumbImageUrls?.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    final url = widget.product.thumbImageUrls?[index] ?? '';
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
                      widget.product.getTitle(),
                      style: theme.titleLarge?.copyWith(
                          color: Colors.blue[700], fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<String>(
                      future: _getLocalizedPrice(widget.product.expectedPrice),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                          snapshot.data ?? widget.product.expectedPrice,
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
                      product: widget.product,
                    ),
                    const SizedBox(height: 16),
                    // 🔹 Seller Contact Card
                    ChatWithSellerCard(
                      receiverUserName: widget.product.sellerName,
                      receiverUserID: widget.product.userId ?? '',
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
