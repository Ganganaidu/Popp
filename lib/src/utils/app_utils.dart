class AppUtils {
  // Private constructor to prevent instantiation
  AppUtils._();

  static final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static bool isEmailValid(String email) {
    return emailRegExp.hasMatch(email);
  }

// Add other common utility functions here
// For example:
// static String formatDate(DateTime date) {
//   // ... formatting logic ...
// }
}
