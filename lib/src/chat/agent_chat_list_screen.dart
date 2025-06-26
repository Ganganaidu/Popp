import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_loger.dart';

import 'chat_service.dart';
import 'generic_chat_screen.dart';
import '../utils/app_constants.dart'; // Import Constants for agentUserId

// Screen for Agent to view list of users who have chatted with them
class AgentChatListScreen extends StatefulWidget {
  // The agentId is passed from the parent to ensure this screen operates
  // for the specific agent identified by this ID.
  final String agentId;

  const AgentChatListScreen({super.key, required this.agentId});

  @override
  State<AgentChatListScreen> createState() => _AgentChatListScreenState();
}

class _AgentChatListScreenState extends State<AgentChatListScreen> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // IMPORTANT: Access control for this screen.
    // Only the actual agent (whose UID matches widget.agentId) should see this dashboard.
    // Ensure this check remains as the primary access control.
    if (_firebaseAuth.currentUser?.uid != widget.agentId) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
            child:
            Text('You are not authorized to view this page as an Agent.')),
      );
    }
    // Also, specifically check if the agentId matches the hardcoded agentUserId from Constants.
    // This provides an extra layer of verification for the "Agent Dashboard" view.
    if (widget.agentId != Constants.adminUserId) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invalid Agent ID')),
        body: const Center(
            child:
            Text('This agent dashboard is not configured for this ID.')),
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Dashboard'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // Use the agentId passed from the widget to get the list of their chats
        stream: _chatService.getAgentChatUserList(widget.agentId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            AppLogger.e(
                "AgentChatListScreen StreamBuilder error: ${snapshot.error}");
            return Center(child: Text('Error: ${snapshot.error}'));
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
                  title: Text(user['name'] ?? 'User ID: ${user['id']}'),
                  // Fallback for name
                  subtitle: Text(
                      'Email: ${user['email']}'), // Display user ID, potentially last message
                  trailing: user['lastMessage'] != null
                      ? Text(
                    user['lastMessage'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  )
                      : null,
                  onTap: () {
                    // Agent taps on a user to open chat with them
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenericChatScreen(
                          receiverUserName: user['name'] ?? 'User',
                          receiverUserID: user['id'],
                          // This is the user ID the agent is chatting with
                          chatType: 'agent_user',
                          agentId: widget.agentId, // Pass the fixed agent ID
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
