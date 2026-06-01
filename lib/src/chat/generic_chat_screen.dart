import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/toolbar/common_app_bar.dart';
import 'package:popp/src/utils/build_extensions.dart';
import '../utils/app_loger.dart';
import 'active_chat_provider.dart';
import 'chat_bubble.dart';
import 'chat_service.dart';

// Generic Chat Screen component
class GenericChatScreen extends StatefulWidget {
  final String receiverUserName;
  final String receiverUserID;
  final String productId;
  final String productTitle;
  final String chatType; // 'user_to_user' or 'agent_user'
  final String? agentId; // Required if chatType is 'agent_user'

  const GenericChatScreen({
    super.key,
    required this.receiverUserName,
    required this.receiverUserID,
    required this.chatType,
    required this.productId,
    required this.productTitle,
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
  late String _currentChatRoomId;

  @override
  void initState() {
    super.initState();
    _determineChatRoomId();
    // Set up the message listener immediately if a user is authenticated
    if (_firebaseAuth.currentUser != null) {
      _setupMessageListener();
    } else {
      AppLogger.e("ChatScreen initialized without an authenticated user.");
      // You might want to navigate back or show an error here
    }

    // Set active chat room for notifications
    ActiveChatProvider.setActiveChat(_currentChatRoomId);
  }

  void _determineChatRoomId() {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      _currentChatRoomId = '';
      return;
    }

    if (widget.chatType == 'user_to_user') {
      List<String> ids = [
        currentUser.uid,
        widget.receiverUserID,
        widget.productId
      ];
      ids.sort();
      _currentChatRoomId = ids.join("_");
    } else {
      List<String> ids = [widget.receiverUserID, widget.agentId!];
      ids.sort();
      _currentChatRoomId = ids.join("_");
    }
  }

  @override
  void dispose() {
    ActiveChatProvider.clearActiveChat();
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
          currentUser.uid, widget.receiverUserID, widget.productId);
    } else {
      // 'agent_user'
      messageStream = _chatService.getAgentUserMessages(
        widget.agentId!, // Must be provided for agent_user type
        widget.receiverUserID, // This is the user's ID in this context
      );
    }

    // Listen to the stream to automatically scroll to the bottom when new messages arrive
    messageStream.listen((snapshot) {
      String otherUserId = widget.receiverUserID;
      if (widget.chatType == 'agent_user') {
        // If current user is the agent, other user is receiverUserID.
        // If current user is the regular user, other user is agentId.
        if (currentUser.uid == widget.agentId) {
          otherUserId = widget.receiverUserID;
        } else {
          otherUserId = widget.agentId!;
        }
      }

      _chatService.markChatAsRead(
        currentUser.uid,
        otherUserId,
        productId: widget.productId,
        chatType: widget.chatType,
      );

      if (_scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            0.0,
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send messages.')),
      );
      return;
    }

    if (_messageController.text.trim().isNotEmpty) {
      final message = _messageController.text.trim();

      // Clear the text field immediately for a snappy UX
      _messageController.clear();
      AppLogger.d("Message controller cleared instantly.");
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      try {
        if (widget.chatType == 'user_to_user') {
          // Do not await, let it run in the background
          _chatService
              .sendUserToUserMessage(
            widget.receiverUserID,
            message,
            widget.productId,
            widget.productTitle,
          )
              .catchError((e) {
            AppLogger.e("Background error sending U2U message: $e");
            // Optional: Provide offline/retry feedback here if it fails critically
          });
          AppLogger.d("Dispatched user-to-user message.");
        } else {
          // 'agent_user'
          _chatService
              .sendAgentUserMessage(
            widget.agentId!, // The fixed agent ID
            widget.receiverUserID,
            // The fixed user ID (even if agent is current sender)
            message,
          )
              .catchError((e) {
            AppLogger.e("Background error sending Agent message: $e");
          });
          AppLogger.d("Dispatched agent-user message.");
        }
      } catch (e, stack) {
        AppLogger.e("Error dispatching message: $e", stack);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: ${e.toString()}')),
        );
      }
    } else {
      AppLogger.w("Attempted to send an empty message.");
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
    final title = widget.productTitle.isNotEmpty
        ? widget.productTitle
        : widget.receiverUserName;
    return Scaffold(
      appBar: CommonAppBar(
        titleWidget: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 2,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
          const SizedBox(height: 35), // Padding at the bottom
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
          currentUser.uid, widget.receiverUserID, widget.productId);
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
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          children: snapshot.data!.docs.reversed
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
                    horizontal: 20.0, vertical: 20.0),
              ),
              obscureText: false,
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: sendMessage,
            backgroundColor: context.primaryColor,
            child: const Icon(Icons.send, color: Colors.white),
          )
        ],
      ),
    );
  }
}
