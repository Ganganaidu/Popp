import 'package:popp/src/utils/product_content_data.dart';

class AppUtils {
  // Private constructor to prevent instantiation
  AppUtils._();

  static final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static bool isEmailValid(String email) {
    return emailRegExp.hasMatch(email);
  }

  // Place the calculateAge function here or in a utility file
  static Map<String, int> calculateAge(DateTime? startDate) {
    if (startDate == null) {
      return {'years': 0, 'months': 0};
    }
    final DateTime currentDate = DateTime.now();
    int years = currentDate.year - startDate.year;
    int months = currentDate.month - startDate.month;
    if (months < 0 || (months == 0 && currentDate.day < startDate.day)) {
      years--;
      months += 12;
    }
    return {'years': years, 'months': months};
  }

  static String getServiceAppBarTitle(String appBarTitle) {
    if (appBarTitle.contains("Track")) {
      appBarTitle = "Track and Training day";
    }
    if (appBarTitle.contains(serviceCategories[0])) {
      appBarTitle = "Find your mechanic";
    }
    return appBarTitle;
  }

  static String findMechanic = "Find Mechanic";
  static String bikeRentals = "Bike Rentals";
  static String accessoryStore = "Accessory Store";
  static String tyreShop = "Tyre Shops";
  static String trackDay = "Track day";
  static String trainingDay = "Training day";

  static String getBusinessDescriptionHint(String? selectedCategory) {
    if (selectedCategory == findMechanic) {
      return "Please provide details list of services you offer & Any conditions that apply to the customers";
    } else if (selectedCategory == bikeRentals) {
      return "Please provide list of Bikes you offer for Rent & Prices.";
    } else if (selectedCategory == accessoryStore) {
      return "Please provide detailed list of Accessories & different Brands you sell in the store. Ex., Helmets, Luggage, LS2, KYT,  Rynox, Viaterra, SWmotech, Rhinowalk ...";
    } else if (selectedCategory == tyreShop) {
      return "Please provide detailed list of Tyre Brands & Sizes you offer to the customers. Also provide if you offer any other Tyre related services.";
    }
    return "";
  }

  static String getShopNameHint(String? selectedCategory) {
    if (selectedCategory == findMechanic) {
      return "Enter Shop/Garage name";
    }
    return "Enter Shop name";
  }
}
