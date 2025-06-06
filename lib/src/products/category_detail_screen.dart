import 'package:flutter/material.dart';
import 'package:poppflutter/src/products/product_card.dart';
import 'package:poppflutter/src/utils/app_loger.dart';
import '../filters/filter_bar.dart';
import '../models/product.dart';

class CategoryDetailScreen extends StatefulWidget {
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
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late List<Product> filteredProducts;
  Map<String, dynamic> activeFilters = {};

  @override
  void initState() {
    super.initState();
    filteredProducts = List<Product>.from(widget.products);
  }

  void _onFiltersChanged(Map<String, dynamic> selectedValues) {
    setState(() {
      activeFilters = selectedValues;
      filteredProducts = _applyFilters(widget.products, selectedValues);
    });
    AppLogger.d("User selected: $selectedValues");
  }

  List<Product> _applyFilters(
      List<Product> products, Map<String, dynamic> filters) {
    bool isDefaultFilters = (filters['Budget'] == null ||
            (filters['Budget'] is RangeValues &&
                (filters['Budget'] as RangeValues).start == 0 &&
                (filters['Budget'] as RangeValues).end == 20000)) &&
        (filters['By KM Driven'] == null ||
            (filters['By KM Driven'] is RangeValues &&
                (filters['By KM Driven'] as RangeValues).start == 0 &&
                (filters['By KM Driven'] as RangeValues).end == 200000)) &&
        (filters['Brand / Model'] == null ||
            (filters['Brand / Model'] is List &&
                (filters['Brand / Model'] as List).isEmpty)) &&
        (filters['By State'] == null ||
            (filters['By State'] is List &&
                (filters['By State'] as List).isEmpty)) &&
        (filters['By Category'] == null ||
            (filters['By Category'] is List &&
                (filters['By Category'] as List).isEmpty)) &&
        (filters['By SubCategory'] == null ||
            (filters['By SubCategory'] is List &&
                (filters['By SubCategory'] as List).isEmpty)) &&
        (filters['By Year'] == null ||
            (filters['By Year'] is List && (filters['By Year'] as List).isEmpty));
    if (filters.isEmpty || isDefaultFilters) {
      return List<Product>.from(products);
    }
    List<Product> result = List<Product>.from(products);
    // Budget filter
    if (filters.containsKey('Budget') &&
        filters['Budget'] != null &&
        filters['Budget'] is RangeValues &&
        ((filters['Budget'] as RangeValues).start != 0 ||
            (filters['Budget'] as RangeValues).end != 20000)) {
      AppLogger.d("Budget filter: ${filters['Budget']}");
      final RangeValues range = filters['Budget'];
      result = result.where((p) {
        final price = p.expectedPrice;
        final priceDouble = (price.toString().isNotEmpty)
            ? double.tryParse(price.toString())
            : null;
        return priceDouble != null &&
            priceDouble >= range.start &&
            priceDouble <= range.end;
      }).toList();
    }
    // By KM Driven filter
    if (filters.containsKey('By KM Driven') &&
        filters['By KM Driven'] != null &&
        filters['By KM Driven'] is RangeValues &&
        ((filters['By KM Driven'] as RangeValues).start != 0 ||
            (filters['By KM Driven'] as RangeValues).end != 200000)) {
      AppLogger.d("Brands KM Driven filter: ${filters['By KM Driven']}");
      final RangeValues range = filters['By KM Driven'];
      result = result.where((p) {
        final km = p.kmDriven;
        final kmDouble = (km != null && km.toString().isNotEmpty)
            ? double.tryParse(km.toString())
            : null;
        return kmDouble != null &&
            kmDouble >= range.start &&
            kmDouble <= range.end;
      }).toList();
    }
    // Brand / Model filter
    if (filters.containsKey('Brand / Model') &&
        filters['Brand / Model'] != null &&
        (filters['Brand / Model'] as List).isNotEmpty) {
      final List<String> brands = List<String>.from(filters['Brand / Model']);
      result = result.where((p) => brands.contains(p.brandName)).toList();
    }
    // By State filter
    if (filters.containsKey('By State') &&
        filters['By State'] != null &&
        (filters['By State'] as List).isNotEmpty) {
      final List<String> states = List<String>.from(filters['By State']);
      result = result.where((p) => states.contains(p.state)).toList();
    }
    // By Category filter
    if (filters.containsKey('By Category') &&
        filters['By Category'] != null &&
        (filters['By Category'] as List).isNotEmpty) {
      final List<String> categories = List<String>.from(filters['By Category']);
      result =
          result.where((p) => categories.contains(p.categoryName)).toList();
    }
    // By SubCategory filter
    if (filters.containsKey('By SubCategory') &&
        filters['By SubCategory'] != null &&
        (filters['By SubCategory'] as List).isNotEmpty) {
      final List<String> subCategories =
          List<String>.from(filters['By SubCategory']);
      result = result
          .where((p) => subCategories.contains(p.subCategoryName))
          .toList();
    }
    // By Year filter
    if (filters.containsKey('By Year') &&
        filters['By Year'] != null &&
        (filters['By Year'] is List) &&
        (filters['By Year'] as List).length == 2) {
      final List years = filters['By Year'];
      final int from = years[0];
      final int to = years[1];
      result = result
          .where((p) =>
              p.mfgDate != null &&
              p.mfgDate!.year >= from &&
              p.mfgDate!.year <= to)
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: Column(
        children: [
          FilterBar(
            filters: widget.filters,
            activeFilterCounts: const {},
            onFiltersChanged: _onFiltersChanged,
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyProductsView(context)
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      itemCount: filteredProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return ProductCard(
                            product: product, width: double.infinity);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProductsView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'No products available',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or check back later.',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
