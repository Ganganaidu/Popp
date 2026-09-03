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

  /// Approved listings — the admin "all listings" management tabs.
  ///
  /// Intentionally a single equality filter (no `isSold` clause, no `orderBy`):
  /// service documents created through the listing form never get an explicit
  /// `isSold` field, and `where('isSold', isEqualTo: false)` silently drops
  /// every document that lacks the field. `ListingsGridView` filters out sold
  /// items and sorts by `createdAt` client-side (see `showAdminSoldOption`).
  Query approvedProducts() =>
      _db.collection(ApiUrl.productsPath).where('isApproved', isEqualTo: true);

  Query approvedServices() =>
      _db.collection(ApiUrl.servicePath).where('isApproved', isEqualTo: true);
}
