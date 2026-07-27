

class AppUtils {
  // Private constructor to prevent instantiation
  AppUtils._();

  static final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static bool isEmailValid(String email) {
    return emailRegExp.hasMatch(email);
  }

  // Indian mobile numbers: 10 digits, first digit 6-9.
  static final RegExp indianPhoneRegExp = RegExp(r'^[6-9]\d{9}$');

  static bool isPhoneValid(String phone, {String countryCode = '+91'}) {
    final digits = phone.trim();
    if (countryCode == '+91') {
      return indianPhoneRegExp.hasMatch(digits);
    }
    return RegExp(r'^\d{10}$').hasMatch(digits);
  }

  static String? phoneValidator(String? value,
      {String countryCode = '+91', bool isRequired = true}) {
    final digits = value?.trim() ?? '';
    if (digits.isEmpty) {
      return isRequired ? 'Phone number is required' : null;
    }
    if (digits.length != 10) {
      return 'Enter a valid 10-digit phone number';
    }
    if (!isPhoneValid(digits, countryCode: countryCode)) {
      return countryCode == '+91'
          ? 'Enter a valid Indian mobile number'
          : 'Enter a valid phone number';
    }
    return null;
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
}
