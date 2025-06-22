import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_loger.dart';

import '../gallery/pic_image_gallery.dart';
import '../models/product.dart';
import '../utils/app_constants.dart';

class FirebaseProductsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<bool> submitProductForm({
    required BuildContext context,
    // Original product data from the form (without ID yet)
    required Product product,
    required List<File> images,
    required Future<void> Function(bool) onLoading, // setState handler
  }) async {
    final userId = currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login before and try again')),
      );
      return false;
    }

    onLoading(true); // Show loading

    // 1. Generate Product ID client-side
    final newProductRef = _db.collection(Constants.productsPath).doc();
    final String newProductId = newProductRef.id;

    // 2. Upload Images using the generated newProductId
    List<String> uploadedImageUrls = [];
    try {
      if (images.isNotEmpty) {
        uploadedImageUrls = await uploadMultipleImages(images);

        // Check if image upload failed (if images were provided but none were uploaded)
        if (uploadedImageUrls.isEmpty) {
          onLoading(false);
          if (!context.mounted) return false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Image upload failed. Please try again.')),
          );
          return false;
        }
      }
    } catch (e) {
      onLoading(false);
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed. Please try again.')),
      );
    }

    // 3. Prepare the complete product data with IDs and image URLs
    final Product completeProduct = product.copyWith(
      userId: userId,
      id: newProductId,
      imageUrl: uploadedImageUrls.isNotEmpty ? uploadedImageUrls.first : null,
      thumbImageUrls: uploadedImageUrls,
      createdAt: FieldValue.serverTimestamp(), // Set creation timestamp
    );

    final productDataForCheck =
        completeProduct.toJson(); // Store it in a variable

    AppLogger.d("newProductId (passed to createProduct): $newProductId");
    AppLogger.d("completeProduct.id (after copyWith): ${completeProduct.id}");
    AppLogger.d(
        "productDataForCheck['id'] (from toJson): ${productDataForCheck['id']}");
    AppLogger.d("productDataForCheck (from toJson): $productDataForCheck");

    // 4. Create the product in FireStore and update user's created list
    final String? createdProductId =
        await createProduct(newProductId, productDataForCheck);

    if (createdProductId != null) {
      // Product was successfully created in 'products' collection
      // and added to the user's 'createdProductIds' list.

      // Now, if this action also implies the user "saves" or "favorites"
      // their own listing immediately, you can call saveProductToUserProfile.
      // If creating a product doesn't mean it's automatically "saved" in a separate list,
      // you might skip this or have different logic.
      // For this example, let's assume creating also means it's "saved" by the creator.
      final bool savedToProfile =
          await saveProductToUserProfile(createdProductId);

      onLoading(false); // Hide loading
      if (!context.mounted) return false;

      if (savedToProfile) {
        // Or just check if createdProductId != null if not auto-saving
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product listed successfully!')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Product listed, but failed to add to your saved items.')),
        );
        return false;
      }
    } else {
      onLoading(false); // Hide loading
      // Attempt to delete already uploaded images if product creation fails
      if (uploadedImageUrls.isNotEmpty) {
        await deleteImagesFromStorage(uploadedImageUrls);
      }
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to list product. Please try again.')),
      );
      return false;
    }
  }

// --- Product Creation ---
  Future<String?> createProduct(
      String productId, Map<String, dynamic> productData) async {
    final user = currentUser;
    if (user == null) {
      AppLogger.d("User not logged in to create product.");
      return null;
    }

    // Ensure userId in productData matches the current user
    if (productData['userId'] != user.uid) {
      AppLogger.e(
          "Mismatch: productData.userId does not match current user.uid");
      return null; // Or throw an error
    }
    // Ensure id in productData matches the passed productId
    if (productData['id'] != productId) {
      AppLogger.e("Mismatch: productData.id does not match passed productId.");
      return null; // Or throw an error
    }

    WriteBatch batch = _db.batch();

    try {
      AppLogger.d("Batch process started");
      // 1. Set product in the global 'products' collection using the provided productId
      DocumentReference productRef =
          _db.collection(Constants.productsPath).doc(productId);
      batch.set(productRef, productData);

      AppLogger.d("Batch process productRef $productRef");
      // 2. Add product ID to the user's 'createdProductIds'
      DocumentReference userRef =
          _db.collection(Constants.userPath).doc(user.uid);
      batch.update(userRef, {
        'createdProductIds': FieldValue.arrayUnion([productId])
      });

      AppLogger.d("Batch process updated $userRef");

      await batch.commit(); // Commit both operations atomically

      AppLogger.d(
          "Product created successfully: $productId and linked to user ${user.uid}");
      return productId;
    } catch (e) {
      AppLogger.d("Error creating product or updating user profile: $e");
      // Batch will automatically roll back if any operation fails.
      return null;
    }
  }

