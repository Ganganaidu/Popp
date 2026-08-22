import 'dart:async';
import 'dart:ui'; // For PlatformDispatcher

import 'package:app_links/app_links.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:popp/src/api/firebase/remote_config_service.dart';
import 'package:popp/src/app_providers.dart';
import 'package:popp/src/deeplink/product_service_deep_link.dart';
import 'package:popp/src/home/home_screen.dart';
import 'package:popp/src/login/login_screen.dart';
import 'package:popp/src/login/sign_up_congrats_screen.dart';
import 'package:popp/src/login/signup_screen.dart';
import 'package:popp/src/systemalerts/auth_wrapper.dart';
import 'package:popp/src/theme/theme_notifier.dart';

import 'firebase_options.dart';
import 'src/theme/theme.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final ThemeNotifier themeNotifier = ThemeNotifier();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
final FirebaseAnalyticsObserver analyticsObserver =
    FirebaseAnalyticsObserver(analytics: analytics);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

/// Subscribes every install to broadcast topics, regardless of login state
/// (unlike per-user FCM token storage in home_screen.dart, which only runs
/// for authenticated users). 'all_users' lets an announcement (e.g. "new
/// version released") be sent to everyone directly from the Firebase
/// Console with no Cloud Function needed. The platform-specific topic is
/// there for the day you need to announce something to only iOS or only
/// Android users without pinging everyone else.
Future<void> _subscribeToNotificationTopics() async {
  try {
    final messaging = FirebaseMessaging.instance;
    await messaging.subscribeToTopic('all_users');

    final String platformTopic = kIsWeb
        ? 'platform_web'
        : defaultTargetPlatform == TargetPlatform.iOS
            ? 'platform_ios'
            : 'platform_android';
    await messaging.subscribeToTopic(platformTopic);
  } catch (e) {
    // Non-fatal — a failed subscription attempt is simply retried on the
    // next app launch.
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await themeNotifier.loadTheme();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize Remote Config
  final remoteConfigService = await RemoteConfigService.getInstance();
  await remoteConfigService.fetchAndActivate();

  if (kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('YOUR_RECAPTCHA_SITE_KEY'),
    );
  } else {
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    );
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  unawaited(_subscribeToNotificationTopics());

  runApp(
    const AppProviders(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _handleInitialLink();
    _handleIncomingLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  /// Handles the link that the app was opened with from a terminated state.
  Future<void> _handleInitialLink() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _navigateToDetailScreen(initialLink);
      }
    } catch (e) {
      // Handle error
    }
  }

  /// Sets up a listener for links while the app is running.
  void _handleIncomingLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      if (!mounted) return;
      _navigateToDetailScreen(uri);
    }, onError: (err) {
      // Handle error
    });
  }

  /// Parses the URI and navigates to the correct screen. If the user isn't
  /// signed in yet, the link is stashed in [PendingDeepLink] and consumed by
  /// [AuthWrapper] right after login instead of being dropped.
  Future<void> _navigateToDetailScreen(Uri uri) async {
    final segments = uri.pathSegments;
    if (segments.length != 2 ||
        (segments[0] != 'service' && segments[0] != 'product')) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      PendingDeepLink.uri = uri;
      navigatorKey.currentState?.pushReplacementNamed('/login');
      return;
    }

    await openDeepLinkUri(uri);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'BikerVerse',
          themeMode: currentThemeMode,
          theme: bikerverseLightTheme,
          darkTheme: bikerverseDarkTheme,
          home: const AuthWrapper(),
          navigatorObservers: [analyticsObserver],

          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/home': (context) => const HomeScreen(),
            '/finalCongrats': (context) => const SignUpCongratsScreen()
          },
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            MonthYearPickerLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
          ],
        );
      },
    );
  }
}
