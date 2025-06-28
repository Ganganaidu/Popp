import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:popp/src/utils/app_loger.dart';
import '../../models/product.dart';
import 'package:popp/src/models/pop_category.dart';

import '../../utils/app_constants.dart';

class ProductRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<PopCategory>> fetchProductsGroupedByCategory(bool isApproved) async {
    QuerySnapshot snapshot = await _db
        .collection(Constants.productsPath)
        .where('isApproved', isEqualTo: isApproved)
        .get();
    if (snapshot.docs.isEmpty) return [];

    List<Product> products = snapshot.docs.map((doc) {
      return Product.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

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
