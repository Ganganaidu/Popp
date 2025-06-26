import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:popp/src/app_providers.dart';
import 'package:popp/src/home/home_screen.dart';
import 'package:popp/src/login/login_screen.dart';
import 'package:popp/src/login/sign_up_congrats_screen.dart';
import 'package:popp/src/login/signup_screen.dart';
import 'package:popp/src/splash/splash_screen.dart';
import 'package:popp/src/subscription/subscription_provider.dart';
import 'package:popp/src/theme/theme_notifier.dart';
import 'package:provider/provider.dart';

import 'src/firebase/firebase_options.dart';
import 'src/theme/theme.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final ThemeNotifier themeNotifier = ThemeNotifier();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message here if needed
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Call refreshSubscriptionFromStore when app resumes
      // Use addPostFrameCallback to ensure context is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider =
            Provider.of<SubscriptionProvider>(context, listen: false);
        provider.refreshSubscriptionFromStore();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, _) {
        return MaterialApp(
          title: 'Popp',
          themeMode: currentThemeMode,
          theme: poppLightTheme,
          darkTheme: poppDarkTheme,
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/home': (context) => const HomeScreen(),
            '/finalCongrats': (context) => const SignUpCongratsScreen(),
          },
          debugShowCheckedModeBanner: false,
          // Add these localization delegates
          localizationsDelegates: const [
            MonthYearPickerLocalizations.delegate, // Add this specific delegate
          ],
          supportedLocales: const [
            Locale('en', 'US'), // English (United States)
            // Add other locales your app supports if needed
          ],
        );
      },
    );
  }
}
