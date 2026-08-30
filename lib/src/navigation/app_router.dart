import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin/admin_dashboard_screen.dart';
import '../chat/chat_list_screen.dart';
import '../chat/generic_chat_screen.dart';
import '../deeplink/product_service_deep_link.dart';
import '../home/dashboard_screen.dart';
import '../home/explore_screen.dart';
import '../home/home_shell.dart';
import '../home/search_screen.dart';
import '../login/forgot_password_screen.dart';
import '../login/login_screen.dart';
import '../login/model/user_data_model.dart';
import '../login/register_and_subscribe_screen.dart';
import '../login/verification_screen.dart';
import '../login/sign_up_congrats_screen.dart';
import '../login/signup_screen.dart';
import '../products/repository/product_repository.dart';
import '../products/ui/category_detail_screen.dart';
import '../products/ui/product_detail_screen.dart';
import '../products/viewmodel/category_products_viewmodel.dart';
import '../products/viewmodel/product_detail_viewmodel.dart';
import '../screens/intro_screen.dart';
import '../services/accessories/sell_your_accessories.dart';
import '../services/bikes/sell_your_bike.dart';
import '../services/listservices/list_service_category_screen.dart';
import '../services/listservices/list_service_form_screen.dart';
import '../services/listservices/service_detail_screen.dart';
import '../services/listservices/service_listing_screen.dart';
import '../services/repository/service_repository.dart';
import '../services/viewmodel/service_listing_viewmodel.dart';
import '../settings/about_us.dart';
import '../settings/favorites_screen.dart';
import '../settings/more_screen.dart';
import '../settings/my_listings_screen.dart';
import '../settings/profile_details_screen.dart';
import '../notifications/notification_screen.dart';
import '../utils/app_constants.dart';
import '../systemalerts/blocking_screen.dart';
import '../systemalerts/message_data.dart';
import '../systemalerts/system_alerts_api_services.dart';
import '../utils/app_loger.dart';
import 'app_routes.dart';

/// The app's single root [Navigator] key, shared with legacy imperative
/// `Navigator.push` call sites (e.g. deep-link handling in
/// product_service_deep_link.dart) that haven't been migrated onto explicit
/// go_router routes yet. A plain `Navigator.push(MaterialPageRoute(...))`
/// against this key continues to work layered on top of go_router — the two
/// mechanisms share the same underlying Navigator.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Publicly reachable without an authenticated session.
const Set<String> _publicRoutes = {'/intro', '/login', '/signup', '/forgot-password', '/verification'};

final SystemAlertsApiServices _systemAlertsApiServices =
    SystemAlertsApiServices();

/// Cleared on every sign-in/sign-out so a newly active blocking message is
/// re-checked once per session rather than on every navigation.
bool _blockingMessageCheckedThisSession = false;

/// Set to true when the user taps "Skip for now" on the login screen so the
/// redirect allows unauthenticated access to the home shell.
bool _guestModeActive = false;

