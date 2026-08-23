import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../login/model/user_data_model.dart';
import '../utils/product_content_data.dart';
import '../utils/product_utils.dart';
import '../widgets/app_dialogs.dart';

/// Central registry of go_router path strings.
///
/// Route paths live here (not scattered as string literals) so call sites and
/// the [GoRouter] configuration in `app_router.dart` share one source of truth.
/// Prefer the typed helpers on [AppNavigation] over passing these strings to
/// `context.push` by hand.
class AppRoutes {
  AppRoutes._();

  static const String loading = '/';
  static const String intro = '/intro';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String finalCongrats = '/finalCongrats';
  static const String blocking = '/blocking';

  // Products feature
  static const String productDetail = '/product-detail';
  static const String categoryDetail = '/category-detail';

  // Services feature
  static const String listServiceCategory = '/list-service-category';
  static const String listServiceForm = '/list-service-form';
  static const String serviceListing = '/service-listing';
  static const String serviceDetail = '/service-detail';
  static const String sellBike = '/sell-bike';
  static const String sellAccessories = '/sell-accessories';

  // Settings / profile
  static const String moreMenu = '/more-menu';
  static const String favorites = '/favorites';
  static const String search = '/search';
  static const String myListings = '/my-listings';
  static const String aboutUs = '/about-us';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String admin = '/admin';

  // Chat
  static const String userChat = '/chat/user';
  static const String agentUserChat = '/chat/agent-user';
  static const String chatList = '/chat/list';

  // Auth
  static const String forgotPassword = '/forgot-password';
  static const String verification = '/verification';
  static const String registerSubscribe = '/register-subscribe';
}

/// Typed argument payload for the product detail route, passed via
/// [GoRouterState.extra]. Using a dedicated class (instead of a raw map or a
/// positional record) keeps the router builder and every call site honest
/// about what the screen needs.
class ProductDetailArgs {
  final Map<String, dynamic> product;
  final bool showStatus;

  const ProductDetailArgs({required this.product, this.showStatus = false});
}

/// Typed argument payload for the category detail route.
class CategoryDetailArgs {
  final String categoryName;
  final String? subCategory;
  final List<Map<String, dynamic>>? products;
  final List<String> filters;

  const CategoryDetailArgs({
    required this.categoryName,
    required this.subCategory,
    required this.products,
    required this.filters,
  });

  /// Builds args for a category, picking the correct filter set (bike vs.
  /// generic) the same way the legacy `navigateToCategoryPage` helper did.
  factory CategoryDetailArgs.forCategory(
    String categoryName, {
    String? subCategory,
    List<Map<String, dynamic>>? products,
  }) {
    return CategoryDetailArgs(
      categoryName: categoryName,
      subCategory: subCategory,
      products: products,
      filters: categoryName.contains(ProductUtils.premiumBikes)
          ? bikeFilters
          : categoryFilters,
    );
  }
}

/// Typed argument payload for the service listing route.
class ServiceListingArgs {
  final String category;
  final String? subCategory;

  const ServiceListingArgs({required this.category, this.subCategory});
}

/// Typed argument payload for the service detail route.
class ServiceDetailArgs {
  final Map<String, dynamic> serviceData;
  final String category;

  const ServiceDetailArgs({required this.serviceData, required this.category});
}

/// Typed argument payload for the "list a service" form route.
class ListServiceFormArgs {
  final String? category;
  final Map<String, dynamic>? existingData;

  const ListServiceFormArgs({this.category, this.existingData});
}

/// Typed argument payload for the sell-bike / sell-accessories product forms.
class SellProductFormArgs {
  final Map<String, dynamic>? existingData;

  const SellProductFormArgs({this.existingData});
}

/// Typed argument payload for a user-to-user chat.
class UserChatArgs {
  final String receiverUserName;
  final String receiverUserID;
  final String productId;
  final String productTitle;

  const UserChatArgs({
    required this.receiverUserName,
    required this.receiverUserID,
    required this.productId,
    required this.productTitle,
  });
}

/// Typed argument payload for an agent-to-user support chat.
class AgentUserChatArgs {
  final String agentUserId;
  final String currentUserId;

  const AgentUserChatArgs({
    required this.agentUserId,
    required this.currentUserId,
  });
}

/// Typed argument payload for the email/OTP verification screen.
class VerificationArgs {
  final UserData? userData;
  final String email;
  final String password;
  final bool isFromSignUp;

  const VerificationArgs({
    required this.userData,
    required this.email,
    required this.password,
    required this.isFromSignUp,
  });
}

/// Typed navigation helpers layered on go_router.
///
/// These replace the imperative `Navigator.push(MaterialPageRoute(...))` helpers
/// from the legacy `nav_router.dart`. Migrated call sites should use these
/// instead of building routes by hand.
extension AppNavigation on BuildContext {
  /// Opens the product detail screen for an already-loaded [product] map.
  Future<T?> pushProductDetail<T>(
    Map<String, dynamic> product, {
    bool showStatus = false,
  }) {
    return push<T>(
      AppRoutes.productDetail,
      extra: ProductDetailArgs(product: product, showStatus: showStatus),
    );
  }

