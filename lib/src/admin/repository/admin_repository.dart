import 'package:cloud_firestore/cloud_firestore.dart';

import '../../api/api_url.dart';

/// Data access for the admin moderation dashboard. Vends the Firestore queries
/// consumed by `ListingsGridView`, so the screen doesn't reference
/// `FirebaseFirestore`/`ApiUrl` directly.
class AdminRepository {
  final FirebaseFirestore _db;

  AdminRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Listings awaiting moderation: not yet approved, OR approved with a pending
  /// update to review.
  Query pendingProducts() => _db.collection(ApiUrl.productsPath).where(Filter.or(
        Filter('isApproved', isEqualTo: false),
        Filter('hasPendingUpdate', isEqualTo: true),
      ));

  Query pendingServices() => _db.collection(ApiUrl.servicePath).where(Filter.or(
        Filter('isApproved', isEqualTo: false),
        Filter('hasPendingUpdate', isEqualTo: true),
      ));

  /// Approved, unsold listings — the admin "all listings" management tabs.
  Query approvedUnsoldProducts() => _db
      .collection(ApiUrl.productsPath)
      .where('isApproved', isEqualTo: true)
      .where('isSold', isEqualTo: false)
      .orderBy('createdAt', descending: true);

  Query approvedUnsoldServices() => _db
      .collection(ApiUrl.servicePath)
      .where('isApproved', isEqualTo: true)
      .where('isSold', isEqualTo: false)
      .orderBy('createdAt', descending: true);
}
