import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SEND MESSAGE
  Future<void> sendMessage(String receiverId, String message) async {
    // Get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // Create a new message
    ChatMessage newMessage = ChatMessage(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      timestamp: timestamp,
      message: message,
    );

    // Construct chat room ID from current user ID and receiver ID (sorted to ensure uniqueness)
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); // Sort the ids (this ensures the chat room id is always the same for any pair of users)
    String chatRoomId = ids.join(
        "_"); // Combine the ids into a single string to use as a chatRoomID

    // Add new message to database
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // GET MESSAGES
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    // Construct chat room id from user ids (sorted to ensure it matches the id used when sending)
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // GET USERS STREAM
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Go through each individual user
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // For customer
  Stream<QuerySnapshot> getCustomerMessages(String customerId) {
    return _firestore
        .collection('chats')
        .doc(customerId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  Future<void> sendCustomerMessage(
      String customerId, String text, String senderId) async {
    await _firestore
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
    return _firestore.collection('chats').snapshots();
  }
}
