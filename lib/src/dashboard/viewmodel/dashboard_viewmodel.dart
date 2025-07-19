import 'dart:async';
import 'package:flutter/cupertino.dart';

import '../../models/pop_category.dart';
import '../../utils/app_loger.dart';
import '../repository/product_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final ProductRepository repository;
  StreamSubscription? _productsSubscription;

  DashboardViewModel(this.repository);

  List<PopCategory> categories = [];
  bool isLoading = false;
  String? error;

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadCategories(BuildContext context, bool isApproved) async {
    isLoading = true;
    notifyListeners();

    try {
      var countryCode = Localizations.localeOf(context).countryCode ?? 'US';
      // Initial load
      categories = await repository.fetchProductsGroupedByCategory(
          isApproved, countryCode);

      // Set up real-time listener
      _productsSubscription?.cancel();
      _productsSubscription = repository
          .getProductsStream(isApproved, countryCode)
          .listen((updatedCategories) {
        categories = updatedCategories;
        error = null;
        // for (var category in categories) {
        //   for (var product in category.products ?? []) {
        //     product.isApproved = isApproved;
        //     AppLogger.d(
        //       'Product updated in ${category.name}: '
        //       'ID: ${product.id}, '
        //       'Name: ${product.modelName}, '
        //       'sold: ${product.isSold}, '
        //       'Status: ${product.isSold ? "Sold" : product.isApproved ? "Approved" : "Pending"}'
        //     );
        //   }
        // }
        notifyListeners();
      }, onError: (e) {
        error = e.toString();
        AppLogger.e("Error in products stream: $error");
        notifyListeners();
      });

      error = null;
    } catch (e) {
      error = e.toString();
      AppLogger.e("Error loading categories: $error");
    }

    isLoading = false;
    notifyListeners();
  }
}
