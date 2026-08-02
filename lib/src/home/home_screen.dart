import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:popp/src/toolbar/pop_app_bar.dart';
import 'package:popp/src/toolbar/web_menu_drawer.dart';
import 'package:popp/src/toolbar/web_top_bar.dart';
import 'package:popp/src/utils/app_constants.dart';
import 'package:popp/src/utils/app_loger.dart';

import '../api/api_url.dart';
import '../chat/active_chat_provider.dart';
import '../navigation/custom_bottom_nav_bar.dart';
import '../navigation/nav_helper.dart';
import '../toolbar/web_side_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _navHelper = NavHelper();
  final ValueNotifier<bool> _canPop = ValueNotifier(false);
  final ValueNotifier<String> _appBarTitle = ValueNotifier(Constants.appName);

  // Recommended for foreground notifications on Android
  late AndroidNotificationChannel _channel;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _setupNotifications();
    _saveDeviceInfo();
    _navHelper.navigationChangeListener = _onNavigationChanged;
    _navHelper.updateAppBarTitle = _updateAppBarTitle;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onNavigationChanged();
    });
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
      // This is crucial for keeping the token up-to-date.
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
      final userRef = FirebaseFirestore.instance.collection(ApiUrl.userPath).doc(user.uid);
      // Use arrayUnion to add the token only if it's not already present.
      // This prevents duplicate tokens.
      await userRef.set(
        {
          'fcmTokens': FieldValue.arrayUnion([token]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true), // Use merge to avoid overwriting other user data.
      );
      AppLogger.d('FCM Token saved to Firestore for user: ${user.uid}');
    } catch (e) {
      AppLogger.e('Error saving FCM Token to Firestore: $e');
    }
  }

  /// Records basic device/app info on the user's document — not for
  /// analytics, just so a specific user's platform, OS version, device
  /// model, and app version are on hand when tracking down a reported bug.
  /// Overwrites in place on every launch (latest device only, not a
  /// per-device history) since that's all this is meant for.
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
        osVersion = 'Android ${info.version.release} (SDK ${info.version.sdkInt})';
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

  /// Configures how incoming messages are handled while the app is in the foreground.
  void _configureForegroundMessageHandler() {
    // Required for foreground notifications on Android
    _channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Create the channel on the device
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      AppLogger.d('Got a message whilst in the foreground!');
      AppLogger.d('Message data: ${message.data}');

      // Extract chatRoomId from incoming data payload if it exists
      final String? incomingChatRoomId = message.data['chatRoomId'];

      // Check if the user is actively viewing this specific chat room
      if (incomingChatRoomId != null && incomingChatRoomId == ActiveChatProvider.activeChatRoomId.value) {
        AppLogger.d('Suppressing notification because user is actively viewing this chat room: $incomingChatRoomId');
        return; // Skip showing the local notification
      }

      if (notification != null) {
        AppLogger.d(
            'Message also contained a notification: ${notification.title}');

        // If you're on Android, you need to display the notification manually
        // using flutter_local_notifications.
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
                icon: 'launch_background', // Ensure you have this drawable
              ),
            ),
          );
        }
      }
    });

    // Also handle when a user taps a notification that opened the app from a background state.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.d('A new onMessageOpenedApp event was published!');
      // Notification already saved server-side by Cloud Functions.
    });

    // Handle messages when the app is terminated or in the background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Define a top-level function for background messages handler
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // If you're using other Firebase services in the background,
    // make sure to initialize them first.
    // await Firebase.initializeApp();
    AppLogger.d("Handling a background message: ${message.messageId}");
  }


  /// Called whenever the inner Navigator stack changes
  void _onNavigationChanged() {
    final canPop =
        _navHelper.navigatorKeys[_selectedIndex].currentState?.canPop() ??
            false;
    _canPop.value = canPop;
    // Reset title when returning to root
    if (!canPop) {
      _appBarTitle.value = Constants.appName;
    }
  }

  void _updateAppBarTitle(String newTitle) {
    _appBarTitle.value = newTitle;
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Home tab clicked
      final navigator = _navHelper.navigatorKeys[_selectedIndex].currentState;
      if (navigator != null && navigator.canPop()) {
        navigator.popUntil((route) => route.isFirst); // pop to root first
      }
    }
    setState(() {
      _selectedIndex = index;
      _onNavigationChanged();
      _appBarTitle.value = Constants.appName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navHelper.onWillPop(_selectedIndex);
      },
      child: Scaffold(
        drawer: kIsWeb
            ? WebMenuDrawer(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              )
            : null,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kIsWeb ? 150 : kToolbarHeight),
          child: ValueListenableBuilder2<bool, String>(
            first: _canPop,
            second: _appBarTitle,
            builder: (context, canPop, title, _) {
              if (kIsWeb) {
                return WebTopBar(
                  selectedIndex: _selectedIndex,
                  navigatorKeys: _navHelper.navigatorKeys,
                );
              }
              return PopAppBar(
                title: title,
                selectedIndex: _selectedIndex,
                navigatorKeys: _navHelper.navigatorKeys,
                canPopOverride: canPop,
              );
            },
          ),
        ),
        body: kIsWeb
            ? Row(
                children: [
                  WebSideBar(
                    selectedIndex: _selectedIndex,
                    onItemTapped: _onItemTapped,
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _navHelper.widgetOptions,
                    ),
                  ),
                ],
              )
            : IndexedStack(
                index: _selectedIndex,
                children: _navHelper.widgetOptions,
              ),
        bottomNavigationBar: kIsWeb
            ? null
            : CustomBottomNavBar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
      ),

    );
  }
}

// Helper widget to rebuild when two ValueListenables change.
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget Function(BuildContext, A, B, Widget?) builder;

  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (context, firstValue, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, secondValue, __) {
            return builder(context, firstValue, secondValue, __);
          },
        );
      },
    );
  }
}
