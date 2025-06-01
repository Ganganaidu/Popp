import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:poppflutter/src/utils/app_loger.dart';

import '../firebase/auth_service.dart';
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

  Future<void> submitToFireStore() async {
    if (!termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please accept the Terms & Conditions")),
      );
      return;
    }
    setState(() => isSubmitting = true);

    try {
      FirestoreResult saveUserDataResult =
          await saveUserDataToFireStore(widget.userData);
      if (saveUserDataResult.success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile data saved successfully!")),
        );
        Navigator.pushReplacementNamed(context, '/finalCongrats');
      } else {
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
        AppLogger.w(
            "Failed to save user data. Error: ${saveUserDataResult.errorMessage}, Code: ${saveUserDataResult.errorCode}");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use' ||
          e.code == 'account-exists-with-different-credential' ||
          e.code == 'phone-already-in-use') {
        await AppDialogs.showUserExistsDialog(context, () {
          Navigator.pushReplacementNamed(context, '/login');
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
                      title: const Text(
                          "Check to accept Terms & Conditions of POPP"),
                      value: termsAccepted,
                      onChanged: (val) =>
                          setState(() => termsAccepted = val ?? false),
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
