import 'package:flutter/material.dart';
import 'package:poppflutter/src/products/product_card.dart';
import '../models/product.dart';
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth * 0.4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _navigateToCategoryPage(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      categoryName,
                      style: theme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: itemWidth + 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(product: product, width: itemWidth);
              },
            ),
          ),
        ],
      ),
    );
  }
}
