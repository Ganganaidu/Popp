import 'dart:convert';

import 'package:http/http.dart' as http;
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
}
