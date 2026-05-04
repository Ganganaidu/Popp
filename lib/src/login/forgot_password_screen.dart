import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/toolbar/common_app_bar.dart';
import 'package:popp/src/api/api_url.dart';
import 'package:popp/src/widgets/title_text.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final bool isChangePassword;

  const ForgotPasswordScreen({super.key, required this.isChangePassword});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final email = _emailController.text.trim();

      // ActionCodeSettings are needed to redirect the user back to the app
      // after they reset their password from the link in the email.
      var acs = ActionCodeSettings(
          url: ApiUrl.baseUrl,
          handleCodeInApp: true,
          iOSBundleId: 'com.popp.abike',
          androidPackageName: 'com.popp.abike',
          androidInstallApp: true,
          androidMinimumVersion: '12');

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: email,
          actionCodeSettings: acs, // Pass the settings here
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('A password reset link has been sent to $email')),
        );
        // Optionally, navigate the user away from this screen
        // Navigator.of(context).pop();
      } on FirebaseAuthException catch (e) {
        String message;
        switch (e.code) {
          case 'user-not-found':
            message = 'No user found with this email.';
            break;
          case 'invalid-email':
            message = 'The email address is not valid.';
            break;
          default:
            message = 'Something went wrong. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        titleWidget: TitleText(
            widget.isChangePassword ? "Change Password" : ""),
      ),
      body: SafeArea(
        child: Center( // Added Center widget
          child: ConstrainedBox( // Added ConstrainedBox to limit width
            constraints: const BoxConstraints(maxWidth: 600), // Max width for web
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // To make the Column take minimum vertical space
                  children: [
                    Text(
                      widget.isChangePassword
                          ? "Reset Password"
                          : "Forgot your password?",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Enter your registered email address to receive a password reset link.",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email Address",
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        final emailRegex =
                            RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _sendResetLink,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "Send Reset Link",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
