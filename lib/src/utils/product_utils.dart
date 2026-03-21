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
}