/// Call this before navigating home as a guest (unauthenticated).
void enableGuestMode() => _guestModeActive = true;

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
    // Bottom-nav shell: four branches, each with its own navigator. Detail
    // screens (product/service/etc.) are top-level routes below, so they push
    // full-screen over the shell — matching the pre-migration behaviour.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          HomeShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const DashboardScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/chat',
            builder: (context, state) =>
                const ChatListScreen(agentId: Constants.adminUserId),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/more',
            builder: (context, state) => const MoreScreen(),
          ),
        ]),
      ],
    ),
    GoRoute(
      path: '/finalCongrats',
      builder: (context, state) => const SignUpCongratsScreen(),
    ),
    GoRoute(
      path: '/blocking',
      builder: (context, state) =>
          BlockingScreen(systemMessage: state.extra as SystemMessage),
    ),
    // --- Products feature -------------------------------------------------
    // Screen-scoped viewmodels are provided here so their lifecycle matches
    // the pushed screen and they are seeded with the route's typed args.
    GoRoute(
      path: AppRoutes.productDetail,
      builder: (context, state) {
        final args = state.extra as ProductDetailArgs;
        return ChangeNotifierProvider(
          create: (_) => ProductDetailViewModel(
            repository: ProductRepository(),
            product: args.product,
          ),
          child: const ProductDetailScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.categoryDetail,
      builder: (context, state) {
        final args = state.extra as CategoryDetailArgs;
        return ChangeNotifierProvider(
          create: (_) => CategoryProductsViewModel(ProductRepository()),
          child: CategoryDetailScreen(args: args),
        );
      },
    ),
    // --- Services feature -------------------------------------------------
    GoRoute(
      path: AppRoutes.listServiceCategory,
      builder: (context, state) => const ListServiceCategoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.listServiceForm,
      builder: (context, state) {
        final args = state.extra as ListServiceFormArgs?;
        return ListServiceFormScreen(
          category: args?.category,
          existingData: args?.existingData,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.serviceListing,
      builder: (context, state) {
        final args = state.extra as ServiceListingArgs;
        return ChangeNotifierProvider(
          create: (_) => ServiceListingViewModel(ServiceRepository()),
          child: ServiceListingScreen(
            category: args.category,
            subCategory: args.subCategory,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.serviceDetail,
      builder: (context, state) {
        final args = state.extra as ServiceDetailArgs;
        return ServiceDetailScreen(
          serviceData: args.serviceData,
          category: args.category,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.sellBike,
      builder: (context, state) {
        final args = state.extra as SellProductFormArgs?;
        return SellYourBike(existingData: args?.existingData);
      },
    ),
    GoRoute(
      path: AppRoutes.sellAccessories,
      builder: (context, state) {
        final args = state.extra as SellProductFormArgs?;
        return SellYourAccessories(existingData: args?.existingData);
      },
    ),
    // --- Settings / profile -----------------------------------------------
    GoRoute(
      path: AppRoutes.moreMenu,
      builder: (context, state) => const MoreScreen(),
    ),
    GoRoute(
      path: AppRoutes.favorites,
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: AppRoutes.myListings,
      builder: (context, state) => const MyListingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.aboutUs,
      builder: (context, state) => const AboutUsScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileDetailsScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: AppRoutes.admin,
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    // --- Chat -------------------------------------------------------------
    GoRoute(
      path: AppRoutes.userChat,
      builder: (context, state) {
        final args = state.extra as UserChatArgs;
        return GenericChatScreen(
          receiverUserName: args.receiverUserName,
          receiverUserID: args.receiverUserID,
          productId: args.productId,
          productTitle: args.productTitle,
          chatType: 'user_to_user',
        );
      },
    ),
    GoRoute(
      path: AppRoutes.agentUserChat,
      builder: (context, state) {
        final args = state.extra as AgentUserChatArgs;
        return GenericChatScreen(
          receiverUserName: 'Agent (Support)',
          receiverUserID: args.currentUserId,
          chatType: 'agent_user',
          productTitle: 'Support Chat',
          productId: '',
          agentId: args.agentUserId,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.chatList,
      builder: (context, state) =>
          ChatListScreen(agentId: state.extra as String),
    ),
    // --- Auth -------------------------------------------------------------
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) =>
          ForgotPasswordScreen(isChangePassword: state.extra as bool? ?? false),
    ),
    GoRoute(
      path: AppRoutes.verification,
      builder: (context, state) {
        final args = state.extra as VerificationArgs;
        return VerificationScreen(
          userData: args.userData,
          email: args.email,
          password: args.password,
          isFromSignUp: args.isFromSignUp,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.registerSubscribe,
      builder: (context, state) =>
          RegisterAndSubscribeScreen(userData: state.extra as UserData),
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

  if (location != '/intro') {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;
    if (!hasSeenIntro) return '/intro';
  }

  final user = FirebaseAuth.instance.currentUser;
  final bool authenticated = user != null && user.emailVerified;

  if (!authenticated) {
    _blockingMessageCheckedThisSession = false;
    if (!_publicRoutes.contains(location) && !_guestModeActive) return '/login';
    return null;
  }

  // Authenticated from here on. Bounce away from the transient loading
  // placeholder ('/') and the intro/auth screens onto the home shell.
  if (location == AppRoutes.loading || _publicRoutes.contains(location)) {
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
    _subscription = stream.asBroadcastStream().listen((user) {
      _blockingMessageCheckedThisSession = false;
      if (user == null) _guestModeActive = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
