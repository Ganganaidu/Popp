import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../navigation/nav_router.dart';
import '../utils/product_content_data.dart';
import '../utils/build_extensions.dart';
import '../widgets/listing_card.dart';
import 'category_detail_screen.dart';

class CategoryListWidget extends StatelessWidget {
  final String categoryName;
  final List<Product> products;

  const CategoryListWidget({
    super.key,
    required this.categoryName,
    required this.products,
  });

  void _navigateToCategoryPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryDetailScreen(
          categoryName: categoryName,
          products: products,
          filters: categoryName.contains('Premium Bikes')
              ? bikeFilters
              : categoryFilters,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb && context.isDesktop;
    
    if (isWeb) {
      return _buildWebLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildWebLayout(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(context, theme, isWeb: true),
          const SizedBox(height: 16),
          _buildWebProductGrid(context),
        ],
      ),
    );
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
          const SizedBox(height: 8),
          SizedBox(
            height: itemWidth + 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(context, product, itemWidth, isWeb: false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, TextTheme theme, {required bool isWeb}) {
    return InkWell(
      onTap: () => _navigateToCategoryPage(context),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isWeb ? 12.0 : 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                categoryName,
                style: TextStyle(
                  fontSize: isWeb ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios, 
                size: isWeb ? 20 : 18,
              ),
              onPressed: () => _navigateToCategoryPage(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebProductGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid based on available width
        int crossAxisCount;
        int maxItems;
        if (constraints.maxWidth > 1000) {
          crossAxisCount = 4;
          maxItems = 8;
        } else if (constraints.maxWidth > 700) {
          crossAxisCount = 3;
          maxItems = 6;
        } else {
          crossAxisCount = 2;
          maxItems = 4;
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: products.length > maxItems ? maxItems : products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(context, product, 200, isWeb: true);
          },
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, double width, {required bool isWeb}) {
    return ListingCard(
      title: product.getTitle(),
      imageUrl: product.imageUrl,
      price: product.expectedPrice,
      width: width,
      status: product.isSold ? 'Sold' : null,
      showOptionsMenu: false,
      onTap: () {
        onProductDetailsTap(context, product.toJson());
      },
    );
  }
}
