import 'package:flutter/material.dart';
import 'package:poppflutter/src/utils/build_extensions.dart';
import 'dart:io' show Platform;
import 'social_login_buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool rememberMe = false;
  bool isPasswordVisible = false; // <-- For Show/Hide Password

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
      resizeToAvoidBottomInset: false, // <-- Important to fix skip movement
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  ScaleTransition(
                    scale: _animation,
                    child: _buildLogo(),
                  ),
                  const SizedBox(height: 40),
                  _buildEmailPasswordFields(),
                  _buildRememberForgot(),
                  const SizedBox(height: 20),
                  _buildLoginButton(),
                  const SizedBox(height: 30),
                  _buildOrDivider(),
                  const SizedBox(height: 30),
                  const SocialLoginButtons(),
                  const SizedBox(height: 40),
                  _buildSignupLink(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: _buildSkipButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return const Column(
      children: [
        Text(
          "POPP",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          "Pre Owned Products",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildEmailPasswordFields() {
    return Center(
      child: SizedBox(
        width: 360,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Email",
                filled: true,
                fillColor: context.primary.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: !isPasswordVisible, // <-- use toggle
              decoration: InputDecoration(
                hintText: "Password",
                filled: true,
                fillColor: context.primary.withOpacity(0.1),
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
            onPressed: () {},
            child: const Text('Forgot Password?'),
          )
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Center(
      child: SizedBox(
        width: 360,
        child: ElevatedButton(
          onPressed: () {
            // Your login logic here
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Sign In',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
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
}
