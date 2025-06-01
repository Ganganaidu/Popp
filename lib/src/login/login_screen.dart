import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../navigation/nav_router.dart';
import '../utils/app_utils.dart';
import 'social_login_buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool rememberMe = false;
  bool isPasswordVisible = false;

  // Control visibility of social login
  bool showSocialLogin = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // Stick skip button to bottom
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    ScaleTransition(scale: _animation, child: _buildLogo()),
                    const SizedBox(height: 40),
                    _buildEmailPasswordFields(),
                    _buildRememberForgot(),
                    const SizedBox(height: 20),
                    _buildLoginButton(),
                    const SizedBox(height: 30),
                    if (showSocialLogin) _buildOrDivider(),
                    if (showSocialLogin) const SizedBox(height: 30),
                    if (showSocialLogin) const SocialLoginButtons(),
                    const SizedBox(height: 40),
                    _buildSignupLink(),
                  ],
                ),
              ),
            ),
            _buildSkipButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return const Column(
      children: [
        Text("POPP",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text("Pre Owned Products", style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildEmailPasswordFields() {
    return SizedBox(
      width: 360,
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Email",
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              hintText: "Password",
              filled: true,
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRememberForgot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Checkbox(
                value: rememberMe,
                onChanged: (value) {
                  setState(() {
                    rememberMe = value ?? false;
                  });
                },
                activeColor: Colors.orange,
              ),
              const Text('Remember me'),
            ],
          ),
          TextButton(
            onPressed: () {
              onForgotPasswordTap(context);
            },
            child: const Text('Forgot Password?',
                style: TextStyle(color: Colors.white70)),
          )
        ],
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "Or login with",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        const Expanded(child: Divider(thickness: 1)),
      ],
    );
  }

  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/signup');
          },
          child: const Text(
            "Sign Up now",
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/home');
      },
      child: const Text(
        "Skip for now",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: 360,
      child: ElevatedButton(
        onPressed: () async {
          final email = _emailController.text.trim();
          final password = _passwordController.text;

          if (!AppUtils.isEmailValid(email)) {
            _showError("Please enter a valid email address.");
            return;
          }
          if (password.isEmpty) {
            _showError("Password cannot be empty.");
            return;
          }

          try {
            await FirebaseAuth.instance
                .signInWithEmailAndPassword(email: email, password: password);
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, '/home');
          } on FirebaseAuthException catch (e) {
            _showError(e.message ?? "Authentication failed");
          } catch (e) {
            _showError("Something went wrong. Please try again.");
          }
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Sign In',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
