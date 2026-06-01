import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_loger.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    // A short delay can sometimes help prevent a jarring transition.
    // This is optional and you can adjust the duration.
    await Future.delayed(
        kIsWeb ? const Duration(milliseconds: 500) : const Duration(milliseconds: 50));

    if (mounted) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // User is logged in, go to home screen.
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // User is not logged in, go to auth screen.
          Navigator.pushReplacementNamed(context, '/auth');
        }
      } catch (e) {
        AppLogger.e('Error during authentication check: $e');
        // In case of any error, redirect to auth screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/auth');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // This widget now serves as a temporary placeholder while the logic in initState runs.
    // It will be visible for a very short time.
    // You can keep your branding here for a seamless feel.
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/app_icon_trans.png',
              width: 100.0,
              height: 100.0,
            ),
            const SizedBox(height: 16.0),
            const Text('Pre Owned Products'),
          ],
        ),
      ),
    );
  }
}
