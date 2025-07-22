import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/firebase/firebase_api_service.dart';
import '../home/home_screen.dart';
import 'blocking_screen.dart';
import 'message_data.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FirebaseApiService _firebaseApiService = FirebaseApiService();

  Future<bool> _hasMessageBeenShown(String? messageId) async {
    if (messageId == null) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('shown_message_$messageId') == 'true';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a loading spinner while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in
        if (snapshot.hasData && (snapshot.data?.emailVerified ?? false)) {
          return FutureBuilder<SystemMessage?>(
            future: _firebaseApiService.getPriorityMessage(),
            builder: (context, messageSnapshot) {
              if (messageSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final message = messageSnapshot.data;

              // If there is an active message, check if it's been shown before
              if (message != null && message.isActive) {
                return FutureBuilder<bool>(
                  future: _hasMessageBeenShown(message.messageId),
                  builder: (context, shownSnapshot) {
                    if (shownSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final bool hasBeenShown = shownSnapshot.data ?? false;
                    if (!hasBeenShown) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) =>
                                BlockingScreen(systemMessage: message),
                            fullscreenDialog: true,
                          ),
                          (route) => false,
                        );
                      });
                      return const Scaffold(body: SizedBox.shrink());
                    }

                    return const HomeScreen();
                  },
                );
              }
              return const HomeScreen();
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
