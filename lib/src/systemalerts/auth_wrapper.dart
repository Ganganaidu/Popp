import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/login/login_screen.dart';

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

              // If there is an active message, show the blocking/info screen
              if (message != null && message.isActive) {
                // Use a post-frame callback to ensure the build is complete
                // before trying to show a dialog or navigate.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => BlockingScreen(systemMessage: message),
                      fullscreenDialog: true,
                    ),
                        (route) => false, // Remove all previous routes
                  );
                });
                // Return a temporary empty container while the navigation happens.
                return const Scaffold(body: SizedBox.shrink());
              }
              return const HomeScreen();
            },
          );
        }

        // If user is not logged in, show the login screen
        return const LoginScreen();
      },
    );
  }
}
