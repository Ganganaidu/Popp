import 'package:cloud_firestore/cloud_firestore.dart';

import '../../api/api_url.dart';

/// Data access for the admin moderation dashboard. Vends the Firestore queries
/// for pending (unapproved) products/services consumed by `ListingsGridView`,
/// so the screen doesn't reference `FirebaseFirestore`/`ApiUrl` directly.
class AdminRepository {
  final FirebaseFirestore _db;

  AdminRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Query pendingProducts() =>
      _db.collection(ApiUrl.productsPath).where('isApproved', isEqualTo: false);

  Query pendingServices() =>
      _db.collection(ApiUrl.servicePath).where('isApproved', isEqualTo: false);
}
