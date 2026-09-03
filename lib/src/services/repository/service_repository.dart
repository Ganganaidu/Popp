import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../../api/api_url.dart';
import '../../api/firebase/firebase_api_service.dart';
import '../../gallery/pic_image_gallery.dart';

/// Data access for the services feature — the single seam between the services
/// viewmodels and Firestore. Delegates the existing, proven calls to
/// [FirebaseApiService] and adds a couple of service-specific reads. No
/// `BuildContext`, no widgets.
class ServiceRepository {
  final FirebaseApiService _api;
  final FirebaseFirestore _db;

  ServiceRepository({FirebaseApiService? api, FirebaseFirestore? db})
      : _api = api ?? FirebaseApiService(),
        _db = db ?? FirebaseFirestore.instance;

  String? get currentUserId => _api.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> serviceDoc(String serviceId) =>
      _db.collection(ApiUrl.servicePath).doc(serviceId);

  Future<List<Map<String, dynamic>>> fetchByCategories(
    List<String> categories, {
    bool isApproved = true,
    String? subCategory,
  }) =>
      _api.fetchServicesByCategories(categories, isApproved,
          subCategory: subCategory);

  Future<Map<String, dynamic>?> getServiceById(String serviceId) async {
    final doc = await serviceDoc(serviceId).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return {...data, 'id': doc.id};
  }

  Future<bool> toggleFavorite(String serviceId) =>
      _api.toggleFavoriteProduct(ApiUrl.servicePath, serviceId);

  Future<bool> updateApprovalStatus(String serviceId, bool isApproved) =>
      _api.updateServiceApprovalStatus(serviceId, isApproved);

  Future<bool> updateService(String serviceId, Map<String, dynamic> data) =>
      _api.updateService(serviceId, data);

  /// Admin-only: permanently deletes a service listing — its Firestore document
  /// and its uploaded promo / shop images. Image cleanup failures are logged but
  /// do not block the delete.
  Future<void> deleteService(String serviceId) async {
    final ref = serviceDoc(serviceId);
    final snapshot = await ref.get();
    final data = snapshot.data();

    if (data != null) {
      final images = <String>{};
      for (final key in const ['promoImageUrls', 'shopImageUrls']) {
        final value = data[key];
        if (value is List) {
          images.addAll(value.whereType<String>());
        } else if (value is String && value.isNotEmpty) {
          images.add(value);
        }
      }
      if (images.isNotEmpty) {
        await deleteImagesFromStorage(images.toList());
      }
    }

    await ref.delete();
  }

  /// Submits a new service listing (delegates to the proven
  /// [FirebaseApiService] implementation that owns image upload + snackbars).
  Future<bool> submitListServicesForm({
    required BuildContext context,
    required Map<String, dynamic> data,
    required List<File> promoImages,
    required List<File> shopGarageImages,
    required Function(bool) onLoading,
  }) =>
      _api.submitListServicesForm(
        context: context,
        data: data,
        promoImages: promoImages,
        shopGarageImages: shopGarageImages,
        onLoading: onLoading,
      );
}
