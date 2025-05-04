import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final fireStore = FirebaseFirestore.instance;

  // For customer
  Stream<QuerySnapshot> getCustomerMessages(String customerId) {
    return fireStore
        .collection('chats')
        .doc(customerId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  Future<void> sendCustomerMessage(
      String customerId, String text, String senderId) async {
    await fireStore
        .collection('chats')
        .doc(customerId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // For agent
  Stream<QuerySnapshot> getChatRooms() {
    return fireStore.collection('chats').snapshots();
  }
}
