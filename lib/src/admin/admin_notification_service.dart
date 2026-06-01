import 'package:cloud_firestore/cloud_firestore.dart';

/// Updates listing status in Firestore.
/// The actual FCM push notifications are dispatched by Firebase Cloud Functions
/// that watch for document updates on the products/services collections.
class AdminNotificationService {
  static Future<void> approveListing({
    required DocumentReference listingRef,
  }) async {
    await listingRef.update({
      'status': 'approved',
      'isApproved': true,
      'isActive': true,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    });
    // Cloud Function onProductApproved / onServiceApproved fires automatically
    // when isApproved changes false → true.
  }

  static Future<void> sendBackListing({
    required DocumentReference listingRef,
    String? feedback,
  }) async {
    final data = <String, dynamic>{
      'status': 'sent_back',
      'isApproved': false,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    };
    if (feedback != null && feedback.trim().isNotEmpty) {
      data['adminFeedback'] = feedback.trim();
    }
    await listingRef.update(data);
    // Cloud Function onProductSentBack / onServiceSentBack fires automatically.
  }

  static Future<void> rejectListing({
    required DocumentReference listingRef,
    String? reason,
  }) async {
    final data = <String, dynamic>{
      'status': 'rejected',
      'isApproved': false,
      'isActive': false,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    };
    if (reason != null && reason.trim().isNotEmpty) {
      data['adminFeedback'] = reason.trim();
    }
    await listingRef.update(data);
    // Cloud Function onProductRejected / onServiceRejected fires automatically.
  }
}
