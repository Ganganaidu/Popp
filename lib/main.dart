import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:poppflutter/src/app_providers.dart';
import 'package:poppflutter/src/home/home_screen.dart';
import 'package:poppflutter/src/login/login_screen.dart';
import 'package:poppflutter/src/login/sign_up_congrats_screen.dart';
import 'package:poppflutter/src/login/signup_screen.dart';
import 'package:poppflutter/src/splash/splash_screen.dart';
import 'package:poppflutter/src/theme/theme_notifier.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        );
      },
    );
  }
}
