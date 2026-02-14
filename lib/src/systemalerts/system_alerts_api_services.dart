// dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_url.dart';
import '../utils/app_loger.dart';
import 'message_data.dart';

/// Service responsible for retrieving and handling system alert messages.
///
/// This service reads messages from Firestore, checks user-specific block
/// messages, and persists information about which messages have been shown
/// to the user using `SharedPreferences`.
class SystemAlertsApiServices {
  /// Firestore instance used to read system messages.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// FirebaseAuth instance used to determine the current user.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the highest-priority active `SystemMessage` that should be shown.
  ///
  /// Priority and selection rules:
  /// 1. If there is a global message with `priority == MessagePriority.high`
  ///    and `isActive == true`, return it immediately.
  /// 2. If the current authenticated user has a user-specific block message
  ///    (fetched via `_getUserBlockMessage`) that is active, return it (user
  ///    block messages are treated as high priority).
  /// 3. If no high-priority message is found, return the active global message
  ///    (if any).
  /// 4. Return `null` if no active messages are applicable.
  ///
  /// Returns a `Future<SystemMessage?>` that completes with the selected
  /// message or `null`.
  Future<SystemMessage?> getPriorityMessage() async {
    // 1. Check for a global message first.
    final globalMessage = await _getGlobalMessage();
    AppLogger.d("global message : ${globalMessage?.isActive} and priority : ${globalMessage?.priority}");
    if (globalMessage != null &&
        globalMessage.isActive &&
        globalMessage.priority == MessagePriority.high) {
      // If there's a high-priority global message, it overrides everything.
      return globalMessage;
    }

    // 2. Check for a user-specific block message.
    final user = _auth.currentUser;
    if (user != null) {
      final userMessage = await _getUserBlockMessage(user.uid);
      if (userMessage != null && userMessage.isActive) {
        // A user block is always high priority.
        return userMessage;
      }
    }

    // 3. If no high-priority messages, return the active global message (if any).
    if (globalMessage != null && globalMessage.isActive) {
      return globalMessage;
    }

    // No active messages found.
    return null;
  }

  /// Fetches the current global message document from Firestore.
  ///
  /// The method reads the document located at
  /// `collection(ApiUrl.globalMessagesPath).doc('current')`. If the document
  /// exists it is converted to `SystemMessage` via
  /// `SystemMessage.fromFirestore`. On errors the method logs the exception
  /// and returns `null`.
  ///
  /// Returns a `Future<SystemMessage?>`.
  Future<SystemMessage?> _getGlobalMessage() async {
    try {
      final doc =
          await _db.collection(ApiUrl.globalMessagesPath).doc('current').get();
      if (doc.exists) {
        return SystemMessage.fromFirestore(doc);
      }
    } catch (e) {
      // Handle potential errors, e.g., logging.
      AppLogger.e("Error fetching global message: $e");
    }
    return null;
  }

  /// Fetches a user-specific block message for the given `userId`.
  ///
  /// The method reads the document at:
  /// `collection(ApiUrl.userPath).doc(userId).collection('user_messages').doc('block_status')`.
  /// If the document exists it is converted to `SystemMessage`. On errors the
  /// method logs the exception and returns `null`.
  ///
  /// Parameters:
  /// - `userId` : the UID of the user whose block message should be fetched.
  ///
  /// Returns a `Future<SystemMessage?>`.
  Future<SystemMessage?> _getUserBlockMessage(String userId) async {
    try {
      final doc = await _db
          .collection(ApiUrl.userPath)
          .doc(userId)
          .collection('user_messages')
          .doc('block_status')
          .get();

      if (doc.exists) {
        return SystemMessage.fromFirestore(doc);
      }
    } catch (e) {
      AppLogger.e("Error fetching user message: $e");
    }
    return null;
  }

  /// Persists that `systemMessage` has been shown to the user.
  ///
  /// The message id is stored in `SharedPreferences` under the key
  /// `shown_message_{messageId}` with value `'true'`.
  ///
  /// If `systemMessage.messageId` is `null`, this method does nothing.
  Future<void> saveMessageId(SystemMessage systemMessage) async {
    if (systemMessage.messageId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('shown_message_${systemMessage.messageId}', 'true');
    }
  }

  /// Checks whether a message with `messageId` has already been shown.
  ///
  /// Returns `false` immediately if `messageId` is `null`.
  /// Otherwise reads `SharedPreferences` key `shown_message_{messageId}` and
  /// returns `true` when the stored value equals `'true'`.
  Future<bool> _hasMessageBeenShown(String? messageId) async {
    if (messageId == null) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('shown_message_$messageId') == 'true';
  }

  /// Determines whether `message` should be shown to the user.
  ///
  /// The method returns `false` if the message has already been shown (using
  /// `_hasMessageBeenShown`). If not shown before, it compares the current
  /// app build number from `PackageInfo.fromPlatform()` with the message's
  /// `versionCode`. If the build number differs from `message.versionCode`
  /// the method returns `true` (indicating it should be shown); otherwise
  /// it returns `false`.
  ///
  /// Returns a `Future<bool>`.
  Future<bool> shouldShowMessage(SystemMessage message) async {
    final hasBeenShown = await _hasMessageBeenShown(message.messageId);
    if (hasBeenShown) return false;

    final packageInfo = await PackageInfo.fromPlatform();
    AppLogger.d("packageInfo.buildNumber ${packageInfo.buildNumber}");
    AppLogger.d("versionCode ${message.versionCode}");

    return packageInfo.buildNumber != message.versionCode;
  }
}
