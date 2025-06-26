import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../firebase/auth_service.dart';
import '../navigation/nav_router.dart';
import '../subscription/subscribe_page_widget.dart';
import '../utils/app_constants.dart';
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

  void _openTermsLink() async {
    final launched = await launchUrl(
      Uri.parse(Constants.privacyLink),
      mode: LaunchMode.externalApplication,
    );
    if (launched) {
      setState(() => hasClickedTermsLink = true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not open Terms & Conditions link.')),
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
        // update registration status
        await updateRegistrationComplete(
            uid: widget.userData.uid, registrationComplete: true);

        if (!mounted) return;
        // Show bottom sheet with SubscribePageWidget instead of navigating to finalCongrats
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          builder: (context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: SubscribePageWidget(
              userUid: widget.userData.uid,
              isFromSettings: false,
            ),
          ),
        );
      } else {
        await updateRegistrationComplete(
            uid: widget.userData.uid, registrationComplete: false);

        // More specific error handling
        String userMessage =
            saveUserDataResult.errorMessage ?? "An unknown error occurred.";
        if (saveUserDataResult.errorCode == 'permission-denied') {
          userMessage =
              "You do not have permission to save this data. Please contact support.";
          // You might also log out the user or take other specific actions
        } else if (saveUserDataResult.errorCode == 'unavailable') {
          userMessage =
              "Could not connect to the server. Please check your internet connection and try again.";
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $userMessage")),
        );
        AppLogger.i("widget.userData ${widget.userData}");
        AppLogger.w(
            "Failed to save user data. Error: ${saveUserDataResult.errorMessage}, Code: ${saveUserDataResult.errorCode}");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use' ||
          e.code == 'account-exists-with-different-credential' ||
          e.code == 'phone-already-in-use') {
        if (!mounted) return;
        // Handle user already exists case
        await AppDialogs.showUserExistsDialog(context, () {
          if (context.mounted) {
            onLoginTap(context);
          }
        });
        return;
      }
      // Handle other FirebaseAuthExceptions
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An authentication error occurred: ${e.message}')),
      );
      // Log the error for more detailed analysis
      AppLogger.e("Unhandled FirebaseAuthException: ${e.code} - ${e.message}");
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Register & Subscribe")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("🏍️ Welcome, Riders!",
                        style: textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(
                      "You're now part of a passionate community built by riders, for riders. Whether you're cruising the highways or hitting the track, this app is your ultimate companion on two wheels.",
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    Text("🚀 Enjoy the Free Ride",
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                        "Right now, you're in the free access period. Explore all the features without spending a dime!",
                        style: textTheme.bodyLarge),
                    const SizedBox(height: 24),
                    Text("🔥 What You Can Do:",
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...[
                      "Create and Join Rides: Plan epic journeys and invite fellow bikers.",
                      "Discover Top Routes: Get access to handpicked routes.",
                      "Nearby Services: Find trusted bike service centers.",
                      "Train & Ride Harder: Join training sessions and track days.",
                      "Need a Ride? Rent bikes effortlessly."
                    ].map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text("• $item", style: textTheme.bodyLarge),
                        )),
                    const SizedBox(height: 24),
                    Text(" Subscription? Practically Free",
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                        "After trial ends, keep riding with us for a yearly subscription fee so low, it's almost unbelievable.",
                        style: textTheme.bodyLarge),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      title: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            const TextSpan(text: 'Check to accept '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _openTermsLink,
                            ),
                            const TextSpan(text: ' of POPP'),
                          ],
                        ),
                      ),
                      value: termsAccepted,
                      onChanged: (val) {
                        if (hasClickedTermsLink) {
                          setState(() => termsAccepted = val ?? false);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Kindly read and accept the Terms & Conditions before continuing...')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitToFireStore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Register & Subscribe",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
