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
}
