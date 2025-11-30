import 'dart:async';
import 'package:flutter/cupertino.dart';

import '../../models/pop_category.dart';
import '../../utils/app_loger.dart';
import '../repository/service_repository.dart';

class ServiceViewModel extends ChangeNotifier {
  final ServiceRepository repository;
  StreamSubscription? _servicesSubscription;

  ServiceViewModel(this.repository);

  List<PopCategory> categories = [];
  bool isLoading = false;
  String? error;

  @override
  void dispose() {
    _servicesSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadCategories(BuildContext context, bool isApproved) async {
    isLoading = true;
    notifyListeners();

    try {
      // Initial load
      categories = await repository.fetchServicesGroupedByCategory(isApproved);

      // Set up real-time listener
      _servicesSubscription?.cancel();
      _servicesSubscription = repository
          .getServicesStream(isApproved)
          .listen((updatedCategories) {
        categories = updatedCategories;
        error = null;
        notifyListeners();
      }, onError: (e) {
        error = e.toString();
        AppLogger.e("Error in services stream: $error");
        notifyListeners();
      });

      error = null;
    } catch (e) {
      error = e.toString();
      AppLogger.e("Error loading service categories: $error");
    }

    isLoading = false;
    notifyListeners();
  }
}
