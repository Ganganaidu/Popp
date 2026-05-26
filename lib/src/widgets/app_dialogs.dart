import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_constants.dart';

class AppDialogs {
  // Private constructor to prevent instantiation
  AppDialogs._();

  static const List<String> soldReasons = [
    'Sold through this platform',
    'Sold through another platform',
    'Sold to friend/family',
    'Decided not to sell anymore',
    'Product exchanged/traded',
    'Product unavailable/damaged',
  ];

  /// Shows the sold-reason picker and, once the user submits, marks [docRef]
  /// as sold (sets isSold, status, soldReason and soldDate) and shows a
  /// snackbar. Returns true on a successful write, false if the user cancelled
  /// or the write failed. Callers can use the result to update local state.
  static Future<bool> confirmAndMarkAsSold({
    required BuildContext context,
    required DocumentReference docRef,
    String successMessage = 'Product marked as sold successfully',
  }) async {
    final reason = await showSoldReasonDialog(context: context);
    if (reason == null) return false;

    try {
      await docRef.update({
        'isSold': true,
        'status': 'Sold',
        'soldReason': reason,
        'soldDate': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to mark as sold. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  /// Asks the seller why the product is being marked as sold.
  /// Returns the chosen reason once the user submits, or null if cancelled.
  static Future<String?> showSoldReasonDialog({
    required BuildContext context,
  }) {
    String? selectedReason;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Mark as Sold'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                          'Please choose the reason for marking this product as sold:'),
                    ),
                    ...soldReasons.map(
                      (reason) => RadioListTile<String>(
                        title: Text(reason),
                        value: reason,
                        groupValue: selectedReason,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onChanged: (value) =>
                            setState(() => selectedReason = value),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  onPressed: selectedReason == null
                      ? null
                      : () => Navigator.of(dialogContext).pop(selectedReason),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<void> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
    VoidCallback? cancelCallback,
    String confirmText = "OK",
    String? cancelText = "Cancel",
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            if (cancelText != null)
              TextButton(
                child: Text(cancelText),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  if (cancelCallback != null) {
                    cancelCallback();
                  }
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

  static Future<void> showProductSuccessDialog(
    BuildContext context,
    VoidCallback callBack,
    VoidCallback homeCallBack, {
    String title = "Product listed successfully. Awaiting approval",
    String confirmText = "My Listing",
    String? cancelText = "Home",
  }) {
    return showConfirmationDialog(
      context: context,
      title: title,
      content: "Your product has been sent for approval. Once it's approved, "
          "it will go live and be visible to the public. "
          "Meanwhile, check the current status under My Listings in Settings. "
          "Thanks for listing with us!",
      onConfirm: callBack,
      cancelCallback: homeCallBack,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }

  static Future<void> showServiceSubmitDialog(
      BuildContext context, String category, VoidCallback callBack) {
    return showConfirmationDialog(
      context: context,
      title: "Listing Submitted",
      content: "Your '$category' listing has been submitted for review. "
          "Once approved it will be visible to all users. Until then, "
          "it will remain pending and visible only to you. "
          "Thank you for listing with ${Constants.appName}!",
      onConfirm: callBack,
      cancelText: null,
      confirmText: "okay",
    );
  }
}
