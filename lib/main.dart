import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:poppflutter/src/splash/splash_screen.dart';
import 'package:poppflutter/src/login/login_screen.dart';
import 'package:poppflutter/src/login/signup_screen.dart';
import 'package:poppflutter/src/home/home_screen.dart';
import 'src/theme/theme.dart';
import 'src/firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Popp',
      themeMode: ThemeMode.light,
      theme: AppTheme.lightThemeData,
      darkTheme: AppTheme.darkThemeData,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
