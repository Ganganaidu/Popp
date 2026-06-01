import 'dart:async';
import 'dart:ui'; // For PlatformDispatcher

import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:popp/src/api/api_url.dart';
import 'package:popp/src/api/firebase/remote_config_service.dart';
import 'package:popp/src/app_providers.dart';
import 'package:popp/src/home/home_screen.dart';
import 'package:popp/src/login/login_screen.dart';
import 'package:popp/src/login/sign_up_congrats_screen.dart';
import 'package:popp/src/login/signup_screen.dart';
import 'package:popp/src/products/product_detail_screen.dart';
import 'package:popp/src/services/listservices/service_detail_screen.dart';
import 'package:popp/src/systemalerts/auth_wrapper.dart';
import 'package:popp/src/theme/theme_notifier.dart';

import 'firebase_options.dart';
import 'src/theme/theme.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final ThemeNotifier themeNotifier = ThemeNotifier();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

  /// Parses the URI and navigates to the correct screen.
  Future<void> _navigateToDetailScreen(Uri uri) async {
    final segments = uri.pathSegments;
    if (segments.length != 2 ||
        (segments[0] != 'service' && segments[0] != 'product')) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      navigatorKey.currentState?.pushReplacementNamed('/login');
      return;
    }

    final productType = segments[0];
    final serviceId = segments[1];
    final servicePath =
        productType == 'service' ? ApiUrl.servicePath : ApiUrl.productsPath;

    try {
      final doc = await FirebaseFirestore.instance
          .collection(servicePath)
          .doc(serviceId)
          .get();

      if (!doc.exists) return;
      final raw = doc.data() as Map<String, dynamic>;
      final data = {...raw, 'id': doc.id};

      if (productType == 'service') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(
              serviceData: data,
              category: data['category'] ?? '',
            ),
          ),
        );
      } else {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productJson: data,
            ),
          ),
        );
      }
    } catch (e) {
      // Optionally handle error
    }
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
