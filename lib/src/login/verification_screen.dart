import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/toolbar/common_app_bar.dart';
import 'package:popp/src/login/model/user_data_model.dart';
import 'package:popp/src/navigation/nav_router.dart';
import 'package:popp/src/widgets/title_text.dart';

import '../utils/app_loger.dart';

class VerificationScreen extends StatefulWidget {
  final UserData? userData;
  final String email;
  final String password;
  final bool isFromSignUp;

  const VerificationScreen({
    super.key,
    this.userData,
    required this.email,
    required this.password,
    required this.isFromSignUp,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  Timer? _verificationTimer;
  int _resendCooldown = 60;
  Timer? _resendTimer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
    _startResendTimer();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    _verificationTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      // Every 3 seconds, reload the user's data from Firebase
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      // If the email is verified, finalize the account and navigate
      if (user?.emailVerified ?? false) {
        timer.cancel();
        if (mounted) {
          await _finalizeAccountSetup();
        }
      }
    });
  }

  Future<void> _finalizeAccountSetup() async {
    try {
      // Sign in again to ensure the auth state is current
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.userData?.email ?? widget.email,
        password: widget.password,
      );
      if (mounted) {
        if (widget.isFromSignUp) {
          onRegisterAndSubscribeTap(context, widget.userData!);
        } else {
          // If not from sign up, just navigate to home
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      AppLogger.e("Error finalizing account: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }

  void _startResendTimer() {
    setState(() => _isResending = true);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown == 0) {
        setState(() => _isResending = false);
        timer.cancel();
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _resendLink() async {
    if (_isResending) return;
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification link resent.')),
        );
        setState(() => _resendCooldown = 60);
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend link: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        titleWidget: TitleText('Verify Your Email'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              Text(
                'Check Your Inbox',
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
                widget.userData?.email ?? widget.email,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  const Text(
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                    'Click the link in the email to complete your registration. This screen will update automatically.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                      ),
                      children: [
                        TextSpan(
                            text:
                                'If you haven\'t received the email, please check your '),
                        TextSpan(
                          text: 'spam/junk',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' folder.'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
              const SizedBox(height: 32),
              TextButton(
                onPressed: _resendLink,
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
