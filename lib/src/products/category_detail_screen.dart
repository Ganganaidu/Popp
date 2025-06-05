import 'package:flutter/material.dart';
import 'package:poppflutter/src/products/product_card.dart';
import 'package:poppflutter/src/utils/app_loger.dart';
import '../filters/filter_bar.dart';
import '../models/product.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;
  final List<Product> products;
  final List<String> filters;

  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
    required this.products,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: Column(
        children: [
          FilterBar(
            filters: filters,
            activeFilterCounts: const {},
            onFiltersChanged: (selectedValues) {
              AppLogger.d("User selected: $selectedValues");
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(product: product, width: double.infinity);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
