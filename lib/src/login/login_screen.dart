import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation/nav_router.dart';
import '../utils/app_constants.dart';
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
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRememberMe = prefs.getBool('remember_me') ?? false;
    final savedUsername = prefs.getString('remembered_username') ?? '';
    if (savedRememberMe && savedUsername.isNotEmpty) {
      setState(() {
        rememberMe = true;
        _emailController.text = savedUsername;
      });
    }
  }

  Future<void> _onRememberMeChanged(bool? value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = value ?? false;
    });
    AppLogger.d("_onRememberMeChanged $rememberMe");
    if (rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('remembered_username', _emailController.text);
      AppLogger.d("remember_me saved $rememberMe");
    } else {
      await prefs.setBool('remember_me', false);
      await prefs.remove('remembered_username');
      AppLogger.d("remember_me not saved $rememberMe");
    }
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
                    const SizedBox(height: 16),
                    _buildSkipButton(),
                  ],
                ),
              ),
            ),
            // Move skip button below signup and privacy/terms
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: _buildPrivacyTermsLink(),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Checkbox(
                value: rememberMe,
                onChanged: _onRememberMeChanged,
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
                style: TextStyle(color: Colors.orange)),
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

  Widget _buildPrivacyTermsLink() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () async {
          final launched = await launchUrl(
            Uri.parse(Constants.privacyLink),
            mode: LaunchMode.externalApplication,
          );
          if (!launched) {
            _showError('Could not open Privacy and Terms & Conditions link.');
          }
        },
        child: const Text(
          'Privacy and Terms & Conditions',
          style: TextStyle(
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return SizedBox(
      width: 180,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/home');
        },
        label: const Text(
          'Skip for now',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.orange),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
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

