import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<bool> isUserSubscribed() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final doc = await _fireStore.collection('userSubscriptions').doc(uid).get();
    if (!doc.exists) return false;

    final data = doc.data()!;
    final startDate = (data['startDate'] as Timestamp).toDate();
    final isSubscribed = data['isSubscribed'] ?? false;

    final freeTrialEnd = startDate.add(const Duration(days: 180));
    final now = DateTime.now();

    return now.isBefore(freeTrialEnd) || isSubscribed;
  }

  Future<void> updateSubscriptionStatus(bool isSubscribed, PurchaseDetails purchaseDetails) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _fireStore.collection('userSubscriptions').doc(uid);
    await docRef.set({
      'isSubscribed': isSubscribed,
      'purchaseDetails' : purchaseDetails,
      'startDate': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  // SubscriptionService().isUserSubscribed().then((isSubscribed) {
  // setState(() {
  // _isSubscribed = isSubscribed;
  // });
  // });
}
