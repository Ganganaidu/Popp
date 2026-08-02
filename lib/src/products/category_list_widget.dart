import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../api/currency_service.dart';
import '../navigation/nav_router.dart';
import '../utils/product_content_data.dart';
import '../utils/build_extensions.dart';
import '../utils/product_utils.dart';
import '../widgets/listing_card.dart';
import 'category_detail_screen.dart';
import '../theme/bikerverse_colors.dart';

class CategoryListWidget extends StatelessWidget {
  final String categoryName;
  final List<Map<String, dynamic>> products;
  final String countryCode;

  const CategoryListWidget({
    super.key,
    required this.categoryName,
    required this.products,
    required this.countryCode
  });

  void _navigateToCategoryPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CategoryDetailScreen(
              categoryName: categoryName,
              subCategory: "",
              products: products,
              filters: categoryName.contains(ProductUtils.premiumBikes)
                  ? bikeFilters
                  : categoryFilters,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
      return _buildMobileLayout(context);
  }

  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth * 0.5;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(context, theme, isWeb: false),
          const SizedBox(height: 15),
          SizedBox(
            height: itemWidth * 1.2, // Adjust height based on aspect ratio of product cards
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(context, product, itemWidth,
                    isWeb: false);
              },
            ),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, TextTheme theme,
      {required bool isWeb}) {
    if (!isWeb) {
      return InkWell(
        onTap: () => _navigateToCategoryPage(context),
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: BikerverseColors.textPrimary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: BikerverseColors.accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _navigateToCategoryPage(context),
                borderRadius: BorderRadius.circular(20),
                child: const Row(
                  children: [
                    Text(
                      'VIEW ALL',
                      style: TextStyle(
                        color: BikerverseColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: BikerverseColors.accent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _navigateToCategoryPage(context),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isWeb ? 10.0 : 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
              onPressed: () => _navigateToCategoryPage(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context,
      Map<String, dynamic> product,
      double width,
      {required bool isWeb}) {
    return ListingCard(
      title: ProductUtils.getBrandAndModelName(product),
      imageUrl: product['imageUrl'],
      price: CurrencyService.getProductPrice(product['price'], countryCode),
      width: width,
      status: product['isSold'] == true ? 'Sold' : null,
      showOptionsMenu: false,
      onTap: () {
        onProductDetailsTap(context, product);
      },
    );
  }
}
