import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:intl/intl.dart'; // **NEW: For timestamp formatting**

import 'chat_service.dart';
import 'generic_chat_screen.dart';
import '../utils/app_constants.dart'; // Import Constants for agentUserId

// Screen for Agent to view list of users who have chatted with them
class ChatListScreen extends StatefulWidget {
  // The agentId is passed from the parent to ensure this screen operates
  // for the specific agent identified by this ID.
  final String agentId;

  const ChatListScreen({super.key, required this.agentId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUserId = _firebaseAuth.currentUser?.uid;
    // If current user is the agent (matches widget.agentId and Constants.adminUserId)
    final isAgent = currentUserId == widget.agentId &&
        widget.agentId == Constants.adminUserId;

    if (isAgent) {
      // Agent dashboard view
      return _agentChatListView();
    } else {
      // Non-agent: show their own chat messages
      return _userChatListView(currentUserId);
    }
  }

  Widget _agentChatListView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Dashboard'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getAgentChatUserList(widget.agentId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            AppLogger.e(
                "AgentChatListScreen StreamBuilder error: [1m${snapshot.error}[0m");
            return Center(child: Text('Error: [1m${snapshot.error}[0m'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No active agent chats.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(user['name'] ?? 'User ID: [1m${user['id']}[0m'),
                  subtitle: Text('Email: [1m${user['email']}[0m'),
                  trailing: user['lastMessage'] != null
                      ? Text(
                    user['lastMessage'],
                    style:
                    const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenericChatScreen(
                          receiverUserName: user['name'] ?? 'User',
                          receiverUserID: user['id'],
                          productId: '',
                          productTitle: 'Support Chat',
                          chatType: 'agent_user',
                          agentId: widget.agentId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // **UPDATED: User Chat List View**
  Widget _userChatListView(String? currentUserId) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getUserChatList(),
        // You must implement getUserMessages in ChatService
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            AppLogger.e("User message list error: [1m${snapshot.error}[0m");
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      // Icon related to shopping/products
                      size: 60,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Conversations Yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'It looks like you haven\'t contacted any sellers yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Explore our Products and services, '
                          'and connect with sellers for more details!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final msg = snapshot.data![index];

              // ** Format the timestamp **
              String timeDisplay = '';
              final timestamp = msg['timestamp']; // Assuming timestamp is available
              if (timestamp != null) {
                // If the timestamp is today, show time (e.g., 2:30 PM), otherwise show date (e.g., 10/25/2024)
                final DateTime messageDate = timestamp.toDate();
                final DateTime now = DateTime.now();
                final DateFormat formatter = messageDate.day == now.day &&
                    messageDate.month == now.month &&
                    messageDate.year == now.year
                    ? DateFormat.jm() // 2:30 PM
                    : DateFormat.yMd(); // 10/25/2024
                timeDisplay = formatter.format(messageDate);
              }


              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                elevation: 1, // Slight elevation for better separation
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                  // Use a leading icon or avatar placeholder
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(Icons.person, color: Theme.of(context).primaryColor),
                  ),

                  // Main content area
                  title: Row(
                    children: [
                      // Product Title (Primary focus)
                      Expanded(
                        child: Text(
                          msg['name'] ?? 'Unknown User',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Timestamp (Right aligned)
                      if (timeDisplay.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            timeDisplay,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),

                  // Subtitle shows the other user and the last message
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      // Username (Seller/Buyer)
                      Text(
                        msg['productTitle'] ?? 'General Chat',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Last Message
                      Text(
                        msg['lastMessage'] ?? 'Tap to view conversation...',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenericChatScreen(
                          receiverUserName: msg['name'] ?? 'User',
                          receiverUserID: msg['id'],
                          productId: msg['productId'] ?? '',
                          productTitle: msg['productTitle'] ?? 'Chat',
                          chatType: 'user_to_user',
                          agentId: widget.agentId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}