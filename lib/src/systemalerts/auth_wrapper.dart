import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:popp/src/login/login_screen.dart';
import 'package:popp/src/screens/intro_page.dart';
import 'package:popp/src/screens/intro_screen.dart';
import 'package:popp/src/systemalerts/system_alerts_api_services.dart';
import 'package:popp/src/utils/app_constants.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/home_screen.dart';
import '../utils/app_loger.dart';
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
  bool? _hasSeenIntro;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _hasSeenIntro = true; // Skip intro on web
    } else {
     _checkIntroSeen();
    }
  }

  Future<void> _checkIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('hasSeenIntro') ?? false;
    if (!seen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const IntroScreen()),
        );
      });
    } else {
      setState(() {
        _hasSeenIntro = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeenIntro == null) {
      // Waiting for pref check
      return _buildLoadingScreen();
    }
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        AppLogger.d('is webview to display: $kIsWeb');
        // Skip login on web
        if (kIsWeb) {
          return const HomeScreen();
        }

        // Show a loading spinner while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        // If user is logged in
        if (snapshot.hasData && (snapshot.data?.emailVerified ?? false)) {
          return FutureBuilder<SystemMessage?>(
            future: _systemAlertsApiServices.getPriorityMessage(),
            builder: (context, messageSnapshot) {
              if (messageSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingIntroScreen();
              }

              final message = messageSnapshot.data;

              // If there is an active message, check if it's been shown before
              if (message != null && message.isActive) {
                return FutureBuilder<bool>(
                  future: _systemAlertsApiServices.shouldShowMessage(message),
                  builder: (context, shownSnapshot) {
                    if (shownSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildLoadingIntroScreen();
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

Widget _buildLoadingScreen() {
  return const Scaffold(body: Center(child: CircularProgressIndicator()));
}

Widget _buildLoadingIntroScreen() {
  return Scaffold(
    body: Center(
      child: Stack(
        children: [
          // 1. The main welcome content (IntroPage)
          const IntroPage(
            image: 'assets/app_icon_trans.png',
            title: 'Welcome to ${Constants.appName}',
            description:
                'Gear up! We\'re loading your personalized dashboard now.',
          ),

          // 2. Interactive and stylized loader
          Positioned(
            top: 80,
            bottom: 10,
            right: 20,
            left: 20,
            child: SpinKitPulsingGrid(
              // A nice, animated, non-boring loader
              color: Colors.green.withOpacity(0.8),
              size: 80.0,
            ),
          ),

          Positioned(
            right: 20,
            top: 100,
            bottom: 100,
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                'BIKERVERSE',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
