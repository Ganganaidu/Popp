import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_url.dart';
import '../api/firebase/auth_service.dart';
import '../api/firebase/remote_config_service.dart';
import '../navigation/app_routes.dart';
import '../subscription/subscribe_page_widget.dart';
import '../widgets/app_dialogs.dart';
import 'model/user_data_model.dart';

class RegisterAndSubscribeScreen extends StatefulWidget {
  final UserData userData;

  const RegisterAndSubscribeScreen({super.key, required this.userData});

  @override
  State<RegisterAndSubscribeScreen> createState() =>
      _RegisterAndSubscribeScreenState();
}

class _RegisterAndSubscribeScreenState
    extends State<RegisterAndSubscribeScreen> {
  bool termsAccepted = false;
  bool isSubmitting = false;
  bool hasClickedTermsLink = false;
  bool _showSubscription = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  void _loadConfig() async {
    final configService = await RemoteConfigService.getInstance();
    setState(() {
      _showSubscription = configService.isSubscriptionFeatureEnabled;
    });
  }

  void _openTermsLink() async {
    AppLogger.w("Terms link clicked");
    final uri = Uri.parse(ApiUrl.privacyLink);
    final launched = await launchUrl(uri);
    if (launched) {
      setState(() => hasClickedTermsLink = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Could not open Terms & Conditions link.")),
      );
    }
  }

  Future<void> submitToFireStore() async {
    if (!termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please accept the Terms & Conditions")),
      );
      return;
    }
    setState(() => isSubmitting = true);

    try {
      FireStoreResult saveUserDataResult =
          await saveUserDataToFireStore(widget.userData);
      if (saveUserDataResult.success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile data saved successfully!")),
        );
        await updateRegistrationComplete(
            uid: widget.userData.uid, registrationComplete: true);

        if (_showSubscription) {
          if (!mounted) return;
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            backgroundColor: Colors.transparent,
            builder: (context) => DraggableScrollableSheet(
              initialChildSize: 0.8,
              maxChildSize: 0.9,
              minChildSize: 0.7,
              builder: (_, scrollController) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SubscribePageWidget(
                  userUid: widget.userData.uid,
                  isFromSettings: false,
                ),
              ),
            ),
          );
        } else {
          if (!mounted) return;
          context.goHome();
        }
      } else {
        await updateRegistrationComplete(
            uid: widget.userData.uid, registrationComplete: false);

        String userMessage =
            saveUserDataResult.errorMessage ?? "An unknown error occurred.";
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $userMessage")),
        );
      }
    } on FirebaseAuthException catch (_) {
      if (!mounted) return;
      await AppDialogs.showUserExistsDialog(context, () {
        if (context.mounted) {
          context.goLogin();
        }
      });
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // A subtle background color to make the cards pop
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Welcome To POPP!",
                      style: textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    "Pre Owned Premium Products",
                    style: textTheme.titleSmall?.copyWith(
                        color:
                            isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Lottie.asset('assets/congrats.json', height: 100),
                    const SizedBox(height: 8),
                    // Welcome Card
                    _buildInfoCard(
                      icon: Icons.celebration_rounded,
                      iconColor: Colors.amber,
                      title: "Congratulations!",
                      content:
                          "You're now part of a passionate community built by riders, for riders. Explore all features for free during the trial period!",
                    ),

                    // Features Card
                    _buildInfoCard(
                      icon: Icons.stars_rounded,
                      iconColor: Colors.blueAccent,
                      title: "What You Can Do",
                      contentWidget: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFeatureRow(Icons.build_circle_outlined,
                              "Find Nearby Services"),
                          _buildFeatureRow(
                              Icons.directions_bike, "Discover Top Routes"),
                          _buildFeatureRow(Icons.speed_outlined,
                              "Join Training & Track Days"),
                          _buildFeatureRow(
                              Icons.map_outlined, "Create and Join Rides"),
                        ],
                      ),
                    ),

                    // Subscription Card
                    _buildInfoCard(
                      icon: Icons.workspace_premium_rounded,
                      iconColor: Colors.deepOrangeAccent,
                      title: "Subscription required?",
                      content: _showSubscription
                          ? "Practically Free, After the trial ends, keep riding with us for a Monthly/yearly subscription fee so low, it's almost unbelievable."
                          : "It’s completely free to use until we introduce our subscription system — and even then, the yearly fee will be so low, it’s almost unbelievable. Until then, enjoy unlimited access to all our services!",
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Bottom Action Area
            _buildBottomActionArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? content,
    Widget? contentWidget,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: iconColor.withOpacity(0.15),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (content != null)
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    height: 1.5),
              ),
            if (contentWidget != null) contentWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionArea(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 50),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (hasClickedTermsLink) {
                setState(() => termsAccepted = !termsAccepted);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Please read the Terms & Conditions before accepting.')),
                );
              }
            },
            child: Row(
              children: [
                Checkbox(
                  value: termsAccepted,
                  onChanged: (val) {
                    if (hasClickedTermsLink) {
                      setState(() => termsAccepted = val ?? false);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please read the Terms & Conditions before accepting.')),
                      );
                    }
                  },
                  activeColor: Colors.orange,
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        const TextSpan(text: 'I have read and agree to the '),
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _openTermsLink,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : submitToFireStore,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: termsAccepted ? 5 : 0,
              ).copyWith(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.grey;
                  }
                  return Colors.orange; // Use the component's default.
                },
              )),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _showSubscription
                          ? "Register & Subscribe"
                          : "Let's Ride!",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
