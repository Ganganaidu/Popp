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
}