// --- Saving/Favoriting a Product ---
  Future<bool> saveProductToUserProfile(String productId) async {
    final user = currentUser;
    if (user == null) {
      // AppLogger.d("User not logged in to save product.");
      AppLogger.d("User not logged in to save product.");
      return false;
    }

    try {
      // Check if product exists (optional, but good practice)
      final productDoc =
          await _db.collection(Constants.productsPath).doc(productId).get();
      if (!productDoc.exists) {
        // AppLogger.d("Product with ID $productId does not exist.");
        AppLogger.d("Product with ID $productId does not exist.");
        return false;
      }

      await _db.collection(Constants.userPath).doc(user.uid).update({
        'savedProductIds': FieldValue.arrayUnion([productId])
      });
      // AppLogger.d("Product $productId saved to user ${user.uid}");
      AppLogger.d("Product $productId saved to user ${user.uid}");
      return true;
    } catch (e) {
      // AppLogger.d("Error saving product to user profile: $e");
      AppLogger.d("Error saving product to user profile: $e");
      return false;
    }
  }

  Future<bool> removeSavedProductFromUserProfile(String productId) async {
    final user = currentUser;
    if (user == null) {
      // AppLogger.d("User not logged in to remove saved product.");
      AppLogger.d("User not logged in to remove saved product.");
      return false;
    }

    try {
      await _db.collection(Constants.userPath).doc(user.uid).update({
        'savedProductIds': FieldValue.arrayRemove([productId])
      });
      // AppLogger.d("Product $productId removed from user ${user.uid}'s saved list");
      AppLogger.d(
          "Product $productId removed from user ${user.uid}'s saved list");
      return true;
    } catch (e) {
      // AppLogger.d("Error removing saved product from user profile: $e");
      AppLogger.d("Error removing saved product from user profile: $e");
      return false;
    }
  }

  // In FirebaseProductsService -> updateProduct method
  Future<bool> updateProduct(
      String productId, Map<String, dynamic> dataToUpdate) async {
    final user = currentUser;
    if (user == null) {
      AppLogger.d("User not logged in to update product.");
      return false;
    }

    try {
      DocumentSnapshot productDoc =
          await _db.collection(Constants.productsPath).doc(productId).get();
      if (!productDoc.exists) {
        AppLogger.d("Product $productId does not exist, cannot update.");
        return false;
      }

      final productData = productDoc.data() as Map<String, dynamic>?;

      if (productData == null || productData['userId'] != user.uid) {
        AppLogger.e(
            "User ${user.uid} is not authorized to update product $productId (or product data is null).");
        // Depending on your rules, Firestore security rules should also prevent this.
        return false;
      }

      // Add a 'updatedAt' timestamp
      Map<String, dynamic> updatePayload =
          Map.from(dataToUpdate); // Create a mutable copy
      updatePayload['updatedAt'] = FieldValue.serverTimestamp();

      await _db
          .collection(Constants.productsPath)
          .doc(productId)
          .update(updatePayload);
      AppLogger.d("Product $productId updated successfully.");
      return true;
    } catch (e) {
      AppLogger.d("Error updating product $productId: $e");
      return false;
    }
  }

// --- Fetching Products ---

// Fetch a single product by ID
  Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      DocumentSnapshot doc =
          await _db.collection(Constants.productsPath).doc(productId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      // AppLogger.d("Error fetching product by ID: $e");
      AppLogger.d("Error fetching product by ID: $e");
      return null;
    }
  }

// Fetch all products created by the current user
  Future<List<Map<String, dynamic>>> getProductsCreatedByUser() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final userDoc =
          await _db.collection(Constants.userPath).doc(user.uid).get();
      if (!userDoc.exists || userDoc.data()?['createdProductIds'] == null) {
        return [];
      }
      final List<String> productIds =
          List<String>.from(userDoc.data()!['createdProductIds']);
      if (productIds.isEmpty) return [];

      // Fetch products in batches of 10 (Firestore 'in' query limit)
      List<Map<String, dynamic>> products = [];
      for (var i = 0; i < productIds.length; i += 10) {
        List<String> sublist = productIds.sublist(
            i, i + 10 > productIds.length ? productIds.length : i + 10);
        final querySnapshot = await _db
            .collection(Constants.productsPath)
            .where(FieldPath.documentId, whereIn: sublist)
            .get();
        products.addAll(querySnapshot.docs.map((doc) => doc.data()));
      }
      return products;
    } catch (e) {
      // AppLogger.d("Error fetching products created by user: $e");
      AppLogger.d("Error fetching products created by user: $e");
      return [];
    }
  }