  /// Opens the category listing screen. When [products] is null the screen
  /// fetches the category's products itself.
  Future<T?> pushCategoryDetail<T>(CategoryDetailArgs args) {
    return push<T>(AppRoutes.categoryDetail, extra: args);
  }

  // --- Services feature ---------------------------------------------------

  /// Opens the "select a category to list a service" grid.
  Future<T?> pushListServiceCategory<T>() {
    return push<T>(AppRoutes.listServiceCategory);
  }

  /// Opens the list-a-service form, optionally pre-seeded for a [category] or
  /// an [existingData] edit.
  Future<T?> pushListServiceForm<T>({
    String? category,
    Map<String, dynamic>? existingData,
  }) {
    return push<T>(
      AppRoutes.listServiceForm,
      extra: ListServiceFormArgs(category: category, existingData: existingData),
    );
  }

  /// Opens the service listing for [category]. Pass [replace] to swap the
  /// current route (used right after submitting a new listing).
  Future<T?> pushServiceListing<T>(
    String category, {
    String? subCategory,
    bool replace = false,
  }) {
    final args = ServiceListingArgs(category: category, subCategory: subCategory);
    if (replace) {
      pushReplacement(AppRoutes.serviceListing, extra: args);
      return Future<T?>.value();
    }
    return push<T>(AppRoutes.serviceListing, extra: args);
  }

  /// Opens the detail screen for a service.
  Future<T?> pushServiceDetail<T>(
    Map<String, dynamic> serviceData,
    String category,
  ) {
    return push<T>(
      AppRoutes.serviceDetail,
      extra: ServiceDetailArgs(serviceData: serviceData, category: category),
    );
  }

  /// Opens the sell-your-bike product form.
  Future<T?> pushSellBike<T>({Map<String, dynamic>? existingData}) {
    return push<T>(
      AppRoutes.sellBike,
      extra: SellProductFormArgs(existingData: existingData),
    );
  }

  /// Opens the sell-your-accessories product form.
  Future<T?> pushSellAccessories<T>({Map<String, dynamic>? existingData}) {
    return push<T>(
      AppRoutes.sellAccessories,
      extra: SellProductFormArgs(existingData: existingData),
    );
  }

  // --- Settings / profile -------------------------------------------------

  Future<T?> pushMoreMenu<T>() => push<T>(AppRoutes.moreMenu);
  Future<T?> pushFavorites<T>() => push<T>(AppRoutes.favorites);
  Future<T?> pushSearch<T>() => push<T>(AppRoutes.search);
  Future<T?> pushAboutUs<T>() => push<T>(AppRoutes.aboutUs);
  Future<T?> pushProfileDetails<T>() => push<T>(AppRoutes.profile);
  Future<T?> pushNotifications<T>() => push<T>(AppRoutes.notifications);
  Future<T?> pushAdminDashboard<T>() => push<T>(AppRoutes.admin);

  /// Opens the user's listings. Pass [replace] to swap the current route
  /// (used right after submitting a new listing).
  Future<T?> pushMyListings<T>({bool replace = false}) {
    if (replace) {
      pushReplacement(AppRoutes.myListings);
      return Future<T?>.value();
    }
    return push<T>(AppRoutes.myListings);
  }

  // --- Chat ---------------------------------------------------------------

  Future<T?> pushUserChat<T>(UserChatArgs args) =>
      push<T>(AppRoutes.userChat, extra: args);

  Future<T?> pushAgentUserChat<T>(String agentUserId, String currentUserId) =>
      push<T>(AppRoutes.agentUserChat,
          extra: AgentUserChatArgs(
              agentUserId: agentUserId, currentUserId: currentUserId));

  Future<T?> pushChatList<T>(String agentId) =>
      push<T>(AppRoutes.chatList, extra: agentId);

  // --- Auth ---------------------------------------------------------------

  Future<T?> pushForgotPassword<T>(bool isChangePassword) =>
      push<T>(AppRoutes.forgotPassword, extra: isChangePassword);

  Future<T?> pushVerification<T>(VerificationArgs args) =>
      push<T>(AppRoutes.verification, extra: args);

  /// Register-and-subscribe replaces the current route (post-verification step).
  Future<T?> pushRegisterSubscribe<T>(UserData userData) {
    pushReplacement(AppRoutes.registerSubscribe, extra: userData);
    return Future<T?>.value();
  }

  /// Sends the user to the login screen, clearing the current stack (the
  /// router's redirect owns everything above it).
  void goLogin() => go(AppRoutes.login);

  /// Sends the user to the home shell.
  void goHome() => go(AppRoutes.home);

  /// Sends the user to the signup screen.
  void goSignup() => go(AppRoutes.signup);

  /// Sends the user to the post-signup congrats screen.
  void goFinalCongrats() => go(AppRoutes.finalCongrats);

  /// Shows the "please log in" dialog, then routes to login on confirm.
  void showLoginPrompt(String message) {
    AppDialogs.showUserLoginDialog(this, () {
      if (mounted) goLogin();
    }, message);
  }
}
