import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/login/login_screen.dart';
import 'package:popp/src/systemalerts/system_alerts_api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  final SystemAlertsApiServices _systemAlertsApiServices =
      SystemAlertsApiServices();

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
            future: _systemAlertsApiServices.getPriorityMessage(),
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
                  future: _systemAlertsApiServices.shouldShowMessage(message),
                  builder: (context, shownSnapshot) {
                    if (shownSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final bool shouldShow = shownSnapshot.data ?? false;
                    if (shouldShow) {
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