// Fetch all products saved by the current user
  Future<List<Map<String, dynamic>>> getProductsSavedByUser() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final userDoc =
          await _db.collection(Constants.userPath).doc(user.uid).get();
      if (!userDoc.exists || userDoc.data()?['savedProductIds'] == null) {
        return [];
      }
      final List<String> productIds =
          List<String>.from(userDoc.data()!['savedProductIds']);
      if (productIds.isEmpty) return [];

      List<Map<String, dynamic>> products = [];
      for (var i = 0; i < productIds.length; i += 10) {
        List<String> sublist = productIds.sublist(
            i, i + 10 > productIds.length ? productIds.length : i + 10);
        final querySnapshot = await _db
            .collection(Constants.productsPath)
            .where(FieldPath.documentId, whereIn: sublist)
            .get();
        products.addAll(querySnapshot.docs.map((doc) => doc.data()));
      }
      return products;
    } catch (e) {
      // AppLogger.d("Error fetching products saved by user: $e");
      AppLogger.d("Error fetching products saved by user: $e");
      return [];
    }
  }

// Fetch all products (e.g., for a public catalog)
  Future<List<Map<String, dynamic>>> getAllProducts({int limit = 20}) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(Constants.productsPath)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      // AppLogger.d("Error fetching all products: $e");
      AppLogger.d("Error fetching all products: $e");
      return [];
    }
  }

// Fetch products by category
  Future<List<Map<String, dynamic>>> getProductsByCategory(String categoryId,
      {int limit = 20}) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(Constants.productsPath)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      // AppLogger.d("Error fetching products by category: $e");
      AppLogger.d("Error fetching products by category: $e");
      return [];
    }
  }

// --- User Profile Setup (Call this when a user signs up) ---
  Future<void> createUserProfileDocument(User user, {String? email}) async {
    try {
      await _db.collection(Constants.userPath).doc(user.uid).set(
          {
            'uid': user.uid,
            'email':
                email ?? user.email, // Use provided email or from User object
            'createdAt': FieldValue.serverTimestamp(),
            'createdProductIds': [], // Initialize as empty arrays
            'savedProductIds': [],
          },
          SetOptions(
              merge: true)); // Merge to avoid overwriting if doc somehow exists
      // AppLogger.d("User profile created for ${user.uid}");
      AppLogger.d("User profile created for ${user.uid}");
    } catch (e) {
      // AppLogger.d("Error creating user profile document: $e");
      AppLogger.d("Error creating user profile document: $e");
    }
  }

  Future<bool> submitListServicesForm({
    required BuildContext context,
    required Map<String, dynamic> data,
    required List<File> promoImages,
    required List<File> shopGarageImages,
    required Function(bool) onLoading,
  }) async {
    onLoading(true);
    try {
      AppLogger.d("Submitting service listing with data: $data");

      // Upload promo images
      final uploadedPromoImageUrls = await uploadImagesHelper(promoImages, context, onLoading);
      if (promoImages.isNotEmpty && uploadedPromoImageUrls.isEmpty) return false;
      data['promoImageUrls'] = uploadedPromoImageUrls;

      // AppLogger.d("Uploaded promo images: $uploadedPromoImageUrls");
      // Upload shop/garage images
      if (!context.mounted) return false;
      final uploadedShopImageUrls = await uploadImagesHelper(shopGarageImages, context, onLoading);
      if (shopGarageImages.isNotEmpty && uploadedShopImageUrls.isEmpty) {
        // Only return false if images were provided but upload failed
        return false;
      }
      data['shopImageUrls'] = uploadedShopImageUrls;

      AppLogger.d("Uploaded shop/garage images: $uploadedShopImageUrls");
      // save the service data to FireStore
      try {
        AppLogger.d("Attempting to add service to Firestore: $data");
        await _db.collection(Constants.servicePath).add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
          'userId': FirebaseAuth.instance.currentUser?.uid,
        });
        AppLogger.d("Service successfully added to Firestore.");
      } catch (e, stack) {
        AppLogger.e("Firestore add error: $e\nStack: $stack");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to list service (Firestore error): $e')),
          );
        }
        return false;
      }

      if (context.mounted) {
        AppLogger.d("Service listed successfully: $data");
         // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service listed successfully!')),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        AppLogger.d("Error listing service: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to list service: $e')),
        );
      }
      return false;
    } finally {
      AppLogger.d("Finally block executed in submitListServicesForm");
      onLoading(false);
    }
  }
}
