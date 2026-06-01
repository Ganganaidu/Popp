import 'package:cloud_firestore/cloud_firestore.dart';

enum MessagePriority { low, high, appUpdate, none }

class SystemMessage {
  final String message;
  final String priority;
  final bool isActive;
  final String? messageId;
  final String? versionCode;
  final String? playStoreUrl;
  final String? appStoreUrl;

  SystemMessage({
    required this.message,
    required this.priority,
    required this.messageId,
    this.versionCode,
    this.playStoreUrl,
    this.appStoreUrl,
    this.isActive = false,
  });

  factory SystemMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SystemMessage(
      message:
          data['message'] ?? 'An important message from the Bikerverse team.',
      messageId: data['messageId'],
      versionCode: data['versionCode'],
      priority: data['priority'],
      isActive: data['isActive'] ?? false,
    );
  }
}

String getPriorityMessageTitle(String priority) {
  if (priority == MessagePriority.high.name) {
    return 'Access Restricted';
  } else if (priority == MessagePriority.appUpdate.name) {
    return 'Update Required';
  }
  return 'Important Message';
}

String getButtonText(String priority) {
  if (priority == MessagePriority.high.name) {
    return 'Dismiss';
  } else if (priority == MessagePriority.appUpdate.name) {
    return 'Open store';
  }
  return 'okay, got it';
}
