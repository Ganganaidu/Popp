import 'package:cloud_firestore/cloud_firestore.dart';

import '../../api/api_url.dart';

/// Vends the Firestore queries backing the user's listing/favorite grids, so
/// the settings screens don't construct `collection(...).where(...)` chains (or
/// reference `FirebaseFirestore`/`ApiUrl`) themselves. The reusable
/// `ListingsGridView` consumes the returned [Query].
class ListingsRepository {
  final FirebaseFirestore _db;

  ListingsRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Query favoriteProducts(String uid) => _db
      .collection(ApiUrl.productsPath)
      .where('favoritedBy', arrayContains: uid);

  Query favoriteServices(String uid) => _db
      .collection(ApiUrl.servicePath)
      .where('favoritedBy', arrayContains: uid);

  Query myProducts(String uid) =>
      _db.collection(ApiUrl.productsPath).where('userId', isEqualTo: uid);

  Query myServices(String uid) =>
      _db.collection(ApiUrl.servicePath).where('userId', isEqualTo: uid);
}
