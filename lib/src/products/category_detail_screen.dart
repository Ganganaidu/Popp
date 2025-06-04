import 'package:flutter/material.dart';
import 'package:poppflutter/src/products/product_card.dart';
import '../filters/filter_bar.dart';
import '../models/product.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;
  final List<Product> products;

  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: Column(
        children: [
          const FilterBar(
            filters: [
              'Budget',
              'Brand / Model',
              'By KM Driven',
              'By Year',
              'By Fuel',
              'Sort By'
            ],
            activeFilterCounts: {
              'Budget': 1,
              'By KM Driven': 2,
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
