import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:popp/src/widgets/app_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Set to false to hide social logins for now
  bool showSocialLogin = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // State variables for dynamic welcome messages
  // String _welcomeMessage = "POPP";
  final String _welcomeSubtitle = "Pre owned Premium Products";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
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
        // Update messages for returning user
        // _welcomeMessage = "Welcome Back!";
        // _welcomeSubtitle = "Sign in to continue your journey";
      });
    }
  }

  Future<void> _onRememberMeChanged(bool? value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = value ?? false;
    });
    if (rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('remembered_username', _emailController.text);
    } else {
      await prefs.setBool('remember_me', false);
      await prefs.remove('remembered_username');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
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

    setState(() => _isLoading = true);

    try {
      final userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (userCred.user?.emailVerified == false) {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        showVerificationDialog(email, password);
      } else {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Authentication failed");
    } catch (e) {
      _showError("Something went wrong. Please try again.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> showVerificationDialog(String email, String password) async {
    AppDialogs.showConfirmationDialog(
      context: context,
      title: "Email not verified",
      content:
          "To keep your account secure, please verify your email address. Click 'Verify Now' to continue",
      onConfirm: () {
        onVerificationScreenTap(context, null, email, password, false);
      },
      confirmText: "Verify Now",
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [Colors.grey[850]!, Colors.grey[900]!]
                : [const Color(0xFFFDFBFB), const Color(0xFFEBEDEE)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 16),
                    _buildActionsRow(),
                    const SizedBox(height: 32),
                    _buildLoginButton(),
                    if (showSocialLogin) ...[
                      const SizedBox(height: 32),
                      _buildOrDivider(),
                      const SizedBox(height: 24),
                      const SocialLoginButtons(),
                    ],
                    const SizedBox(height: 40),
                    _buildFooter(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // You can replace this with an Image.asset for your logo
        // Icon(Icons.two_wheeler_rounded, size: 60, color: context.primaryColor),
        Image.asset(
          'assets/app_icon_trans.png',
          width: 80,
          height: 80,
          fit: BoxFit.contain,
        ),
        // const SizedBox(height: 16),
        // Text(_welcomeMessage,
        //     style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(_welcomeSubtitle,
            style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: context.inputDecoration(
        '',
        'Email',
        icon: Icons.email_outlined,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !isPasswordVisible,
      decoration: context
          .inputDecoration(
            '',
            'Password',
            icon: Icons.lock_outline_rounded,
          )
          .copyWith(
            // Use copyWith to add the suffix icon without modifying the common method
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () =>
                  setState(() => isPasswordVisible = !isPasswordVisible),
            ),
          ),
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: rememberMe,
              onChanged: _onRememberMeChanged,
              activeColor: context.primaryColor,
            ),
            const Text('Remember me'),
          ],
        ),
        TextButton(
          onPressed: () => onForgotPasswordTap(context, false),
          child: Text('Forgot Password?',
              style: TextStyle(color: context.primaryColor)),
        )
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.primaryColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 5,
          shadowColor: context.primaryColor.withOpacity(0.4),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Sign In',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("OR", style: TextStyle(color: Colors.grey[500])),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account?"),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/signup'),
              child: Text("Sign Up",
                  style: TextStyle(
                      color: context.primaryColor,
                      fontWeight: FontWeight.bold)),
            )
          ],
        ),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          child:
              Text('Skip for now', style: TextStyle(color: Colors.grey[600])),
        ),
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
