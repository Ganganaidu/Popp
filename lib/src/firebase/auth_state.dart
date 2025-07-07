import 'package:flutter/material.dart';

/// A global notifier to track if the user is in the signup process.
///
/// This flag tells the global auth listener not to redirect to the home screen
/// while the user is actively creating an account.
final ValueNotifier<bool> isSigningUp = ValueNotifier(false);
