import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:popp/src/utils/app_loger.dart';

/// A service class to handle fetching currency conversion rates from an API.
class CurrencyService {
  final String _apiKey = '7c021024b664cfb6d1e1dc27';
  final String _baseUrl = 'https://v6.exchangerate-api.com/v6/';

  /// Fetches the conversion rate from INR to USD.
  /// Returns the rate as a double, or null if the request fails.
  Future<double?> getInrToUsdRate() async {
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
  Future<double?> getUsdToInrRate() async {
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

  Future<String> getLocalizedPrice(
    BuildContext context,
    String priceValueStr,
    String? sourceCuntryCode,
  ) async {
    double priceValue;
    try {
      priceValue = double.parse(priceValueStr);
    } catch (e) {
      // Handle the case where priceValue is not a valid double string.
      // For example, log an error and/or use a default value.
      AppLogger.e('Error parsing priceValue: $priceValueStr, Error: $e');
      priceValue = 0.0; // Fallback to 0.0 or another appropriate default
    }

    String sourceCurrency = (sourceCuntryCode == 'IN') ? 'INR' : 'USD';
    // 1. Get the device's locale to determine the target currency.
    final String targetCountryCode =
        Localizations.localeOf(context).countryCode ?? 'US';

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
}
