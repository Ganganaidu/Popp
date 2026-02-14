import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:provider/provider.dart';

import '../api/firebase/remote_config_service.dart';
import '../navigation/nav_router.dart';
import '../subscription/subscription_provider.dart';
import '../widgets/app_dialogs.dart';

class ChatWithSellerCard extends StatefulWidget {
  final String receiverUserName;
  final String receiverUserID;
  final String productId;
  final String productTitle;
  final bool isOwner;

  const ChatWithSellerCard(
      {super.key,
      required this.receiverUserName,
      required this.receiverUserID,
      required this.productId,
      required this.productTitle,
      this.isOwner = false});

  @override
  State<ChatWithSellerCard> createState() => _ChatWithSellerCardState();
}

class _ChatWithSellerCardState extends State<ChatWithSellerCard> {
  bool _showSubscription = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  void _loadConfig() async {
    final configService = await RemoteConfigService.getInstance();
    setState(() {
      _showSubscription = configService.isSubscriptionFeatureEnabled;
    });
  }

  void _openChatWithSeller(BuildContext context) async {
    onUserToUserChatTap(context, widget.receiverUserName, widget.receiverUserID,
        widget.productId, widget.productTitle);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isSubscribed = context.watch<SubscriptionProvider>().isSubscribed;
    final canChat = user != null && isSubscribed;
    final isSelfChat = widget.receiverUserID == user?.uid;
    final bool chatEnabled = !_showSubscription || (canChat && !isSelfChat);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: context.primaryColor,
              child: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.receiverUserName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  isSelfChat
                      ? const Text("Owner",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16))
                      : Text(
                          widget.isOwner
                              ? "Chat with Seller"
                              : "Chat with Provider",
                          style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            if (!isSelfChat)
              ElevatedButton.icon(
                onPressed: chatEnabled
                    ? () => _openChatWithSeller(context)
                    : () {
                        String message;
                        if (user == null) {
                          message = 'Please login to use chat.';
                        } else {
                          message =
                              'Chat feature is available for subscribed users only. Please upgrade your plan to start chatting';
                        }
                        final confirmText =
                            user == null ? 'Login' : 'Subscribe';
                        AppDialogs.showConfirmationDialog(
                            context: context,
                            title: 'Chat Unavailable',
                            content: message,
                            confirmText: confirmText,
                            onConfirm: () {
                              if (user == null) {
                                onLoginTap(context);
                              } else {
                                onSettingsTap(context);
                              }
                            });
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
