import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:popp/src/api/api_url.dart';

import '../model/ad_banner.dart';

class AdRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch ads. If [isActive] is provided, query only documents with that
  /// isActive value. Otherwise return all ads.
  Future<List<AdBanner>> fetchAds([bool? isActive]) async {
    Query collection = _firestore.collection(ApiUrl.adsPath);

    if (isActive != null) {
      collection = collection.where('isActive', isEqualTo: isActive);
    }

    final snapshot = await collection.get();

    return snapshot.docs.map((doc) => AdBanner.fromDocument(doc)).toList();
  }

  /// Update only the `isActive` flag of an ad document. Requires a valid doc id.
  Future<void> updateAdStatus(String id, bool isActive) async {
    if (id.isEmpty) throw ArgumentError('Document id cannot be empty');
    await _firestore.collection(ApiUrl.adsPath).doc(id).update({'isActive': isActive});
  }
}
