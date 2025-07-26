import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:popp/src/utils/app_loger.dart';

/// A service class to handle fetching currency conversion rates from an API.
class CurrencyService {
  static const String _apiKey = '7c021024b664cfb6d1e1dc27';
  static const String _baseUrl = 'https://v6.exchangerate-api.com/v6/';

  static Future<String> getLocalizedPrice(
    String priceValueStr,
    String? sourceCuntryCode,
    String? targetCountryCode,
  ) async {
    // Early return for invalid or pre-formatted prices
    if (priceValueStr.isEmpty ||
        priceValueStr == '0' ||
        priceValueStr == '0.0' ||
        priceValueStr.contains(r'$')) {
      return priceValueStr;
    }

    double priceValue;
    try {
      priceValue = double.parse(priceValueStr);
    } catch (e) {
      AppLogger.e('Error parsing priceValue: $priceValueStr, Error: $e');
      return priceValueStr; // Return original string if parsing fails
    }

    if (sourceCuntryCode == null || sourceCuntryCode.isEmpty) {
      sourceCuntryCode = 'IN'; // Default to India if null
    }

    if (targetCountryCode == null || targetCountryCode.isEmpty) {
      targetCountryCode = 'IN'; // Default to US if null or empty
    }

    String sourceCurrency = (sourceCuntryCode == 'IN') ? 'INR' : 'USD';
    // 1. Get the device's locale to determine the target currency.
    // final String targetCountryCode =
    //     Localizations.localeOf(context).countryCode ?? 'US';

    // Determine the target currency format based on the user's country.
    final String targetCurrency = (targetCountryCode == 'IN') ? 'INR' : 'USD';

    double finalPrice = priceValue;
    String suffix = '';

    // 2. Check if conversion is needed.
    if (sourceCurrency != targetCurrency) {
      // --- CONVERSION LOGIC ---
      if (sourceCurrency == 'INR' && targetCurrency == 'USD') {
        final rate = await getInrToUsdRate();
        if (rate != null) {
          finalPrice = priceValue * rate;
        } else {
          const double fallbackRate = 1 / 83.0; // Hardcoded fallback
          finalPrice = priceValue * fallbackRate;
          suffix = ' (est.)';
        }
      } else if (sourceCurrency == 'USD' && targetCurrency == 'INR') {
        final rate = await getUsdToInrRate();
        if (rate != null) {
          finalPrice = priceValue * rate;
        } else {
          const double fallbackRate = 83.0; // Hardcoded fallback
          finalPrice = priceValue * fallbackRate;
          suffix = ' (est.)';
        }
      }
      // Add other conversion cases here if needed (e.g., EUR to USD).
    }

    // 3. Format the final price in the target currency.
    if (targetCurrency == 'INR') {
      final format = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      );
      return format.format(finalPrice) + suffix;
    } else {
      // Default to USD
      final format = NumberFormat.currency(
        locale: 'en_US',
        symbol: '\$',
        decimalDigits: 2,
      );
      return format.format(finalPrice) + suffix;
    }
  }

  /// Fetches the conversion rate from INR to USD.
  /// Returns the rate as a double, or null if the request fails.
  static Future<double?> getInrToUsdRate() async {
    final Uri url = Uri.parse('$_baseUrl$_apiKey/latest/INR');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] == 'success' && data['conversion_rates'] != null) {
          final rate = data['conversion_rates']['USD'];
          return rate?.toDouble();
        }
      }
      AppLogger.e(
          'Failed to load currency data. Status code: ${response.statusCode}');
      return null; // Return null if API call was not successful
    } catch (e) {
      // Handle exceptions like no internet connection
      AppLogger.e('CurrencyService Error: $e');
      return null;
    }
  }

  /// Fetches the conversion rate from USD to INR.
  /// Returns the rate as a double, or null if the request fails.
  static Future<double?> getUsdToInrRate() async {
    // The only change in the URL is the base currency, from INR to USD.
    final Uri url = Uri.parse('$_baseUrl$_apiKey/latest/USD');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] == 'success' && data['conversion_rates'] != null) {
          // Here, we extract the INR rate from the list of conversion rates.
          final rate = data['conversion_rates']['INR'];
          return rate?.toDouble();
        }
      }
      AppLogger.e(
          'Failed to load currency data. Status code: ${response.statusCode}');
      return null; // Return null if API call was not successful
    } catch (e) {
      // Handle exceptions like no internet connection
      AppLogger.e('CurrencyService Error: $e');
      return null;
    }
  }
}
