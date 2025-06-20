import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_loger.dart';

import 'chat_message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        AppLogger.e("No current user found. Cannot send message.");
        return;
      }

      final String currentUserId = currentUser.uid;
      final String currentUserEmail = currentUser.email ??
          "anonymous@example.com"; // Provide fallback for anonymous
      final Timestamp timestamp = Timestamp.now();

      AppLogger.d("Sending message from: $currentUserId to: $receiverId");
      AppLogger.d("Message: $message");

      ChatMessage newMessage = ChatMessage(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId,
        timestamp: timestamp,
        message: message,
      );

      List<String> ids = [currentUserId, receiverId];
      ids.sort();
      String chatRoomId = ids.join("_");

      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap())
          .then((value) {
        AppLogger.d("Message sent successfully with ID: ${value.id}");
      }).catchError((error, stack) {
        AppLogger.e("Failed to send message: $error", stack);
      });

      AppLogger.d("newMessage data: ${newMessage.toMap()}");
    } catch (e, stack) {
      AppLogger.e("Failed to send message: $e", stack);
      rethrow;
    }
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    try {
      List<String> ids = [userId, otherUserId];
      ids.sort();
      String chatRoomId = ids.join("_");

      AppLogger.d(
          "Getting messages for chatRoomId: $chatRoomId (between $userId and $otherUserId)");

      return _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots();
    } catch (e, stack) {
      AppLogger.e("Failed to get messages: $e", stack);
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    try {
      return _firestore.collection('users').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final user = doc.data();
          user['id'] = doc.id;
          return user;
        }).toList();
      });
    } catch (e, stack) {
      AppLogger.e("Failed to get users stream: $e", stack);
      rethrow;
    }
  }

  Stream<QuerySnapshot> getCustomerMessages(String customerId) {
    try {
      return _firestore
          .collection('chats')
          .doc(customerId)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots();
    } catch (e, stack) {
      AppLogger.e("Failed to get customer messages: $e", stack);
      rethrow;
    }
  }

  Future<void> sendCustomerMessage(
      String customerId, String text, String senderId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(customerId)
          .collection('messages')
          .add({
        'text': text,
        'senderId': senderId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e, stack) {
      AppLogger.e("Failed to send customer message: $e", stack);
      rethrow;
    }
  }

  Stream<QuerySnapshot> getChatRooms() {
    try {
      return _firestore.collection('chats').snapshots();
    } catch (e, stack) {
      AppLogger.e("Failed to get chat rooms: $e", stack);
      rethrow;
    }
  }
}
