import 'package:flutter/material.dart';
import 'package:popp/src/login/model/user_data_model.dart';
import 'package:popp/src/settings/about_us.dart';
import 'package:popp/src/settings/favorites_screen.dart';
import 'package:popp/src/settings/settings_screen.dart';
import 'package:popp/src/utils/app_constants.dart';

import '../admin/admin_dashboard_screen.dart';
import '../chat/agent_chat_list_screen.dart';
import '../chat/generic_chat_screen.dart';
import '../home/search_screen.dart';
import '../login/forgot_password_screen.dart';
import '../login/register_and_subscribe_screen.dart';
import '../login/verification_screen.dart';
import '../products/category_detail_screen.dart';
import '../products/product_detail_screen.dart';
import '../services/accessories/sell_your_accessories.dart';
import '../services/bikes/sell_your_bike.dart';
import '../services/listservices/list_service_form_screen.dart';
import '../services/listservices/service_detail_screen.dart';
import '../services/listservices/service_listing_screen.dart';
import '../settings/my_listings_screen.dart';
import '../settings/profile_details_screen.dart';
import '../utils/app_loger.dart';
import '../utils/product_content_data.dart';
import '../utils/product_utils.dart';
import '../widgets/app_dialogs.dart';

// Define routes for each tab
final Map<String, WidgetBuilder> routes = {
  '/productDetails': (context) {
    final product =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return ProductDetailScreen(productJson: product);
  },
};

// call this from Dashboard_list_widget
void onProductDetailsTap(BuildContext context, Map<String, dynamic> product,
    [bool showStatus = false]) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProductDetailScreen(
        productJson: product,
        showStatus: showStatus,
      ),
    ),
  );
}

void onListYourServiceTap(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ListServiceFormScreen(),
    ),
  );
}

void onSelleYourBikeTap(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SellYourBike(),
    ),
  );
}

void onSellYourAccessoriesTap(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SellYourAccessories(),
    ),
  );
}

void onSettingsTap(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SettingsScreen(),
    ),
  );
}

void onFavScreenTap(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const FavoritesScreen(),
    ),
  );
}

void onSearchTap(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SearchScreen(),
    ),
  );
}

void onMyListingScreenTap(BuildContext context, bool isReplacement) {
  if (isReplacement) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MyListingsScreen(),
      ),
    );
    return;
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MyListingsScreen(),
    ),
  );
}

void onForgotPasswordTap(BuildContext context, bool isChangePassword) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(
              isChangePassword: isChangePassword,
            )),
  );
}

void onUserToUserChatTap(
    BuildContext context, String receiverUserName, String receiverUserID) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GenericChatScreen(
        receiverUserName: receiverUserName,
        receiverUserID: receiverUserID,
        chatType: 'user_to_user',
      ),
    ),
  );
}

// Chat with Agent
void onAgentToUserChatTap(
    BuildContext context, String agentUserId, String currentUserId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GenericChatScreen(
        receiverUserName: "Agent (Support)",
        receiverUserID: currentUserId,
        // Current user's ID is the 'user' in agent-user chat
        chatType: 'agent_user',
        agentId: agentUserId,
      ),
    ),
  );
}

void onAgentChatTap(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          const AgentChatListScreen(agentId: Constants.adminUserId),
    ),
  );
}

void navigateToCategoryPage(BuildContext context, String categoryName,
    String? subCategory, List<Map<String, dynamic>>? products) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CategoryDetailScreen(
        categoryName: categoryName,
        subCategory: subCategory,
        products: products,
        filters: categoryName.contains(ProductUtils.premiumBikes)
            ? bikeFilters
            : categoryFilters,
      ),
    ),
  );
}

void onServiceListingTap(BuildContext context, String category,
    String? subCategory, bool isReplacement) {
  AppLogger.d("Form submission navigate to : $category > $subCategory");
  if (isReplacement) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceListingScreen(
          category: category,
          subCategory: subCategory,
        ),
      ),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ServiceListingScreen(category: category, subCategory: subCategory),
      ),
    );
  }
}

void onRegisterAndSubscribeTap(BuildContext context, UserData userData) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => RegisterAndSubscribeScreen(userData: userData),
    ),
  );
}

void onServiceDetailsScreenTap(
    BuildContext context, Map<String, dynamic> serviceData, String category) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ServiceDetailScreen(
        serviceData: serviceData,
        category: category,
      ),
    ),
  );
}

void onAdminDashboardTap(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AdminDashboardScreen(),
    ),
  );
}

void onLoginTap(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
}

onLoginClicked(BuildContext context, String message) {
  AppDialogs.showUserLoginDialog(context, () {
    if (context.mounted) {
      onLoginTap(context);
    }
  }, message);
}

void onVerificationScreenTap(BuildContext context, UserData? userData,
    String email, String password, bool isFromSignUp) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => VerificationScreen(
        userData: userData,
        email: email,
        password: password,
        isFromSignUp: isFromSignUp,
      ),
    ),
  );
}

void onAboutUsTap(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AboutUsScreen(),
    ),
  );
}

void onProfileDetailsTap(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ProfileDetailsScreen(),
    ),
  );
}
