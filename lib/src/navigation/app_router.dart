import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../deeplink/product_service_deep_link.dart';
import '../home/home_screen.dart';
import '../login/login_screen.dart';
import '../login/sign_up_congrats_screen.dart';
import '../login/signup_screen.dart';
import '../screens/intro_screen.dart';
import '../systemalerts/blocking_screen.dart';
import '../systemalerts/message_data.dart';
import '../systemalerts/system_alerts_api_services.dart';
import '../utils/app_loger.dart';

/// The app's single root [Navigator] key, shared with legacy imperative
/// `Navigator.push` call sites (e.g. deep-link handling in
/// product_service_deep_link.dart) that haven't been migrated onto explicit
/// go_router routes yet. A plain `Navigator.push(MaterialPageRoute(...))`
/// against this key continues to work layered on top of go_router — the two
/// mechanisms share the same underlying Navigator.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Publicly reachable without an authenticated session.
const Set<String> _publicRoutes = {'/intro', '/login', '/signup'};

final SystemAlertsApiServices _systemAlertsApiServices =
    SystemAlertsApiServices();

/// Cleared on every sign-in/sign-out so a newly active blocking message is
/// re-checked once per session rather than on every navigation.
bool _blockingMessageCheckedThisSession = false;

final GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/',
  debugLogDiagnostics: false,
  refreshListenable:
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  redirect: _redirect,
  observers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)],
  routes: [
    GoRoute(path: '/', builder: (context, state) => const _LoadingScreen()),
    GoRoute(path: '/intro', builder: (context, state) => const IntroScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/finalCongrats',
      builder: (context, state) => const SignUpCongratsScreen(),
    ),
    GoRoute(
      path: '/blocking',
      builder: (context, state) =>
          BlockingScreen(systemMessage: state.extra as SystemMessage),
    ),
  ],
);

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final String location = state.matchedLocation;

  // Web skips both the intro carousel and login entirely.
  if (kIsWeb) {
    if (location == '/' || location == '/intro' || location == '/login') {
      return '/home';
    }
    return null;
  }

  if (location != '/intro') {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;
    if (!hasSeenIntro) return '/intro';
  }

  final user = FirebaseAuth.instance.currentUser;
  final bool authenticated = user != null && user.emailVerified;

  if (!authenticated) {
    _blockingMessageCheckedThisSession = false;
    if (!_publicRoutes.contains(location)) return '/login';
    return null;
  }

  // Authenticated from here on. Bounce away from the intro/auth screens.
  if (_publicRoutes.contains(location)) {
    final pending = PendingDeepLink.uri;
    if (pending != null) {
      PendingDeepLink.uri = null;
      // Fire-and-forget: this pushes its own screen once resolved, layered
      // on top of whatever the redirect below lands on.
      unawaited(openDeepLinkUri(pending));
    }
    return '/home';
  }

  if (location == '/blocking') return null;

  if (!_blockingMessageCheckedThisSession) {
    _blockingMessageCheckedThisSession = true;
    try {
      final message = await _systemAlertsApiServices.getPriorityMessage();
      if (message != null && message.isActive) {
        final shouldShow =
            await _systemAlertsApiServices.shouldShowMessage(message);
        if (shouldShow) {
          return '/blocking';
        }
      }
    } catch (e) {
      AppLogger.e('Error checking priority system message: $e');
    }
  }

  return null;
}

/// Bridges a [Stream] (Firebase auth state changes) into go_router's
/// [Listenable]-based `refreshListenable`, so the router re-evaluates
/// [_redirect] whenever the user signs in or out. This is the standard
/// go_router pattern for stream-driven refresh (not shipped by the package
/// itself).
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      _blockingMessageCheckedThisSession = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
