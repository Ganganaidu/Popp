import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_loger.dart';

import '../api_url.dart';
import '../../gallery/pic_image_gallery.dart';
import '../../models/product.dart';
import '../../systemalerts/message_data.dart';

class FirebaseApiService {
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
    final newProductRef = _db.collection(ApiUrl.productsPath).doc();
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

    final productDataForCheck = completeProduct.toJson();
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
        AppLogger.d(
            "Product listed successfully and added to user's saved items: $createdProductId");
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
          _db.collection(ApiUrl.productsPath).doc(productId);
      batch.set(productRef, productData);

      AppLogger.d("Batch process productRef $productRef");
      // 2. Add product ID to the user's 'createdProductIds'
      DocumentReference userRef = _db.collection(ApiUrl.userPath).doc(user.uid);
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
          await _db.collection(ApiUrl.productsPath).doc(productId).get();
      if (!productDoc.exists) {
        // AppLogger.d("Product with ID $productId does not exist.");
        AppLogger.d("Product with ID $productId does not exist.");
        return false;
      }

      await _db.collection(ApiUrl.userPath).doc(user.uid).update({
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
      await _db.collection(ApiUrl.userPath).doc(user.uid).update({
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
          await _db.collection(ApiUrl.productsPath).doc(productId).get();
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
          .collection(ApiUrl.productsPath)
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
          await _db.collection(ApiUrl.productsPath).doc(productId).get();
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
      final userDoc = await _db.collection(ApiUrl.userPath).doc(user.uid).get();
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
            .collection(ApiUrl.productsPath)
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
      final userDoc = await _db.collection(ApiUrl.userPath).doc(user.uid).get();
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
            .collection(ApiUrl.productsPath)
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
          .collection(ApiUrl.productsPath)
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
          .collection(ApiUrl.productsPath)
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
      await _db.collection(ApiUrl.userPath).doc(user.uid).set(
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
      final uploadedPromoImageUrls =
          await uploadImagesHelper(promoImages, context, onLoading);
      if (promoImages.isNotEmpty && uploadedPromoImageUrls.isEmpty) {
        return false;
      }
      data['promoImageUrls'] = uploadedPromoImageUrls;

      // AppLogger.d("Uploaded promo images: $uploadedPromoImageUrls");
      // Upload shop/garage images
      if (!context.mounted) return false;
      final uploadedShopImageUrls =
          await uploadImagesHelper(shopGarageImages, context, onLoading);
      if (shopGarageImages.isNotEmpty && uploadedShopImageUrls.isEmpty) {
        // Only return false if images were provided but upload failed
        return false;
      }
      data['shopImageUrls'] = uploadedShopImageUrls;

      AppLogger.d("Uploaded shop/garage images: $uploadedShopImageUrls");
      // save the service data to FireStore
      try {
        AppLogger.d("Attempting to add service to Firestore: $data");
        await _db.collection(ApiUrl.servicePath).add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
          'isApproved': false, // Default to false
          'isFavorite': false, // Default to false
          'userId': FirebaseAuth.instance.currentUser?.uid,
        });
        AppLogger.d("Service successfully added to Firestore.");
      } catch (e, stack) {
        AppLogger.e("Firestore add error: $e\nStack: $stack");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to list service (Firestore error): $e')),
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

  Future<bool> updateServiceApprovalStatus(
      String serviceId, bool isApproved) async {
    try {
      AppLogger.d(
          "Service $serviceId requesting approval status updated to $isApproved");

      await _db.collection(ApiUrl.servicePath).doc(serviceId).update({
        'isApproved': isApproved,
        'approvedAt': FieldValue.serverTimestamp(),
        // Optional: track approval time
      });
      AppLogger.d("Service $serviceId approval status updated to $isApproved");
      return true;
    } catch (e) {
      AppLogger.d("Error updating approval status for service $serviceId: $e");
      return false;
    }
  }

  Future<bool> updateProductApprovalStatus(
      String serviceId, bool isApproved) async {
    try {
      await _db.collection(ApiUrl.productsPath).doc(serviceId).update({
        'isApproved': isApproved,
        'approvedAt': FieldValue.serverTimestamp(),
        // Optional: track approval time
      });
      AppLogger.d("Service $serviceId approval status updated to $isApproved");
      return true;
    } catch (e) {
      AppLogger.d("Error updating approval status for service $serviceId: $e");
      return false;
    }
  }

  // Method to fetch services based on category
  Future<List<Map<String, dynamic>>> fetchServicesByCategories(
      List<String> categories, bool isApproved) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection(ApiUrl.servicePath)
          .where('category', whereIn: categories)
          .where('isApproved', isEqualTo: isApproved)
          .where('isActive', isEqualTo: true)
          .get();

      // Include document ID as 'id' in each map
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      AppLogger.d("Error fetching services: $e");
      return [];
    }
  }

  // Adds or removes a product from the user's favorites.
  Future<bool> toggleFavoriteProduct(
      String collectionPath, String productId) async {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    final productRef = _db.collection(collectionPath).doc(productId);

    try {
      await _db.runTransaction((transaction) async {
        AppLogger.d("productRef $productRef");
        final snapshot = await transaction.get(productRef);
        if (!snapshot.exists) {
          throw Exception("Product does not exist!");
        }
        final List<String> favoritedBy =
            List<String>.from(snapshot.data()?['favoritedBy'] ?? []);
        AppLogger.d("favoritedBy $favoritedBy");
        if (favoritedBy.contains(user.uid)) {
          transaction.update(productRef, {
            'favoritedBy': FieldValue.arrayRemove([user.uid])
          });
        } else {
          transaction.update(productRef, {
            'favoritedBy': FieldValue.arrayUnion([user.uid])
          });
        }
      });
      return true;
    } catch (e) {
      AppLogger.d('toggleFavoriteProduct error: $e');
      return false;
    }
  }

  Future<SystemMessage?> getPriorityMessage() async {
    // 1. Check for a global message first.
    final globalMessage = await _getGlobalMessage();
    if (globalMessage != null &&
        globalMessage.isActive &&
        globalMessage.priority == MessagePriority.high) {
      // If there's a high-priority global message, it overrides everything.
      return globalMessage;
    }

    // 2. Check for a user-specific block message.
    final user = _auth.currentUser;
    if (user != null) {
      final userMessage = await _getUserBlockMessage(user.uid);
      if (userMessage != null && userMessage.isActive) {
        // A user block is always high priority.
        return userMessage;
      }
    }

    // 3. If no high-priority messages, return the active global message (if any).
    if (globalMessage != null && globalMessage.isActive) {
      return globalMessage;
    }

    // No active messages found.
    return null;
  }

  /// Fetches the current global message.
  Future<SystemMessage?> _getGlobalMessage() async {
    try {
      final doc = await _db.collection(ApiUrl.globalMessagesPath).doc('current').get();
      if (doc.exists) {
        return SystemMessage.fromFirestore(doc);
      }
    } catch (e) {
      // Handle potential errors, e.g., logging.
      AppLogger.e("Error fetching global message: $e");
    }
    return null;
  }

  /// Fetches a block message for a specific user.
  Future<SystemMessage?> _getUserBlockMessage(String userId) async {
    try {
      final doc = await _db
          .collection(ApiUrl.userPath)
          .doc(userId)
          .collection('user_messages')
          .doc('block_status')
          .get();

      if (doc.exists) {
        return SystemMessage.fromFirestore(doc);
      }
    } catch (e) {
      AppLogger.e("Error fetching user message: $e");
    }
    return null;
  }
}
