import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:intl/intl.dart';

import 'chat_service.dart';
import 'generic_chat_screen.dart';
import '../utils/app_constants.dart';

// Screen for Agent to view list of users who have chatted with them
class ChatListScreen extends StatefulWidget {
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
    final isAgent = currentUserId == widget.agentId &&
        widget.agentId == Constants.adminUserId;

    if (isAgent) {
      return _agentChatListView();
    } else {
      return _userChatListView(currentUserId);
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    final DateTime msgDate = timestamp.toDate();
    final DateTime now = DateTime.now();
    final bool isToday = msgDate.year == now.year &&
        msgDate.month == now.month &&
        msgDate.day == now.day;
    return isToday
        ? DateFormat.jm().format(msgDate)
        : DateFormat('dd/MM/yy').format(msgDate);
  }

  Widget _buildChatTile({
    required BuildContext context,
    required String name,
    required String? productTitle,
    required String? lastMessage,
    required String timeDisplay,
    required int unreadCount,
    required VoidCallback onTap,
  }) {
    final hasProduct =
        productTitle != null && productTitle.isNotEmpty;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        backgroundColor:
            Theme.of(context).primaryColor.withOpacity(0.12),
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: unreadCount > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (timeDisplay.isNotEmpty)
            Text(
              timeDisplay,
              style: TextStyle(
                fontSize: 12,
                color: unreadCount > 0
                    ? Theme.of(context).primaryColor
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                fontWeight:
                    unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasProduct)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 1),
              child: Text(
                productTitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Text(
                  lastMessage ?? 'Tap to view conversation…',
                  style: TextStyle(
                    fontSize: 13,
                    color: unreadCount > 0
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.55),
                    fontWeight: unreadCount > 0
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unreadCount > 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _agentChatListView() {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
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

          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              final name = user['name'] as String? ??
                  user['id'] as String? ??
                  'Unknown';
              final productTitle = user['productTitle'] as String?;
              final unreadCount = (user['unreadCount'] ?? 0) as int;

              return _buildChatTile(
                context: context,
                name: name,
                productTitle: productTitle,
                lastMessage: user['lastMessage'] as String?,
                timeDisplay: _formatTimestamp(user['timestamp']),
                unreadCount: unreadCount,
                onTap: () {
                  final userId = user['id'] as String?;
                  if (userId == null || userId.isEmpty) return;
                  final chatType =
                      user['chatType'] as String? ?? 'agent_user';
                  final isAgentChat = chatType == 'agent_user';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GenericChatScreen(
                        receiverUserName: name,
                        receiverUserID: userId,
                        productId: isAgentChat
                            ? ''
                            : (user['productId'] as String? ?? ''),
                        productTitle: isAgentChat
                            ? 'Support Chat'
                            : (productTitle ?? 'Chat'),
                        chatType: chatType,
                        agentId: isAgentChat ? widget.agentId : null,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _userChatListView(String? currentUserId) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getUserChatList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            AppLogger.e("User message list error: ${snapshot.error}");
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
                    Icon(
                      Icons.storefront_outlined,
                      size: 60,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.4),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Conversations Yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'It looks like you haven\'t contacted any sellers yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6)),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Explore our Products and services, '
                      'and connect with sellers for more details!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final msg = snapshot.data![index];
              final name = msg['name'] as String? ?? 'Unknown User';
              final productTitle = msg['productTitle'] as String?;
              final unreadCount = (msg['unreadCount'] ?? 0) as int;

              return _buildChatTile(
                context: context,
                name: name,
                productTitle: productTitle,
                lastMessage: msg['lastMessage'] as String?,
                timeDisplay: _formatTimestamp(msg['timestamp']),
                unreadCount: unreadCount,
                onTap: () {
                  final userId = msg['id'] as String?;
                  if (userId == null || userId.isEmpty) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GenericChatScreen(
                        receiverUserName: name,
                        receiverUserID: userId,
                        productId: msg['productId'] as String? ?? '',
                        productTitle: productTitle ?? 'Chat',
                        chatType: 'user_to_user',
                        agentId: widget.agentId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
