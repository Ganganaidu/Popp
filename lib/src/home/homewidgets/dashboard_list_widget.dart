import 'package:flutter/material.dart';
import 'package:poppflutter/src/models/product.dart';
import '../../models/category.dart';
import '../../utils/nav_router.dart';

class DashboardListViewWidget extends StatelessWidget {
  const DashboardListViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: catList.take(catList.length - 1).map((category) {
        return _CategorySection(
          category: category,
          products: productList,
        );
      }).toList(),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final Category category;
  final List<Product> products;

  const _CategorySection({
    required this.category,
    required this.products,
  });

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
          Text(
            category.name,
            style: theme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                return SizedBox(
                  width: itemWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Image card with ripple and hero
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => onProductTap(context, product),
                          child: Hero(
                            tag: product.productId, // Unique tag for Hero
                            child: SizedBox(
                              height: itemWidth,
                              width: itemWidth,
                              child: Image.network(
                                product.imageUrls.first,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Brand name (center aligned)
                      Text(
                        product.getTitle(),
                        textAlign: TextAlign.center,
                        style: theme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Price (center aligned)
                      Text(
                        product.price,
                        textAlign: TextAlign.center,
                        style: theme.titleMedium?.copyWith(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
