import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_constants.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../navigation/nav_router.dart';
import '../widgets/app_dialogs.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    bool isAdmin = userId == Constants.agentUserId;

    AppLogger.d("current user Id is: $userId");
    AppLogger.d("agentUserId Id is: ${Constants.agentUserId}");

    return ListView(
      children: [
        const SizedBox(height: 32),
        const Center(
          child: Text(
            "How can we help you?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 32),

        if (isAdmin)
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('Chat user list'),
            onTap: () {
              onAgentChatTap(context);
            },
          )
        else
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('Chat with us'),
            onTap: () {
              if (FirebaseAuth.instance.currentUser == null) {
                AppDialogs.showUserLoginDialog(context, () {
                  Navigator.pushReplacementNamed(context, '/login');
                }, "Chat with us");
                return;
              } else {
                onAgentToUserChatTap(context, Constants.agentUserId,
                    FirebaseAuth.instance.currentUser?.uid ?? '');
              }
            },
          ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.call_outlined),
          title: const Text('Call us'),
          onTap: () {
            launchUrl(Uri(scheme: 'tel', path: Constants.contactNumber));
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.email_outlined),
          title: const Text('Email us'),
          onTap: () {
            launchUrl(Uri(scheme: 'mailto', path: Constants.contactEmail));
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          onTap: () async {
            launchUrl(Uri.parse(Constants.privacyLink));
          },
        ),
      ],
    );
  }
}
