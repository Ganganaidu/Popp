import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/app_loger.dart';
import 'chat_bubble.dart';
import 'chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverUserName;
  final String receiverUserID;

  const ChatScreen({
    super.key,
    required this.receiverUserName,
    required this.receiverUserID,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Added for auto-scrolling to the latest message
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Listen for messages and scroll to the bottom when new ones arrive
    // This is a common pattern for chat applications.
    _chatService.getMessages(
      _firebaseAuth.currentUser!.uid,
      widget.receiverUserID,
    ).listen((snapshot) {
      // Ensure the scroll controller is attached and we are not at the very top
      if (_scrollController.hasClients) {
        // Delay scrolling slightly to allow UI to build
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    // Check if current user is logged in
    final User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      AppLogger.e("User not logged in. Cannot send message.");
      // Optionally show a user-friendly message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send messages.')),
      );
      return;
    }

    AppLogger.d("Attempting to send message: ${_messageController.text}");
    AppLogger.d("To receiverUserID: ${widget.receiverUserID}");

    if (_messageController.text.trim().isNotEmpty) {
      try {
        // FIX: Use widget.receiverUserID instead of a hardcoded ID
        await _chatService.sendMessage(
            widget.receiverUserID, _messageController.text.trim());
        _messageController.clear(); // Clear the text controller after sending
        // Auto-scroll to bottom after sending
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
    // Ensure current user is available before building the UI
    if (_firebaseAuth.currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('User not authenticated. Please log in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverUserName)),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _buildMessageList(),
          ),
          // User input
          _buildMessageInput(),
          const SizedBox(height: 25), // Padding at the bottom
        ],
      ),
    );
  }

  // Build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        // FIX: Ensure both current user's UID and receiver's UID are passed correctly.
        // The order here doesn't strictly matter because ChatService sorts them,
        // but explicitly passing both is key.
          _firebaseAuth.currentUser!.uid, // Current authenticated user's ID
          widget.receiverUserID // The ID of the user this chat screen is with
      ),
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
        AppLogger.e("StreamBuilder error: ${snapshot.error}");
        return ListView(
          controller: _scrollController, // Attach the scroll controller
          reverse: false, // Display messages from top to bottom (oldest to newest)
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  // Build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // Determine if the message was sent by the current user
    bool isCurrentUser = data['senderId'] == _firebaseAuth.currentUser!.uid;

    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4), // Add some vertical spacing between messages
      child: Column(
        crossAxisAlignment:
        isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            data['senderEmail'],
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          ChatBubble(
            message: data['message'],
            isCurrentUser: isCurrentUser, // Pass this to ChatBubble for styling
          ),
        ],
      ),
    );
  }

  // Build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0), // Adjusted padding
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Enter message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0), // More rounded corners
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200], // Lighter grey for input background
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              ),
              obscureText: false,
              maxLines: null, // Allow multiline input
              keyboardType: TextInputType.multiline,
            ),
          ),
          const SizedBox(width: 8), // Spacing between text field and button
          FloatingActionButton(
            onPressed: sendMessage,
            mini: true, // Make button smaller
            backgroundColor: Colors.orange,
            child: const Icon(Icons.send, color: Colors.white),
          )
        ],
      ),
    );
  }
}