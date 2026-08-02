import 'package:flutter/material.dart';
import 'package:popp/src/toolbar/common_app_bar.dart';
import 'package:popp/src/api/currency_service.dart';
import 'package:popp/src/utils/app_loger.dart';

import '../api/firebase/firebase_api_service.dart';
import '../filters/filter_bar.dart';
import '../navigation/nav_router.dart';
import '../utils/product_utils.dart';
import '../widgets/listing_card.dart';
import '../widgets/title_text.dart';
import '../widgets/web_constrained_box.dart';

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
  // The real full/unfiltered product list — populated from whichever path
  // actually ran in _initProducts (the passed-in widget.products, or the
  // async-fetched result). Filtering always reads from this, never from
  // widget.products directly (that field can be null when products are
  // fetched asynchronously).
  late List<Map<String, dynamic>> _sourceProducts;
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
          _sourceProducts = products;
          filteredProducts = List<Map<String, dynamic>>.from(products);
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _sourceProducts = [];
          filteredProducts = [];
          _isLoading = false;
          _error = 'Failed to load products.';
        });
      }
    } else {
      _sourceProducts = List<Map<String, dynamic>>.from(widget.products!);
      filteredProducts = List<Map<String, dynamic>>.from(widget.products!);
    }
  }

  void _onFiltersChanged(Map<String, dynamic> selectedValues) {
    setState(() {
      activeFilters = selectedValues;
      filteredProducts = ProductUtils.applyFilters(_sourceProducts, selectedValues);
    });
    AppLogger.d("User selected: $selectedValues");
  }

  @override
  Widget build(BuildContext context) {
    String countryCode = Localizations.localeOf(context).countryCode ?? 'US';
    return Scaffold(
      appBar: CommonAppBar(
        titleWidget: TitleText(widget.categoryName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)))
              : WebConstrainedBox(
                  child: Column(
                      children: [
                        FilterBar(
                          filters: widget.filters,
                          activeFilterCounts: const {},
                          onFiltersChanged: _onFiltersChanged,
                          products: _sourceProducts,
                        ),
                        Expanded(
                          child: filteredProducts.isEmpty
                              ? _buildEmptyProductsView(context)
                              : Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: GridView.builder(
                                    itemCount: filteredProducts.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          MediaQuery.of(context).size.width > 800
                                              ? 4
                                              : 2,
                                      childAspectRatio: 0.65,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                    ),
                                    itemBuilder: (context, index) {
                                      final product = filteredProducts[index];
                                      return ListingCard(
                                          title:
                                              ProductUtils.getBrandAndModelName(product),
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
