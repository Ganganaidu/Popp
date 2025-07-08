import 'package:flutter/material.dart';
import 'package:popp/src/settings/favorites_screen.dart';
import 'package:popp/src/login/model/user_data_model.dart';
import 'package:popp/src/settings/settings_screen.dart';
import 'package:popp/src/utils/app_constants.dart';

import '../admin/admin_dashboard_screen.dart';
import '../chat/agent_chat_list_screen.dart';
import '../chat/generic_chat_screen.dart';
import '../login/forgot_password_screen.dart';
import '../login/otp_screen.dart';
import '../login/register_and_subscribe_screen.dart';
import '../products/product_detail_screen.dart';
import '../services/accessories/sell_your_accessories.dart';
import '../services/bikes/sell_your_bike.dart';
import '../services/listservices/list_service_form_screen.dart';
import '../services/listservices/service_detail_screen.dart';
import '../services/listservices/service_listing_screen.dart';
import '../settings/my_listings_screen.dart';

// Define routes for each tab
final Map<String, WidgetBuilder> routes = {
  '/productDetails': (context) {
    final product =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return ProductDetailScreen(productJson: product);
  },
};

// call this from Dashboard_list_widget
void onProductDetailsTap(BuildContext context, Map<String, dynamic> product) {
  // NavHelper().updateAppBarTitle?.call(product.getTitle());
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProductDetailScreen(productJson: product),
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

void onMyListingScreenTap(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MyListingsScreen(),
    ),
  );
}

void onForgotPasswordTap(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
  );
}

void onOTPScreen(BuildContext context, String email, String password) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (_) => OTPScreen(email: email, password: password)),
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

void onServiceListingTap(
    BuildContext context, String category, bool isReplacement) {
  if (isReplacement) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceListingScreen(category: category),
      ),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceListingScreen(category: category),
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
