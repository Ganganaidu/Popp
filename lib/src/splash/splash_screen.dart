import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // The native splash screen is showing. We just need to handle the navigation logic.
    // We don't need a Future.delayed here anymore.
    // The logic will run, and once it's done, we'll navigate away.
    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    // A short delay can sometimes help prevent a jarring transition.
    // This is optional and you can adjust the duration.
    await Future.delayed(const Duration(milliseconds: 50));

    if (mounted) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // User is logged in, go to home screen.
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // User is not logged in, go to login screen.
        Navigator.pushReplacementNamed(context, '/login');
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
              'assets/app_icon.png',
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
