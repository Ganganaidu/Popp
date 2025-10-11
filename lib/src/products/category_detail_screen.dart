import 'package:flutter/material.dart';
import 'package:popp/src/api/currency_service.dart';
import 'package:popp/src/utils/app_loger.dart';

import '../api/firebase/firebase_api_service.dart';
import '../filters/filter_bar.dart';
import '../navigation/nav_router.dart';
import '../utils/product_utils.dart';
import '../widgets/listing_card.dart';
import '../widgets/title_text.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryName;
  final String? subCategory;
  final List<Map<String, dynamic>>? products;
  final List<String> filters;

  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
    required this.subCategory,
    required this.products,
    required this.filters,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late List<Map<String, dynamic>> filteredProducts;
  Map<String, dynamic> activeFilters = {};
  final FirebaseApiService _productsService = FirebaseApiService();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initProducts();
  }

  Future<void> _initProducts() async {
    if (widget.products == null || widget.products!.isEmpty) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      try {
        final List<Map<String, dynamic>> fetched = await _productsService
            .getProductsByCategory([widget.categoryName],
                subCategory: [widget.subCategory].whereType<String>().toList());
        List<Map<String, dynamic>> products =
            List<Map<String, dynamic>>.from(fetched);
        // If no products found, try fetchServicesByCategories
        // if (products.isEmpty) {
        //   AppLogger.d("No products found, trying to fetch services...");
        //   final List<Map<String, dynamic>> serviceFetched =
        //       await _productsService
        //           .fetchServicesByCategories([widget.categoryName], true);
        //   AppLogger.d("Fetched services: $serviceFetched");
        //   products = List<Map<String, dynamic>>.from(serviceFetched);
        // }
        setState(() {
          filteredProducts = List<Map<String, dynamic>>.from(products);
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          filteredProducts = [];
          _isLoading = false;
          _error = 'Failed to load products.';
        });
      }
    } else {
      filteredProducts = List<Map<String, dynamic>>.from(widget.products!);
    }
  }

  void _onFiltersChanged(Map<String, dynamic> selectedValues) {
    setState(() {
      activeFilters = selectedValues;
      filteredProducts = _applyFilters(widget.products!, selectedValues);
    });
    AppLogger.d("User selected: $selectedValues");
  }

  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>> products, Map<String, dynamic> filters) {
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
            (filters['By Year'] is List &&
                (filters['By Year'] as List).isEmpty));
    if (filters.isEmpty || isDefaultFilters) {
      return List<Map<String, dynamic>>.from(products);
    }
    List<Map<String, dynamic>> result =
        List<Map<String, dynamic>>.from(products);
    // Budget filter
    if (filters.containsKey('Budget') &&
        filters['Budget'] != null &&
        filters['Budget'] is RangeValues &&
        ((filters['Budget'] as RangeValues).start != 0 ||
            (filters['Budget'] as RangeValues).end != 20000)) {
      AppLogger.d("Budget filter: ${filters['Budget']}");
      final RangeValues range = filters['Budget'];
      result = result.where((p) {
        final price = p['expectedPrice'];
        final priceDouble = (price != null && price.toString().isNotEmpty)
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
        final km = p['kmDriven'];
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
      result = result.where((p) => brands.contains(p['brandName'])).toList();
    }
    // By State filter
    if (filters.containsKey('By State') &&
        filters['By State'] != null &&
        (filters['By State'] as List).isNotEmpty) {
      final List<String> states = List<String>.from(filters['By State']);
      result = result.where((p) => states.contains(p['state'])).toList();
    }
    // By Category filter
    if (filters.containsKey('By Category') &&
        filters['By Category'] != null &&
        (filters['By Category'] as List).isNotEmpty) {
      final List<String> categories = List<String>.from(filters['By Category']);
      result = result.where((p) => categories.contains(p['category'])).toList();
    }
    // By SubCategory filter
    if (filters.containsKey('By SubCategory') &&
        filters['By SubCategory'] != null &&
        (filters['By SubCategory'] as List).isNotEmpty) {
      final List<String> subCategories =
          List<String>.from(filters['By SubCategory']);
      result = result
          .where((p) => subCategories.contains(p['subCategory']))
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
              p['mfgDate'] != null &&
              p['mfgDate'].year >= from &&
              p['mfgDate'].year <= to)
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    String countryCode = Localizations.localeOf(context).countryCode ?? 'US';
    return Scaffold(
      appBar: AppBar(
          title: TitleText(widget.categoryName,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)))
              : Column(
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
                                  return ListingCard(
                                      title:
                                          ProductUtils.getServiceTitle(product),
                                      imageUrl:
                                          ProductUtils.extractAllImageUrls(
                                              product),
                                      price: CurrencyService.getProductPrice(
                                          product['expectedPrice'],
                                          countryCode),
                                      width: double.infinity,
                                      showOptionsMenu: false,
                                      onTap: () {
                                        onProductDetailsTap(context, product);
                                        // Navigate to detail screen
                                      });
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
