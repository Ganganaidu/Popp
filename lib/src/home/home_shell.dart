import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:popp/src/toolbar/pop_app_bar.dart';
import 'package:popp/src/toolbar/web_menu_drawer.dart';
import 'package:popp/src/toolbar/web_top_bar.dart';
import 'package:popp/src/utils/app_loger.dart';

import '../api/api_url.dart';
import '../chat/active_chat_provider.dart';
import '../navigation/custom_bottom_nav_bar.dart';
import '../toolbar/web_side_bar.dart';

/// Root shell for the four bottom-nav tabs, hosted by a
/// [StatefulShellRoute.indexedStack] in `app_router.dart`. Replaces the legacy
/// `nav_helper.dart` IndexedStack. It also owns the app's push-notification and
/// device-info setup, which previously lived in the old `HomeScreen`.
class HomeShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShell({super.key, required this.navigationShell});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // Recommended for foreground notifications on Android
  late AndroidNotificationChannel _channel;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _setupNotifications();
    _saveDeviceInfo();
  }

  /// Switches the active branch. Re-tapping the current tab resets it to its
  /// root (the standard go_router shell pattern).
  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  /// Sets up all notification-related logic.
  Future<void> _setupNotifications() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // 1. Request permission from the user.
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // 2. Get the initial token and save it to Firestore.
      final initialToken = await messaging.getToken();
      if (initialToken != null) {
        _saveToken(initialToken);
      }

      // 3. Set up a listener for any future token refreshes.
      FirebaseMessaging.instance.onTokenRefresh.listen(_saveToken);

      // 4. Configure foreground message handling.
      if (mounted) {
        _configureForegroundMessageHandler();
      }
    } catch (e) {
      AppLogger.e('Error setting up notifications: $e');
    }
  }

  /// Saves the given FCM token to the current user's document in Firestore.
  Future<void> _saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      AppLogger.d('User not logged in. Skipping FCM token save.');
      return;
    }

    try {
      final userRef =
          FirebaseFirestore.instance.collection(ApiUrl.userPath).doc(user.uid);
      // arrayUnion adds the token only if not already present (no duplicates).
      await userRef.set(
        {
          'fcmTokens': FieldValue.arrayUnion([token]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      AppLogger.d('FCM Token saved to Firestore for user: ${user.uid}');
    } catch (e) {
      AppLogger.e('Error saving FCM Token to Firestore: $e');
    }
  }

  /// Records basic device/app info on the user's document so a specific user's
  /// platform, OS version, device model, and app version are on hand when
  /// tracking down a reported bug. Overwrites in place on every launch.
  Future<void> _saveDeviceInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfoPlugin = DeviceInfoPlugin();

      String platform;
      String osVersion;
      String deviceModel;

      if (kIsWeb) {
        final info = await deviceInfoPlugin.webBrowserInfo;
        platform = 'web';
        osVersion = info.userAgent ?? 'unknown';
        deviceModel = info.browserName.name;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final info = await deviceInfoPlugin.iosInfo;
        platform = 'ios';
        osVersion = info.systemVersion;
        deviceModel = info.utsname.machine;
      } else {
        final info = await deviceInfoPlugin.androidInfo;
        platform = 'android';
        osVersion =
            'Android ${info.version.release} (SDK ${info.version.sdkInt})';
        deviceModel = '${info.manufacturer} ${info.model}';
      }

      final userRef =
          FirebaseFirestore.instance.collection(ApiUrl.userPath).doc(user.uid);
      await userRef.set(
        {
          'deviceInfo': {
            'platform': platform,
            'osVersion': osVersion,
            'deviceModel': deviceModel,
            'appVersion': packageInfo.version,
            'buildNumber': packageInfo.buildNumber,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      AppLogger.e('Error saving device info to Firestore: $e');
    }
  }

  /// Configures how incoming messages are handled while in the foreground.
  void _configureForegroundMessageHandler() {
    _channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      AppLogger.d('Got a message whilst in the foreground!');
      AppLogger.d('Message data: ${message.data}');

      final String? incomingChatRoomId = message.data['chatRoomId'];

      // Suppress the local notification if the user is already viewing this chat.
      if (incomingChatRoomId != null &&
          incomingChatRoomId == ActiveChatProvider.activeChatRoomId.value) {
        AppLogger.d(
            'Suppressing notification because user is actively viewing this chat room: $incomingChatRoomId');
        return;
      }

      if (notification != null) {
        AppLogger.d(
            'Message also contained a notification: ${notification.title}');
        if (android != null && !kIsWeb) {
          _flutterLocalNotificationsPlugin.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                icon: 'launch_background',
              ),
            ),
          );
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.d('A new onMessageOpenedApp event was published!');
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    AppLogger.d("Handling a background message: ${message.messageId}");
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = widget.navigationShell.currentIndex;
    return Scaffold(
      drawer: kIsWeb
          ? WebMenuDrawer(
              selectedIndex: currentIndex,
              onItemTapped: _goBranch,
            )
          : null,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kIsWeb ? 150 : kToolbarHeight),
        child: kIsWeb ? const WebTopBar() : const PopAppBar(),
      ),
      body: kIsWeb
          ? Row(
              children: [
                WebSideBar(
                  selectedIndex: currentIndex,
                  onItemTapped: _goBranch,
                ),
                Expanded(child: widget.navigationShell),
              ],
            )
          : widget.navigationShell,
      bottomNavigationBar: kIsWeb
          ? null
          : CustomBottomNavBar(
              selectedIndex: currentIndex,
              onItemTapped: _goBranch,
            ),
    );
  }
}
