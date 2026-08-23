import 'dart:io' show Platform;
import '../navigation/app_routes.dart';
import 'package:flutter/material.dart';
import '../api/firebase/auth_service.dart';

enum AuthType { google, apple }

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.g_mobiledata),
          label: const Text('Continue with Google'),
          style: _buttonStyle(),
          onPressed: () => _handleLogin(context, AuthType.google),
        ),
        if (Platform.isIOS) ...[
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.apple),
            label: const Text('Continue with Apple'),
            style: _buttonStyle(),
            onPressed: () => _handleLogin(context, AuthType.apple),
          ),
        ],
      ],
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      elevation: 2,
    );
  }

  Future<void> _handleLogin(BuildContext context, AuthType type) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final auth = AuthService();

      switch (type) {
        case AuthType.google:
          await auth.signInWithGoogle();
          break;
        case AuthType.apple:
          await auth.signInWithApple();
          break;
      }

      // ✅ Check if context is still valid
      if (!context.mounted) return;

      Navigator.pop(context); // Close loading dialog
      context.goHome();
    } catch (e) {
      if (!context.mounted) return;

      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
