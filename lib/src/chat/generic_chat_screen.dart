import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/build_extensions.dart';
import '../utils/app_loger.dart';
import 'chat_bubble.dart';
import 'chat_service.dart';

// Generic Chat Screen component
class GenericChatScreen extends StatefulWidget {
  final String receiverUserName;
  final String receiverUserID;
  final String chatType; // 'user_to_user' or 'agent_user'
  final String? agentId; // Required if chatType is 'agent_user'

  const GenericChatScreen({
    super.key,
    required this.receiverUserName,
    required this.receiverUserID,
    required this.chatType,
    this.agentId,
  }) : assert(chatType == 'user_to_user' ||
      (chatType == 'agent_user' && agentId != null));

  @override
  State<GenericChatScreen> createState() => _GenericChatScreenState();
}

class _GenericChatScreenState extends State<GenericChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Set up the message listener immediately if a user is authenticated
    if (_firebaseAuth.currentUser != null) {
      _setupMessageListener();
    } else {
      AppLogger.e("ChatScreen initialized without an authenticated user.");
      // You might want to navigate back or show an error here
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Sets up the appropriate message stream based on chatType
  void _setupMessageListener() {
    final User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      AppLogger.e("ChatScreen initialized with no authenticated user.");
      return;
    }

    Stream<QuerySnapshot> messageStream;
    if (widget.chatType == 'user_to_user') {
      messageStream = _chatService.getUserToUserMessages(
        currentUser.uid,
        widget.receiverUserID,
      );
    } else {
      // 'agent_user'
      messageStream = _chatService.getAgentUserMessages(
        widget.agentId!, // Must be provided for agent_user type
        widget.receiverUserID, // This is the user's ID in this context
      );
    }

    // Listen to the stream to automatically scroll to the bottom when new messages arrive
    messageStream.listen((snapshot) {
      if (_scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    });
  }

  void sendMessage() async {
    final User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      AppLogger.e("User not logged in. Cannot send message.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send messages.')),
      );
      return;
    }

    if (_messageController.text.trim().isNotEmpty) {
      try {
        if (widget.chatType == 'user_to_user') {
          await _chatService.sendUserToUserMessage(
            widget.receiverUserID,
            _messageController.text.trim(),
          );
        } else {
          // 'agent_user'
          // When sending an agent-user message, receiverUserID is the OTHER party's ID
          // The agentId needs to be consistent for the chat room.
          await _chatService.sendAgentUserMessage(
            widget.agentId!, // The fixed agent ID
            widget.receiverUserID,
            // The fixed user ID (even if agent is current sender)
            _messageController.text.trim(),
          );
        }
        _messageController.clear();
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } catch (e) {
        AppLogger.e("Error sending message: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check authentication status before rendering the chat UI
    if (_firebaseAuth.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not authenticated. Please log in.'),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    widget.receiverUserName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Spacer to balance the back button
              ],
            ),
          ),
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
          const SizedBox(height: 25), // Padding at the bottom
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please log in to view messages.'));
    }

    Stream<QuerySnapshot> messageStream;
    if (widget.chatType == 'user_to_user') {
      messageStream = _chatService.getUserToUserMessages(
        currentUser.uid,
        widget.receiverUserID,
      );
    } else {
      // 'agent_user'
      messageStream = _chatService.getAgentUserMessages(
        widget.agentId!,
        widget.receiverUserID, // The user's ID
      );
    }

    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          AppLogger.e("StreamBuilder error: ${snapshot.error}");
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Start a conversation!'));
        }

        return ListView(
          controller: _scrollController,
          reverse: false, // Messages are typically displayed bottom-up, so reverse is often true
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    final User? currentUser = _firebaseAuth.currentUser;

    bool isCurrentUser =
    (currentUser != null && data['senderId'] == currentUser.uid);

    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment:
        isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            data['senderEmail'] ?? 'Unknown User', // Display sender's email
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          ChatBubble(
            message: data['message'] ?? 'Empty Message',
            isCurrentUser: isCurrentUser,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Enter message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
              ),
              obscureText: false,
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: sendMessage,
            mini: true,
            backgroundColor: context.primaryColor,
            child: const Icon(Icons.send, color: Colors.white),
          )
        ],
      ),
    );
  }
}
