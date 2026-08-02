import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../api/api_url.dart';

class ProductUtils {
  // Private constructor to prevent instantiation
  ProductUtils._();

  static const String premiumBikes = "Premium Bikes";
  static const String findMechanic = "Find Mechanic";
  static const String bikeRentals = "Bike Rentals";
  static const String accessoryStore = "Accessory Store";
  static const String tyreShop = "Tyre Shops";
  static const String trackDay = "Track day";
  static const String trainingDay = "Training day";
  static const String premiumInspection = 'Premium Inspection';
  static const String towingService = 'Towing Service';

  static List<String> listYourServiceCategories = [
    findMechanic,
    bikeRentals,
    trackDay,
    trainingDay,
    accessoryStore,
    tyreShop,
    towingService
  ];

  static String getTitle(Map<String, dynamic>? product) {
    return "${product?['brandName']} ${product?['modelName']}";
  }

  static String getBrandAndModelName(Map<String, dynamic>? product) {
    return "${product?['brandName']} ${product?['modelName']}";
  }

  static String getServiceTitle(Map<String, dynamic>? service) {
    return service?['businessTitle'] ??
        service?['eventName'] ??
        service?['brandName'] ??
        service?['modelName'] ??
        'No Title';
  }

  static String extractAllImageUrls(Map<String, dynamic> item) {
    List<String> allImageUrls = [];
    List<dynamic>? promoImages;
    if (item['promoImageUrls'] is List) {
      promoImages = item['promoImageUrls'] as List<dynamic>?;
    } else if (item['promoImageUrls'] is String &&
        (item['promoImageUrls'] as String).isNotEmpty) {
      promoImages = [(item['promoImageUrls'] as String)];
    } else if (item['thumbImageUrls'] is List) {
      promoImages = item['thumbImageUrls'] as List<dynamic>?;
    } else if (item['shopImageUrls'] is String &&
        (item['shopImageUrls'] as String).isNotEmpty) {
      promoImages = [(item['shopImageUrls'] as String)];
    }
    if (promoImages != null && promoImages.isNotEmpty) {
      allImageUrls.addAll(promoImages.cast<String>());
    }
    return allImageUrls.isNotEmpty
        ? allImageUrls.first
        : ApiUrl.defaultPlaceholderImage;
  }

  static String getServiceAppBarTitle(String appBarTitle) {
    if (appBarTitle.contains("Track")) {
      appBarTitle = "Track and Training day";
    }
    if (appBarTitle.contains(findMechanic)) {
      appBarTitle = "Find your mechanic";
    }
    return appBarTitle;
  }

  static String getBusinessDescriptionHint(String? selectedCategory) {
    if (selectedCategory == findMechanic) {
      return "Please provide details list of services you offer & Any conditions that apply to the customers";
    } else if (selectedCategory == bikeRentals) {
      return "Please provide list of Bikes you offer for Rent & Prices.";
    } else if (selectedCategory == accessoryStore) {
      return "Please provide detailed list of Accessories & different Brands you sell in the store. Ex., Helmets, Luggage, LS2, KYT,  Rynox, Viaterra, SWmotech, Rhinowalk ...";
    } else if (selectedCategory == tyreShop) {
      return "Please provide detailed list of Tyre Brands & Sizes you offer to the customers. Also provide if you offer any other Tyre related services.";
    } else if (selectedCategory == towingService) {
      return "Please provide detailed desc about your services";
    }
    return "";
  }

  static String getShopNameHint(String? selectedCategory) {
    if (selectedCategory == findMechanic) {
      return "Enter Shop/Garage name";
    } else if (selectedCategory == towingService) {
      return "Enter Towing Service Name";
    }
    return "Enter Shop name";
  }

  static String getProductDescTitle(String? selectedCategory) {
    if (selectedCategory == findMechanic) {
      return "Mechanic Details";
    } else if (selectedCategory == bikeRentals) {
      return "Bike Rental Details";
    } else if (selectedCategory == accessoryStore) {
      return "Store Details";
    } else if (selectedCategory == tyreShop) {
      return "Shop Details";
    } else if (selectedCategory == towingService) {
      return "Towing Service Details";
    }
    return "Event Details";
  }

  static bool isBikeAndOthersCategory(String? selectedCategory) {
    return selectedCategory == ProductUtils.findMechanic ||
        selectedCategory == ProductUtils.bikeRentals ||
        selectedCategory == ProductUtils.accessoryStore ||
        selectedCategory == ProductUtils.tyreShop ||
        selectedCategory == ProductUtils.premiumInspection ||
        selectedCategory == ProductUtils.towingService;
  }

  static bool isTrackAndTrainingCategory(String? selectedCategory) {
    return selectedCategory == ProductUtils.trackDay ||
        selectedCategory == ProductUtils.trainingDay ||
        selectedCategory ==
            [ProductUtils.trackDay, ProductUtils.trainingDay].join(',');
  }

  /// Applies the filter map produced by `FilterBar` (Budget/By KM Driven as
  /// [RangeValues], multi-select filters as a list of strings, By Year as a
  /// two-element `[from, to]` list) against [products].
  static List<Map<String, dynamic>> applyFilters(
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
    List<Map<String, dynamic>> result = List<Map<String, dynamic>>.from(products);
    // Budget filter
    if (filters.containsKey('Budget') &&
        filters['Budget'] != null &&
        filters['Budget'] is RangeValues &&
        ((filters['Budget'] as RangeValues).start != 0 ||
            (filters['Budget'] as RangeValues).end != 20000)) {
      final RangeValues range = filters['Budget'];
      result = result.where((p) {
        final price = p['price'];
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
      result = result.where((p) {
        final mfgDate = _asDateTime(p['mfgDate']);
        return mfgDate != null && mfgDate.year >= from && mfgDate.year <= to;
      }).toList();
    }
    return result;
  }

  /// Firestore document maps carry date fields as [Timestamp], not
  /// [DateTime] — this normalizes either shape for comparison.
  static DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
