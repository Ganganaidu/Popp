import 'package:flutter/foundation.dart';

import '../../utils/app_loger.dart';
import '../../utils/product_utils.dart';
import '../repository/service_repository.dart';

/// State + logic for the service listing screen: loads a category's services
/// and applies location (state/city/area) filters.
class ServiceListingViewModel extends ChangeNotifier {
  final ServiceRepository repository;

  ServiceListingViewModel(this.repository);

  List<Map<String, dynamic>> _allServices = [];
  bool isLoading = false;
  String? error;

  List<String> selectedStates = [];
  List<String> selectedCities = [];
  List<String> selectedAreas = [];

  List<Map<String, dynamic>> get allServices => _allServices;

  List<String> _distinct(String key) => _allServices
      .map((s) => s[key]?.toString().trim() ?? '')
      .where((v) => v.isNotEmpty)
      .toSet()
      .toList();

  List<String> get availableStates => _distinct('state');
  List<String> get availableCities => _distinct('city');
  List<String> get availableAreas => _distinct('area');

  List<Map<String, dynamic>> get filteredServices {
    return _allServices.where((service) {
      final state = service['state']?.toString().trim() ?? '';
      final city = service['city']?.toString().trim() ?? '';
      final area = service['area']?.toString().trim() ?? '';
      if (selectedStates.isNotEmpty && !selectedStates.contains(state)) {
        return false;
      }
      if (selectedCities.isNotEmpty && !selectedCities.contains(city)) {
        return false;
      }
      if (selectedAreas.isNotEmpty && !selectedAreas.contains(area)) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> load({required String category, String? subCategory}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      if (category.contains(ProductUtils.premiumInspection)) {
        // Premium Inspection: search 'Book your Bike service' (findMechanic)
        // and keep only shops that inspect premium bikes.
        final services =
            await repository.fetchByCategories([ProductUtils.findMechanic]);
        _allServices = services
            .where((s) => s['doYouInspectPremiumBikes'] == 'Yes')
            .toList();
      } else {
        final categories =
            category.split(',').map((e) => e.trim()).toList();
        _allServices = await repository.fetchByCategories(categories,
            subCategory: subCategory);
      }
    } catch (e) {
      error = e.toString();
      _allServices = [];
      AppLogger.e('Error loading services: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  void onFiltersChanged(Map<String, dynamic> filters) {
    selectedStates = List<String>.from(filters['By State'] ?? []);
    selectedCities = List<String>.from(filters['By City'] ?? []);
    selectedAreas = List<String>.from(filters['By Area'] ?? []);
    notifyListeners();
  }
}
