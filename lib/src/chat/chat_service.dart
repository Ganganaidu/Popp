import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_loger.dart';

import '../utils/app_constants.dart';
import 'chat_message.dart';

// MODIFIED ChatService to handle both types of chats
class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- User-to-User Chat Methods ---
  Future<void> sendUserToUserMessage(String receiverId, String message) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        AppLogger.e("No current user found. Cannot send user-to-user message.");
        return;
      }

      final String currentUserId = currentUser.uid;
      final String currentUserEmail = currentUser.email ?? "anonymous@example.com";
      final Timestamp timestamp = Timestamp.now();

      AppLogger.d("Sending U2U from: $currentUserId to: $receiverId");
      ChatMessage newMessage = ChatMessage(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId, // The other user's ID
        timestamp: timestamp,
        message: message,
      );

      List<String> ids = [currentUserId, receiverId];
      ids.sort();
      String chatRoomId = ids.join("_"); // Unique ID for user-to-user chat

      await _firestore
          .collection(Constants.userToUserChatPath) // Dedicated collection for U2U
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap())
          .then((value) {
        AppLogger.d("U2U message sent successfully: ${value.id}");
      })
          .catchError((error, stack) {
        AppLogger.e("Failed to send U2U message: $error", stack);
      });
    } catch (e, stack) {
      AppLogger.e("Failed to send U2U message: $e", stack);
      rethrow;
    }
  }

  Stream<QuerySnapshot> getUserToUserMessages(String userId1, String userId2) {
    try {
      List<String> ids = [userId1, userId2];
      ids.sort();
      String chatRoomId = ids.join("_");

      AppLogger.d("Getting U2U messages for chatRoomId: $chatRoomId");
      return _firestore
          .collection(Constants.userToUserChatPath) // Dedicated collection for U2U
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots();
    } catch (e, stack) {
      AppLogger.e("Failed to get U2U messages: $e", stack);
      rethrow;
    }
  }

  // --- Agent-User Chat Methods ---
  // A single method for sending messages in agent-user threads, regardless of sender (agent or user)
  Future<void> sendAgentUserMessage(
      String agentId, String userId, String message) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        AppLogger.e("No current user found. Cannot send agent-user message.");
        return;
      }

      final String currentUserId = currentUser.uid; // This will be agentId or userId
      final String currentUserEmail = currentUser.email ?? "anonymous@example.com";
      final Timestamp timestamp = Timestamp.now();

      AppLogger.d("Sending A-U message from: $currentUserId (agent: $agentId, user: $userId)");
      ChatMessage newMessage = ChatMessage(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: currentUserId == agentId ? userId : agentId, // The actual recipient
        timestamp: timestamp,
        message: message,
      );

      // Chat room ID is structured as 'user_id_agent_id'
      List<String> ids = [userId, agentId];
      ids.sort(); // Sorting ensures consistency
      String chatRoomId = ids.join("_");

      await _firestore
          .collection(Constants.agentToUserChatPath) // Dedicated collection for A-U
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap())
          .then((value) {
        AppLogger.d("A-U message sent successfully: ${value.id}");
      })
          .catchError((error, stack) {
        AppLogger.e("Failed to send A-U message: $error", stack);
      });
    } catch (e, stack) {
      AppLogger.e("Failed to send A-U message: $e", stack);
      rethrow;
    }
  }

  // For a specific user or agent to get messages for their chat with the other
  Stream<QuerySnapshot> getAgentUserMessages(String agentId, String userId) {
    try {
      List<String> ids = [userId, agentId];
      ids.sort();
      String chatRoomId = ids.join("_");

      AppLogger.d("Getting A-U messages for chatRoomId: $chatRoomId");
      return _firestore
          .collection(Constants.agentToUserChatPath) // Dedicated collection for A-U
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots();
    } catch (e, stack) {
      AppLogger.e("Failed to get A-U messages: $e", stack);
      rethrow;
    }
  }

  // For the agent to get a list of all users who have chatted with them
  // This will show distinct "chat rooms" from the agent's perspective
  Stream<List<Map<String, dynamic>>> getAgentChatUserList(String agentId) {
    try {
      AppLogger.d("Processing chat room: $agentId");
      // Listen to the 'agent_user_chats' collection to find all documents
      // where this agent is involved. Firestore security rules might need to be
      // set up carefully for this to work efficiently on a larger scale.
      // For demonstration, we'll just query the parent collection.
      // A more robust solution might involve a separate 'agent_conversations'
      // document per agent with a list of user IDs.
      return _firestore
          .collection(Constants.agentToUserChatPath)
          .snapshots()
          .map((snapshot) {
        List<Map<String, dynamic>> userChats = [];
        AppLogger.d("Processing chat room: ${snapshot.docs}");
        for (var doc in snapshot.docs) {
          // Extract the two UIDs from the chatRoomId
          List<String> ids = doc.id.split('_').toList();
          AppLogger.d("Processing chat room: ${doc.id} with IDs: $ids");
          if (ids.length == 2 && (ids.contains(agentId))) {
            String otherUserId = ids.firstWhere((id) => id != agentId);

            AppLogger.d("Processing chat room: $otherUserId");
            // In a real app, you'd fetch user details (name, email) from a 'users' collection
            // For this demo, we'll just use the ID and a generic name.
            userChats.add({
              'id': otherUserId,
              'name': 'User ${otherUserId.substring(0, 4)}...',
            });
          }
        }
        return userChats;
      });
    } catch (e, stack) {
      AppLogger.e("Failed to get agent chat user list: $e", stack);
      rethrow;
    }
  }

  // Fetch all products (e.g., for a public catalog)
  Future<List<Map<String, dynamic>>> getChats() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(Constants.agentToUserChatPath)
          .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      // AppLogger.d("Error fetching all products: $e");
      AppLogger.d("Error fetching all products: $e");
      return [];
    }
  }

  // Existing getUsersStream (for user-to-user selection)
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    try {
      return _firestore.collection(Constants.userPath).snapshots().map((snapshot) {
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
}
