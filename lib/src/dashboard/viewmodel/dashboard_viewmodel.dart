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
      // Initial load
      categories = await repository.fetchProductsGroupedByCategory(isApproved);

      // Set up real-time listener
      _productsSubscription?.cancel();
      _productsSubscription = repository
          .getProductsStream(isApproved)
          .listen((updatedCategories) {
        categories = updatedCategories;
        error = null;
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
