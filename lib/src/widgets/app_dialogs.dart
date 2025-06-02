import 'package:flutter/material.dart';

class AppDialogs {
  // Private constructor to prevent instantiation
  AppDialogs._();

  static Future<void> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
    String confirmText = "OK",
    String cancelText = "Cancel",
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(cancelText),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: Text(confirmText),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showUserExistsDialog(
      BuildContext context, VoidCallback onLogin) {
    return showConfirmationDialog(
      context: context,
      title: "User Already Exists",
      content: "An account with this email or phone number already exists."
          " Do you want to login instead?",
      onConfirm: onLogin,
      confirmText: "Login",
    );
  }

  static Future<void> showUserLoginDialog(
      BuildContext context, VoidCallback onLogin, String description) {
    return showConfirmationDialog(
      context: context,
      title: "Want to $description?",
      content: "Please login in to access this feature",
      onConfirm: onLogin,
      confirmText: "Login",
    );
  }

  static Future<void> showOkayDialog(
      BuildContext context,
      VoidCallback callBack,
      String title,
      String content,
      String cancelText,
      String confirmText) {
    return showConfirmationDialog(
      context: context,
      title: title,
      content: content,
      onConfirm: callBack,
      cancelText: cancelText,
      confirmText: confirmText,
    );
  }

  static Future<void> showComingSoonDialog(
      BuildContext context, VoidCallback callBack) {
    return showConfirmationDialog(
      context: context,
      title: "Coming Soon!",
      content: "We’re building something awesome. Stay tuned!",
      onConfirm: callBack,
      cancelText: "",
      confirmText: "okay",
    );
  }
}
