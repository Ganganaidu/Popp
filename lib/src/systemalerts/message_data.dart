import 'package:cloud_firestore/cloud_firestore.dart';

enum MessagePriority { low, high, none }

class SystemMessage {
  final String message;
  final MessagePriority priority;
  final bool isActive;

  SystemMessage({
    required this.message,
    required this.priority,
    this.isActive = false,
  });

  factory SystemMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SystemMessage(
      message: data['message'] ?? 'An important message from the Popp team.',
      priority: (data['priority'] == 'high')
          ? MessagePriority.high
          : MessagePriority.low,
      isActive: data['isActive'] ?? false,
    );
  }
}
