import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poppflutter/src/utils/app_loger.dart';

/// Saves a list of products associated with a specific category to Firestore.
///
/// This function creates or updates a document in the 'category_products' collection.
/// The document ID is determined by the `categoryId`.
///
/// Args:
///   categoryId: The unique identifier for the category.
///   categoryName: The name of the category.
///   products: A list of maps, where each map represents a product with its details.
///
/// Returns:
///   A Future that completes when the operation is done.
///
/// Throws:
///   FirebaseException: If there is an error during the Firestore operation.
///
/// ex:
///   await saveCategoryProducts(
///   "cat_001",
///   "Premium Bikes",
///   premiumBikesProducts,
/// );

Future<bool> saveCategoryProducts({
  required String categoryId,
  required String categoryName,
  required Map<String, dynamic> products,
}) async {
  try {
    final categoryRef = FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId);

    // Ensure category exists (optional)
    await categoryRef.set({
      'categoryName': categoryName,
    }, SetOptions(merge: true));

    await categoryRef.collection('products').add({
      ...products,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return true;
  } catch (e) {
    AppLogger.d("Error saving product: $e");
    return false;
  }
}


Future<List<Map<String, dynamic>>> fetchAllProducts() async {
  final categoriesSnapshot = await FirebaseFirestore.instance
      .collection('categories')
      .get();

  final List<Map<String, dynamic>> allProducts = [];

  for (final cat in categoriesSnapshot.docs) {
    final productsSnapshot = await cat.reference
        .collection('products')
        .get();

    for (final doc in productsSnapshot.docs) {
      allProducts.add(doc.data());
    }
  }

  return allProducts;
}


Future<List<Map<String, dynamic>>> getProductsByCategoryId(String categoryId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('categories')
      .doc(categoryId)
      .collection('products')
      .get();

  return snapshot.docs.map((doc) => doc.data()).toList();
}


Future<List<Map<String, dynamic>>> getProductsByCategoryName(String name) async {
  final categorySnap = await FirebaseFirestore.instance
      .collection('categories')
      .where('categoryName', isEqualTo: name)
      .limit(1)
      .get();

  if (categorySnap.docs.isEmpty) return [];

  final categoryId = categorySnap.docs.first.id;

  return getProductsByCategoryId(categoryId);
}

// For Dashboard view
Future<Map<String, List<Map<String, dynamic>>>> getProductsGroupedByCategory() async {
  final categoriesSnapshot = await FirebaseFirestore.instance
      .collection('categories')
      .get();

  final Map<String, List<Map<String, dynamic>>> grouped = {};

  for (final cat in categoriesSnapshot.docs) {
    final productsSnapshot = await cat.reference.collection('products').get();

    grouped[cat['categoryName']] = productsSnapshot.docs
        .map((doc) => doc.data())
        .toList();
  }

  return grouped;
}


