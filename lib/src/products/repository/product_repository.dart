import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../../admin/admin_notification_service.dart';
import '../../api/api_url.dart';
import '../../api/firebase/firebase_api_service.dart';
import '../../gallery/pic_image_gallery.dart';
import '../../models/product.dart';

/// Data access for the products feature.
///
/// This is the single seam between the products viewmodels and the backend.
/// It delegates the already-battle-tested calls to [FirebaseApiService] (so
/// behaviour is unchanged) while giving the feature a clean, UI-free API to
/// depend on. No `BuildContext`, no widgets.
class ProductRepository {
  final FirebaseApiService _api;
  final FirebaseFirestore _db;

  ProductRepository({FirebaseApiService? api, FirebaseFirestore? db})
      : _api = api ?? FirebaseApiService(),
        _db = db ?? FirebaseFirestore.instance;

  /// Uid of the signed-in user, or null. Used for ownership/admin checks.
  String? get currentUserId => _api.currentUser?.uid;

  /// Reference to a single product document — used by callers that need to run
  /// their own writes (e.g. the mark-as-sold confirm flow).
  DocumentReference<Map<String, dynamic>> productDoc(String productId) =>
      _db.collection(ApiUrl.productsPath).doc(productId);

  Future<Map<String, dynamic>?> getProductById(String productId) =>
      _api.getProductById(productId);

  Future<List<Map<String, dynamic>>> getProductsByCategory(
    List<String> categories, {
    List<String>? subCategory,
  }) =>
      _api.getProductsByCategory(categories, subCategory: subCategory);

  /// Toggles the current user in the product's `favoritedBy` array. Returns
  /// true on success.
  Future<bool> toggleFavorite(String productId) =>
      _api.toggleFavoriteProduct(ApiUrl.productsPath, productId);

  // --- Admin moderation actions ---------------------------------------------
  // These delegate to [AdminNotificationService], which performs the status
  // write that Cloud Functions watch to dispatch the user notification.

  Future<void> approve(String productId) =>
      AdminNotificationService.approveListing(listingRef: productDoc(productId));

  Future<void> sendBack(String productId, String? feedback) =>
      AdminNotificationService.sendBackListing(
          listingRef: productDoc(productId), feedback: feedback);

  Future<void> reject(String productId, String? reason) =>
      AdminNotificationService.rejectListing(
          listingRef: productDoc(productId), reason: reason);

  /// Publishes a pending update to an already-approved listing.
  Future<void> approvePendingUpdate(
          String productId, Map<String, dynamic> pendingUpdate) =>
      AdminNotificationService.approvePendingUpdate(
          listingRef: productDoc(productId), pendingUpdate: pendingUpdate);

  /// Discards a pending update, keeping the original approved content.
  Future<void> rejectPendingUpdate(String productId, String? feedback) =>
      AdminNotificationService.rejectPendingUpdate(
          listingRef: productDoc(productId), feedback: feedback);

  // --- Product create/edit (sell-your-bike / -accessories forms) -----------
  // These delegate to the existing, proven [FirebaseApiService] implementations
  // (which own the image-upload + snackbar orchestration), so the form screens
  // depend on this repository rather than the shared god-service directly.

  Future<bool> submitProductForm({
    required BuildContext context,
    required Product product,
    required List<File> images,
    required Future<void> Function(bool) onLoading,
  }) =>
      _api.submitProductForm(
        context: context,
        product: product,
        images: images,
        onLoading: onLoading,
      );

  Future<bool> updateProduct(
          String productId, Map<String, dynamic> dataToUpdate) =>
      _api.updateProduct(productId, dataToUpdate);

  /// Admin-only: permanently deletes a product listing — its Firestore document,
  /// its uploaded images, and any references to it on the owner's user document.
  /// Image / user-doc cleanup failures are logged but do not block the delete.
  Future<void> deleteProduct(String productId) async {
    final ref = productDoc(productId);
    final snapshot = await ref.get();
    final data = snapshot.data();

    if (data != null) {
      final images = <String>{
        ...((data['thumbImageUrls'] as List<dynamic>?)?.whereType<String>() ??
            const <String>[]),
        if (data['imageUrl'] is String &&
            (data['imageUrl'] as String).isNotEmpty)
          data['imageUrl'] as String,
      };
      if (images.isNotEmpty) {
        await deleteImagesFromStorage(images.toList());
      }

      final ownerId = data['userId'] as String?;
      if (ownerId != null && ownerId.isNotEmpty) {
        try {
          await _db.collection(ApiUrl.userPath).doc(ownerId).update({
            'createdProductIds': FieldValue.arrayRemove([productId]),
            'savedProductIds': FieldValue.arrayRemove([productId]),
          });
        } catch (_) {
          // Non-fatal: the listing itself is still removed below.
        }
      }
    }

    await ref.delete();
  }
}
