import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:poppflutter/src/utils/app_loger.dart';

import '../models/category.dart';

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
    await FirebaseFirestore.instance.collection('category_products').add({
      ...products,
      'userId': '',
      'categoryId': categoryId,
      'categoryName': categoryName,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return true;
  } catch (e) {
    AppLogger.d("Error submitting form: $e");
    return false;
  }
}

