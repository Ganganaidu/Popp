import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/api_url.dart';

class NotificationService {
  static CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance
          .collection(ApiUrl.userPath)
          .doc(uid)
          .collection(ApiUrl.notificationsSubPath);

  static Future<void> saveNotification({
    required String uid,
    required String title,
    required String body,
    String? type,
    String? relatedId,
  }) async {
    await _col(uid).add({
      'title': title,
      'body': body,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      if (type != null) 'type': type,
      if (relatedId != null) 'relatedId': relatedId,
    });
  }

  static Stream<int> unreadCountStream(String uid) => _col(uid)
      .where('isRead', isEqualTo: false)
      .snapshots()
      .map((s) => s.docs.length);

  static Stream<QuerySnapshot<Map<String, dynamic>>> notificationsStream(
          String uid) =>
      _col(uid).orderBy('createdAt', descending: true).snapshots();

  static Future<void> markAsRead(String uid, String notifId) =>
      _col(uid).doc(notifId).update({'isRead': true});

  static Future<void> markAllAsRead(String uid) async {
    final snap = await _col(uid).where('isRead', isEqualTo: false).get();
    if (snap.docs.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
