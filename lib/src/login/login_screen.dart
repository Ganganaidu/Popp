import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:popp/src/widgets/app_dialogs.dart';
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

  // Set to false to hide social logins for now
  bool showSocialLogin = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // State variables for dynamic welcome messages
  // String _welcomeMessage = "Bikerverse";

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
    
    if (kIsWeb && context.isDesktop) {
      return _buildWebLayout(context, isDarkMode);
    } else {
      return _buildMobileLayout(context, isDarkMode);
    }
  }

  Widget _buildWebLayout(BuildContext context, bool isDarkMode) {
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
        child: Row(
          children: [
            // Left side - Branding
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(60),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/app_icon_trans.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        Constants.appName,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbitron',
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome back! Sign in to continue your journey.',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Right side - Login Form
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(60),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildLoginForm(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDarkMode) {
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
                    const SizedBox(height: 30),
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildLoginForm(context),
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

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      children: [
        if (kIsWeb && context.isDesktop) ...[
          Text(
            'Sign In',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your credentials to access your account',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white70 
                  : Colors.black54,
            ),
          ), 
          const SizedBox(height: 40),
        ],
        _buildEmailField(),
        const SizedBox(height: 20),
        _buildPasswordField(),
        const SizedBox(height: 20),
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
      ],
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
        const Text(Constants.appName,
            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, fontFamily: 'Orbitron')),
      ],
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {IconData? icon,
      TextInputType? keyboardType,
      bool isPasswordField = false,
      bool? isPasswordVisible,
      VoidCallback? onTogglePasswordVisibility}) {
    final isWeb = kIsWeb && context.isDesktop;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPasswordField ? !(isPasswordVisible ?? false) : false,
      style: TextStyle(fontSize: isWeb ? 16 : 14),
      decoration: context.inputDecoration(
        '',
        hint,
        icon: icon,
        borderRadius: isWeb ? 8.0 : 8.0,
      ).copyWith(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isWeb ? 20 : 16,
          vertical: isWeb ? 18 : 16,
        ),
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  (isPasswordVisible ?? false)
                      ? Icons.visibility
                      : Icons.visibility_off,
                  size: isWeb ? 20 : 18,
                ),
                onPressed: onTogglePasswordVisibility,
              )
            : null,
      ),
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      'Email',
      _emailController,
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      'Password',
      _passwordController,
      icon: Icons.lock_outline_rounded,
      isPasswordField: true,
      isPasswordVisible: isPasswordVisible,
      onTogglePasswordVisibility: () => setState(() => isPasswordVisible = !isPasswordVisible),
    );
  }

  Widget _buildActionsRow() {
    final isWeb = kIsWeb && context.isDesktop;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: rememberMe,
              onChanged: _onRememberMeChanged,
              activeColor: context.primaryColor,
              materialTapTargetSize: isWeb 
                  ? MaterialTapTargetSize.shrinkWrap 
                  : MaterialTapTargetSize.padded,
            ),
            Text(
              'Remember me',
              style: TextStyle(
                fontSize: isWeb ? 14 : 12,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white70 
                    : Colors.black87,
              ),
            ),
          ],
        ),
        _buildTextButton(
          'Forgot Password?',
          () => onForgotPasswordTap(context, false),
        )
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback? onPressed, {bool isLoading = false}) {
    final isWeb = kIsWeb && context.isDesktop;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isWeb ? 8 : 30),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isWeb ? 18 : 16,
            horizontal: isWeb ? 24 : 16,
          ),
          elevation: isWeb ? 2 : 5,
          shadowColor: context.primaryColor.withOpacity(0.4),
        ),
        child: isLoading
            ? SizedBox(
                height: isWeb ? 20 : 18,
                width: isWeb ? 20 : 18,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: isWeb ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return _buildButton('Sign In', _signIn, isLoading: _isLoading);
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

  Widget _buildTextButton(String text, VoidCallback? onPressed, {Color? textColor}) {
    final isWeb = kIsWeb && context.isDesktop;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? 8 : 4,
          vertical: isWeb ? 4 : 2,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? context.primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: isWeb ? 14 : 12,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final isWeb = kIsWeb && context.isDesktop;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: TextStyle(
                fontSize: isWeb ? 14 : 12,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white70 
                    : Colors.black54,
              ),
            ),
            _buildTextButton(
              "Sign Up",
              () => Navigator.pushReplacementNamed(context, '/signup'),
            )
          ],
        ),
        if (!isWeb) ...[
          const SizedBox(height: 8),
          _buildTextButton(
            'Skip for now',
            () => Navigator.pushReplacementNamed(context, '/home'),
            textColor: Colors.grey[600],
          ),
        ],
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
