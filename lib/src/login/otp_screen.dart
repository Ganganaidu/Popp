import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:popp/src/login/sign_up_congrats_screen.dart';
import 'package:popp/src/utils/app_loger.dart';

class OTPScreen extends StatefulWidget {
  final String email;

  // We need to pass the password from the sign-up screen to complete the sign-in process
  // after the email link is clicked. This is a security measure by Firebase.
  final String password;

  const OTPScreen({super.key, required this.email, required this.password});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  bool _isResending = false;
  int _resendCooldown = 60;
  Timer? _resendTimer;
  Timer? _verificationTimer;

  @override
  void initState() {
    super.initState();
    _sendVerificationLink();
    // Start a timer to periodically check if the email has been verified
    _verificationTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      // Reload the user to get the latest email verification status
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user?.emailVerified ?? false) {
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email Verified Successfully!')),
        );
        // After verification, sign the user in to persist the session
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
          );
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const SignUpCongratsScreen()));
        } on FirebaseAuthException catch (e) {
          AppLogger.w('Failed to sign in: ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to sign in: ${e.message}')),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _verificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationLink() async {
    final user = FirebaseAuth.instance.currentUser;

    // ActionCodeSettings are required to tell Firebase how to construct the email link.
    // It needs a URL to redirect back to. For mobile, this is handled via dynamic links,
    var acs = ActionCodeSettings(
        url: 'https://popp-71efb.web.app',
        handleCodeInApp: true,
        iOSBundleId: 'com.popp.abike',
        androidPackageName: 'com.popp.abike',
        androidInstallApp: true,
        androidMinimumVersion: '12');

    try {
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification(acs);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'A verification link has been sent to ${widget.email}.')),
        );
        _startResendTimer();
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.w('Failed to sign in: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to send verification link: ${e.message}')),
      );
    }
  }

  void _startResendTimer() {
    setState(() {
      _isResending = true;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown == 0) {
        setState(() {
          _isResending = false;
        });
        timer.cancel();
      } else {
        setState(() {
          _resendCooldown--;
        });
      }
    });
  }

  void _resendLink() {
    if (!_isResending) {
      _sendVerificationLink();
      setState(() {
        _resendCooldown = 60;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              Text(
                'Verify your email',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'A verification link has been sent to:',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'Please click the link to continue. This window will update automatically.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
              const SizedBox(height: 32),
              TextButton(
                onPressed: _isResending ? null : _resendLink,
                child: Text(
                  _isResending
                      ? 'Resend link in $_resendCooldown s'
                      : 'Resend verification link',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
