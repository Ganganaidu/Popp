import 'package:cloud_firestore/cloud_firestore.dart';

import '../../api/api_url.dart';

/// Data access for global search across products and services (matched on the
/// `searchKeywords` array). Shared by the search screen and the explore search.
class SearchRepository {
  final FirebaseFirestore _db;

  SearchRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Returns matching products and services (each tagged with `type` and `id`),
  /// excluding sold items. Returns an empty list for a blank query.
  Future<List<Map<String, dynamic>>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final keyword = trimmed.toLowerCase();
    final results = <Map<String, dynamic>>[];

    Future<void> addFrom(String collection, String type) async {
      final snap = await _db
          .collection(collection)
          .where('searchKeywords', arrayContainsAny: [keyword]).get();
      results.addAll(snap.docs
          .map((doc) => {...doc.data(), 'type': type, 'id': doc.id})
          .where((item) => item['isSold'] != true && item['status'] != 'Sold'));
    }

    await addFrom(ApiUrl.productsPath, 'product');
    await addFrom(ApiUrl.servicePath, 'service');
    return results;
  }
}
