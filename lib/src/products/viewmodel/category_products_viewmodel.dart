import 'package:flutter/foundation.dart';

import '../../utils/app_loger.dart';
import '../../utils/product_utils.dart';
import '../repository/product_repository.dart';

/// State + logic for the category listing screen. Loads a category's products
/// (either from the list handed in by the caller, or by fetching them) and
/// applies client-side filters.
class CategoryProductsViewModel extends ChangeNotifier {
  final ProductRepository repository;

  CategoryProductsViewModel(this.repository);

  /// The full, unfiltered product list. Filtering always reads from this.
  List<Map<String, dynamic>> _sourceProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];
  Map<String, dynamic> activeFilters = {};
  bool isLoading = false;
  String? error;

  List<Map<String, dynamic>> get sourceProducts => _sourceProducts;

  Future<void> load({
    required String categoryName,
    String? subCategory,
    List<Map<String, dynamic>>? initialProducts,
  }) async {
    if (initialProducts != null && initialProducts.isNotEmpty) {
      _sourceProducts = List<Map<String, dynamic>>.from(initialProducts);
      filteredProducts = List<Map<String, dynamic>>.from(initialProducts);
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final fetched = await repository.getProductsByCategory(
        [categoryName],
        subCategory: [subCategory].whereType<String>().toList(),
      );
      _sourceProducts = List<Map<String, dynamic>>.from(fetched);
      filteredProducts = List<Map<String, dynamic>>.from(fetched);
    } catch (e) {
      _sourceProducts = [];
      filteredProducts = [];
      error = 'Failed to load products.';
      AppLogger.e('Error loading category products: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  void onFiltersChanged(Map<String, dynamic> selectedValues) {
    activeFilters = selectedValues;
    filteredProducts = ProductUtils.applyFilters(_sourceProducts, selectedValues);
    AppLogger.d('User selected: $selectedValues');
    notifyListeners();
  }
}
