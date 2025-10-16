import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_loger.dart';

import '../api/api_url.dart';
import '../utils/app_constants.dart';
import 'chat_message.dart';

// ChatService to handle both types of chats
class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userChatMemberships = 'userChatMemberships';
  final String agentChatMemberships = 'agentChatMemberships';

  // Helper function to get user data (name and email) from their profile
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection(ApiUrl.userPath).doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e, stack) {
      AppLogger.e("Failed to get user data for $userId: $e", stack);
      return null;
    }
  }

  // --- User-to-User Chat Methods ---
  Future<void> sendUserToUserMessage(String receiverId, String message,
      String productId, String productTitle) async {
    AppLogger.d("Attempting to send user-to-user message.");

    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        AppLogger.e("No current user found. Cannot send user-to-user message.");
        return;
      }

      final String currentUserId = currentUser.uid;
      final String currentUserEmail =
          currentUser.email ?? "anonymous@example.com";
      final Timestamp timestamp = Timestamp.now();

      ChatMessage newMessage = ChatMessage(
          senderId: currentUserId,
          senderEmail: currentUserEmail,
          receiverId: receiverId,
          timestamp: timestamp,
          message: message,
          productId: productId,
          productTitle: productTitle);

      List<String> ids = [currentUserId, receiverId, productId];
      ids.sort();
      String chatRoomId = ids.join("_");

      AppLogger.d(
          "Adding message to Firestore subcollection: user_chats/$chatRoomId/messages");
      await _firestore
          .collection(ApiUrl.userToUserChatPath)
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());
      AppLogger.d("Message successfully added to Firestore.");

      final Map<String, dynamic>? senderData = await getUserData(currentUserId);
      final String senderName =
          senderData?['username'] ?? 'User ${currentUserId.substring(0, 4)}...';
      final String senderEmail = senderData?['email'] ?? currentUserEmail;


      final Map<String, dynamic>? receiverData = await getUserData(receiverId);
      final String receiverName =
          receiverData?['username'] ?? 'User ${receiverId.substring(0, 4)}...';
      final String receiverEmail =
          receiverData?['email'] ?? 'anonymous@example.com';

      Map<String, dynamic> senderMembershipData = {
        'chatRoomId': chatRoomId,
        'otherUserId': receiverId,
        'otherUserName': receiverName,
        'otherUserEmail': receiverEmail,
        'lastMessageTimestamp': timestamp,
        'lastMessage': message,
        'productId': productId,
        'productTitle': productTitle,
      };
      AppLogger.d("Sender Membership Data: $senderMembershipData");

      Map<String, dynamic> receiverMembershipData = {
        'chatRoomId': chatRoomId,
        'otherUserId': currentUserId,
        'otherUserName': senderName,
        'otherUserEmail': senderEmail,
        'lastMessageTimestamp': timestamp,
        'lastMessage': message,
        'productId': productId,
        'productTitle': productTitle,
      };
      AppLogger.d("Receiver Membership Data: $receiverMembershipData");

      AppLogger.d("Updating sender's chat membership.");
      await _firestore
          .collection(ApiUrl.userPath)
          .doc(currentUserId)
          .collection(userChatMemberships)
          .doc(chatRoomId)
          .set(senderMembershipData, SetOptions(merge: true));
      AppLogger.d("Sender's chat membership updated.");

      AppLogger.d("Updating receiver's chat membership.");
      await _firestore
          .collection(ApiUrl.userPath)
          .doc(receiverId)
          .collection(userChatMemberships)
          .doc(chatRoomId)
          .set(receiverMembershipData, SetOptions(merge: true));
      AppLogger.d("Receiver's chat membership updated.");

      AppLogger.d(
          "U2U message sent and memberships updated successfully for chatRoomId: $chatRoomId");
    } catch (e, stack) {
      AppLogger.e(
          "Detailed error in sendUserToUserMessage: Failed to send U2U message. Error: $e",
          stack);
      rethrow;
    }
  }

  Stream<QuerySnapshot> getUserToUserMessages(String userId1, String userId2, String productId) {
    try {
      List<String> ids = [userId1, userId2, productId];
      ids.sort();
      String chatRoomId = ids.join("_");

      AppLogger.d("Getting U2U messages for chatRoomId: $chatRoomId");
      return _firestore
          .collection(ApiUrl.userToUserChatPath) // Dedicated collection for U2U
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
  // A single method for sending messages in agent-user threads,
  // regardless of sender (agent or user)
  Future<void> sendAgentUserMessage(
      String agentId, String userId, String message) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        AppLogger.e("No current user found. Cannot send agent-user message.");
        return;
      }

      // This will be agentId or userId
      final String currentUserId = currentUser.uid;
      final String currentUserEmail =
          currentUser.email ?? "anonymous@example.com";
      final Timestamp timestamp = Timestamp.now();

      AppLogger.d(
          "Sending A-U message from: $currentUserId (agent: $agentId, user: $userId)");
      ChatMessage newMessage = ChatMessage(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: currentUserId == agentId ? userId : agentId,
        // The actual recipient
        timestamp: timestamp,
        message: message,
        productId: '',
        productTitle: 'Support Chat',
      );

      // Chat room ID is structured as 'user_id_agent_id'
      List<String> ids = [userId, agentId];
      ids.sort(); // Sorting ensures consistency
      String chatRoomId = ids.join("_");

      // Send the actual chat message
      await _firestore
          .collection(
              ApiUrl.agentToUserChatPath) // Dedicated collection for A-U
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());

      // Get sender's details for membership record
      final Map<String, dynamic>? senderData = await getUserData(currentUserId);
      final String senderName =
          senderData?['username'] ?? 'User ${currentUserId.substring(0, 4)}...';
      final String senderEmail = senderData?['email'] ?? currentUserEmail;

      // Get receiver's details for membership record
      final String receiverUserId = currentUserId == agentId ? userId : agentId;
      final Map<String, dynamic>? receiverData =
          await getUserData(receiverUserId);
      final String receiverName = receiverData?['username'] ??
          'User ${receiverUserId.substring(0, 4)}...';
      final String receiverEmail = receiverData?['email'] ??
          (receiverUserId == Constants.adminUserId
              ? Constants.contactEmail
              : 'anonymous@example.com');

      // Data for the current sender's chat membership document
      Map<String, dynamic> senderMembershipData = {
        'chatRoomId': chatRoomId,
        'otherUserId': receiverUserId,
        'otherUserName': receiverName,
        'otherUserEmail': receiverEmail,
        'lastMessageTimestamp': timestamp,
        'lastMessage': message, // Store last message for quick display
      };

      // Data for the receiver's chat membership document
      Map<String, dynamic> receiverMembershipData = {
        'chatRoomId': chatRoomId,
        'otherUserId': currentUserId,
        'otherUserName': senderName,
        'otherUserEmail': senderEmail,
        'lastMessageTimestamp': timestamp,
        'lastMessage': message,
      };

      // Update sender's agentChatMemberships subcollection
      await _firestore
          .collection(ApiUrl.userPath)
          .doc(currentUserId)
          .collection(agentChatMemberships)
          .doc(chatRoomId)
          .set(senderMembershipData, SetOptions(merge: true));

      // Update receiver's agentChatMemberships subcollection
      await _firestore
          .collection(ApiUrl.userPath)
          .doc(receiverUserId)
          .collection(agentChatMemberships)
          .doc(chatRoomId)
          .set(receiverMembershipData, SetOptions(merge: true));

      AppLogger.d(
          "A-U message sent and memberships updated successfully: $chatRoomId");
    } catch (e, stack) {
      AppLogger.e(
          "Failed to send A-U message or update memberships: $e", stack);
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
          .collection(
              ApiUrl.agentToUserChatPath) // Dedicated collection for A-U
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
  // This will now stream from the agent's agentChatMemberships sub collection
  Stream<List<Map<String, dynamic>>> getAgentChatUserList(String agentId) {
    try {
      final currentUid = _firebaseAuth.currentUser?.uid;
      AppLogger.d("AgentChatUserList - Current UID: $currentUid");
      AppLogger.d(
          "AgentChatUserList - Agent UID Match: ${currentUid == Constants.adminUserId}");

      // Ensure the current user is the agent before querying their specific chat memberships
      if (currentUid != agentId) {
        AppLogger.w(
            "Unauthorized access attempt to getAgentChatUserList for agentId: $agentId by UID: $currentUid");
        // Return an empty stream if not authorized
        return Stream.value([]);
      }

      return _firestore
          .collection(ApiUrl.userPath) // Start from the users collection
          .doc(agentId) // Get the specific agent's document
          .collection(agentChatMemberships)
          .orderBy('lastMessageTimestamp',
              descending: true) // Order by last message to show recent chats
          .snapshots()
          .map((snapshot) {
        AppLogger.d(
            "AgentChatListScreen - Memberships snapshot doc count: ${snapshot.docs.length}");

        List<Map<String, dynamic>> userChats = [];
        for (var doc in snapshot.docs) {
          final data = doc.data();
          // 'otherUserId' is the ID of the user chatting with the agent
          // 'otherUserName' is the name of that user
          userChats.add({
            'id': data['otherUserId'],
            'name': data['otherUserName'],
            'email': data['otherUserEmail'],
            'lastMessage': data['lastMessage'],
            'productTitle': data['productTitle'],
            'productId': data['productId'],
            // Display last message if needed
            'timestamp': data['lastMessageTimestamp'],
            // For sorting or display
          });
        }
        AppLogger.d(
            "AgentChatListScreen - Final chat users list count: ${userChats.length}");
        return userChats;
      });
    } catch (e, stack) {
      AppLogger.e("Failed to get agent chat user list: $e", stack);
      rethrow;
    }
  }

  // For the agent to get a list of all users who have chatted with them
  // This will now stream from the agent's userChatMemberships sub collection
  Stream<List<Map<String, dynamic>>> getUserChatList() {
    try {
      final currentUid = _firebaseAuth.currentUser?.uid;
      if (currentUid == null) {
        return Stream.value([]);
      }

      return _firestore
          .collection(ApiUrl.userPath) // Start from the users collection
          .doc(currentUid) // Get the specific agent's document
          .collection(userChatMemberships)
          // Order by last message to show recent chats
          .orderBy('lastMessageTimestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        List<Map<String, dynamic>> userChats = [];
        for (var doc in snapshot.docs) {
          final data = doc.data();
          // 'otherUserId' is the ID of the user chatting with the agent
          // 'otherUserName' is the name of that user
          userChats.add({
            'id': data['otherUserId'],
            'name': data['otherUserName'],
            'email': data['otherUserEmail'],
            'lastMessage': data['lastMessage'],
            'productTitle': data['productTitle'],
            'productId': data['productId'],
            // Display last message if needed
            'timestamp': data['lastMessageTimestamp'],
            // For sorting or display
          });
        }
        AppLogger.d(
            "AgentChatListScreen - Final chat users list count: ${userChats.length}");
        return userChats;
      });
    } catch (e, stack) {
      AppLogger.e("Failed to get agent chat user list: $e", stack);
      rethrow;
    }
  }

  // Existing getUsersStream (for user-to-user selection) - NO CHANGE
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    try {
      return _firestore.collection(ApiUrl.userPath).snapshots().map((snapshot) {
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
