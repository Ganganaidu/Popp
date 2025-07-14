import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../api/currency_service.dart';

class AppUtils {
  // Private constructor to prevent instantiation
  AppUtils._();

  static final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static bool isEmailValid(String email) {
    return emailRegExp.hasMatch(email);
  }
}
