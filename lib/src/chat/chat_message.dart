import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final String productId;
  final String productTitle;
  final Timestamp timestamp;

  ChatMessage({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.productId,
    required this.productTitle,
  });

  // Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'productId': productId,
      'productTitle': productTitle,
    };
  }
}
