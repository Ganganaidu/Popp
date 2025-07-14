import 'package:flutter/cupertino.dart';

import '../../models/pop_category.dart';
import '../../utils/app_loger.dart';
import '../repository/product_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final ProductRepository repository;

  DashboardViewModel(this.repository);

  List<PopCategory> categories = [];
  bool isLoading = false;
  String? error;

  Future<void> loadCategories(bool isApproved) async {
    isLoading = true;
    notifyListeners();

    try {
      categories = await repository.fetchProductsGroupedByCategory(isApproved);
      error = null;
    } catch (e) {
      error = e.toString();
      AppLogger.e("Error loading categories: $error");
    }

    isLoading = false;
    notifyListeners();
  }
}
