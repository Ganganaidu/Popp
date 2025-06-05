import 'package:flutter/cupertino.dart';

import '../../models/pop_category.dart';
import '../repository/product_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final ProductRepository repository;

  DashboardViewModel(this.repository);

  List<PopCategory> categories = [];
  bool isLoading = false;
  String? error;

  Future<void> loadCategories() async {
    isLoading = true;
    notifyListeners();

    try {
      categories = await repository.fetchProductsGroupedByCategory();
      error = null;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
