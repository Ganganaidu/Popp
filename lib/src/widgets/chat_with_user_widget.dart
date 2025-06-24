import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/nav_router.dart';
import '../subscription/subscription_provider.dart';

class ChatWithSellerCard extends StatelessWidget {
  final String receiverUserName;
  final String receiverUserID;

  const ChatWithSellerCard({
    super.key,
    required this.receiverUserName,
    required this.receiverUserID,
  });

  void _openChatWithSeller(BuildContext context) async {
    onUserToUserChatTap(context, receiverUserName, receiverUserID);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isSubscribed = context.watch<SubscriptionProvider>().isSubscribed;
    final canChat = user != null && isSubscribed;
    final isSelfChat = receiverUserID == user?.uid;
    final bool chatEnabled = canChat && !isSelfChat;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(receiverUserName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text("Chat with Provider",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: chatEnabled
                  ? () => _openChatWithSeller(context)
                  : () {
                      String message;
                      if (isSelfChat) {
                        message = 'You cannot chat with yourself.';
                      } else {
                        message = user == null
                            ? 'Please login to use chat.'
                            : 'Please subscribe to use chat.';
                      }
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Chat Unavailable'),
                          content: Text(message),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
              icon: const Icon(Icons.messenger_rounded),
              label: const Text("Chat"),
              style: ElevatedButton.styleFrom(
                backgroundColor: chatEnabled ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
