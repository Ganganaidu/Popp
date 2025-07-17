import 'package:cloud_firestore/cloud_firestore.dart'; // NEW: Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // NEW: Import FirebaseAuth
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:popp/src/toolbar/pop_app_bar.dart';
import 'package:popp/src/utils/app_constants.dart';
import 'package:popp/src/utils/app_loger.dart';

import '../api/api_url.dart';
import '../navigation/custom_bottom_nav_bar.dart';
import '../navigation/nav_helper.dart';

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

  String? _fcmToken;

  // Recommended for foreground notifications on Android
  late AndroidNotificationChannel _channel;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _setupNotifications();
    _navHelper.navigationChangeListener = _onNavigationChanged;
    _navHelper.updateAppBarTitle = _updateAppBarTitle;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onNavigationChanged();
    });
  }

  Future<void> _setupNotifications() async {
    await _requestPermissions();
    await _getFCMToken(); // This will now also save the token
    _configureForegroundMessageHandler();
  }

  Future<void> _requestPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    AppLogger.d('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    setState(() {
      _fcmToken = token;
    });
    AppLogger.d('FCM Token: $_fcmToken');
    // Send this token to your backend server or save it to Firestore
    if (token != null && FirebaseAuth.instance.currentUser != null) {
      await _saveFCMTokenToFirestore(token, FirebaseAuth.instance.currentUser!.uid);
    }
  }

  // NEW: Method to save FCM token to Firestore
  Future<void> _saveFCMTokenToFirestore(String token, String uid) async {
    try {
      final userRef = FirebaseFirestore.instance.collection(ApiUrl.userPath).doc(uid);
      await userRef.set(
        {
          'fcmTokens': FieldValue.arrayUnion([token]), // Add token to an array
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true), // Use merge to avoid overwriting existing fields
      );
      AppLogger.d('FCM Token saved to Firestore for user: $uid');
    } catch (e) {
      AppLogger.e('Error saving FCM Token to Firestore: $e');
    }
  }


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

      if (notification != null) {
        AppLogger.d(
            'Message also contained a notification: ${notification.title}');

        // If you're on Android, you need to display the notification manually
        // using flutter_local_notifications.
        if (android != null && !kIsWeb) { // Add !kIsWeb check for Android-specific logic
          _flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
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
      // You can add logic here to navigate to a specific page
      // based on the message data.
    });

    // Handle messages when the app is terminated or in the background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Define a top-level function for background messages handler
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // If you're using Firebase services, make sure to initialize them
    // For example: await Firebase.initializeApp();
    AppLogger.d("Handling a background message: ${message.messageId}");
    // You can process the message here, e.g., save to local storage, show local notification
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ValueListenableBuilder2<bool, String>(
            first: _canPop,
            second: _appBarTitle,
            builder: (context, canPop, title, _) {
              return PopAppBar(
                title: title,
                selectedIndex: _selectedIndex,
                navigatorKeys: _navHelper.navigatorKeys,
                canPopOverride: canPop,
              );
            },
          ),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _navHelper.widgetOptions,
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}

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
