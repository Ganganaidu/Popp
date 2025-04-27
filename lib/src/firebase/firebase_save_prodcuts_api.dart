import 'package:cloud_firestore/cloud_firestore.dart';

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
Future<void> saveCategoryProducts(String categoryId, String categoryName,
    List<Map<String, dynamic>> products) async {
  await FirebaseFirestore.instance
      .collection('category_products')
      .doc(categoryId)
      .set({
    'categoryId': categoryId,
    'categoryName': categoryName,
    'products': products,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
