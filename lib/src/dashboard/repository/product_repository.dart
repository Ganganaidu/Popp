import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:popp/src/models/pop_category.dart';

import '../../api/api_url.dart';
import '../../utils/product_utils.dart';

class ProductRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<PopCategory>> fetchProductsGroupedByCategory(bool isApproved) async {
    QuerySnapshot snapshot = await _db
        .collection(ApiUrl.productsPath)
        .where('isApproved', isEqualTo: isApproved)
        .where('isActive', isEqualTo: true)
        .where('isSold', isEqualTo: false)
        .get();
    return _processSnapshot(snapshot);
  }

  Stream<List<PopCategory>> getProductsStream(
      bool isApproved) {
    return _db
        .collection(ApiUrl.productsPath)
        .where('isApproved', isEqualTo: isApproved)
        .where('isActive', isEqualTo: true)
        .where('isSold', isEqualTo: false)
        .snapshots()
        .asyncMap((snapshot) => _processSnapshot(snapshot));
  }

  Future<List<PopCategory>> _processSnapshot(
      QuerySnapshot snapshot) async {
    if (snapshot.docs.isEmpty) return [];

    List<Map<String, dynamic>> products = [];

    // Process each product and format its price
    for (var doc in snapshot.docs) {
      Map<String, dynamic> productMap =
          Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
      productMap['id'] = doc.id;
      products.add(productMap);
    }

    Map<String, List<Map<String, dynamic>>> grouped = {};
    Map<String, String> categoryNames = {};

    for (var product in products) {
      final categoryId = product['categoryId'] ?? '';
      final categoryName = product['category'] ?? 'Unknown';
      grouped.putIfAbsent(categoryId, () => []);
      grouped[categoryId]!.add(product);
      categoryNames[categoryId] = categoryName;
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
        if (a.name == ProductUtils.premiumBikes) return -1;
        if (b.name == ProductUtils.premiumBikes) return 1;
        return 0;
      });
  }
}
