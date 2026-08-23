import 'package:cloud_firestore/cloud_firestore.dart';

import '../../api/api_url.dart';
import '../../utils/app_loger.dart';

/// Data access for the current user's profile document. Keeps the settings
/// screens free of direct `FirebaseFirestore`/`ApiUrl` usage.
class UserProfileRepository {
  final FirebaseFirestore _db;

  UserProfileRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Returns the user's display name, or `'Rider'` as a friendly default when
  /// unset or on error.
  Future<String> fetchUsername(String uid) async {
    try {
      final doc = await _db.collection(ApiUrl.userPath).doc(uid).get();
      final data = doc.data();
      if (data != null &&
          data['username'] != null &&
          data['username'].toString().isNotEmpty) {
        return data['username'];
      }
    } catch (e) {
      AppLogger.e('Error fetching username: $e');
    }
    return 'Rider';
  }

  /// Raw profile document (consumed via `UserData.fromFirestore`).
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(String uid) =>
      _db.collection(ApiUrl.userPath).doc(uid).get();

  Future<void> updateProfile(String uid, Map<String, dynamic> data) =>
      _db.collection(ApiUrl.userPath).doc(uid).update(data);
}
