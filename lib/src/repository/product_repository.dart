import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poppflutter/src/utils/app_loger.dart';
import '../models/product.dart';
import '../models/category.dart';

class ProductRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Category>> fetchProductsGroupedByCategory() async {
    QuerySnapshot snapshot = await _db.collection('products').get();
    if (snapshot.docs.isEmpty) return [];

    AppLogger.d("snapshot $snapshot");
    List<Product> products = snapshot.docs.map((doc) {
      return Product.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    AppLogger.d("products ${products.length}");
    Map<String, List<Product>> grouped = {};
    Map<String, String> categoryNames = {};

    for (var product in products) {
      grouped.putIfAbsent(product.categoryId, () => []);
      grouped[product.categoryId]!.add(product);
      categoryNames[product.categoryId] = product.categoryName;
    }

    return grouped.entries.map((entry) {
      return Category(
        categoryId: entry.key,
        name: categoryNames[entry.key] ?? 'Unknown',
        products: entry.value,
      );
    }).toList();
  }
}
