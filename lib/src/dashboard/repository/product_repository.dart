import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:popp/src/api/currency_service.dart';
import 'package:popp/src/models/pop_category.dart';

import '../../api/api_url.dart';
import '../../models/product.dart';

class ProductRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<PopCategory>> fetchProductsGroupedByCategory(
      bool isApproved, String targetCountryCode) async {
    QuerySnapshot snapshot = await _db
        .collection(ApiUrl.productsPath)
        .where('isApproved', isEqualTo: isApproved)
        .get();
    if (snapshot.docs.isEmpty) return [];

    List<Product> products = [];

    // Process each product and format its price
    for (var doc in snapshot.docs) {
      Product product =
          Product.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      // Format the expected price using CurrencyService
      String formattedPrice = await CurrencyService.getLocalizedPrice(
          product.expectedPrice.toString(),
          product.countryCode,
          targetCountryCode);
      product = product.copyWith(expectedPrice: formattedPrice);
      products.add(product);
    }

    Map<String, List<Product>> grouped = {};
    Map<String, String> categoryNames = {};

    for (var product in products) {
      grouped.putIfAbsent(product.categoryId, () => []);
      grouped[product.categoryId]!.add(product);
      categoryNames[product.categoryId] = product.category;
    }

    return grouped.entries.map((entry) {
      return PopCategory(
        categoryId: entry.key,
        name: categoryNames[entry.key] ?? 'Unknown',
        products: entry.value,
      );
    }).toList()
      // Sort so that 'Premium bike' category comes first
      ..sort((a, b) {
        if (a.name == 'Premium Bikes') return -1;
        if (b.name == 'Premium Bikes') return 1;
        return 0;
      });
  }
}
