import 'package:flutter/material.dart';
import 'package:popp/src/settings/settings_screen.dart';
import 'package:popp/src/utils/app_constants.dart';

import '../chat/agent_chat_list_screen.dart';
import '../chat/generic_chat_screen.dart';
import '../login/forgot_password_screen.dart';
import '../models/product.dart';
import '../products/product_detail_screen.dart';
import '../services/accessories/sell_your_accessories.dart';
import '../services/bikes/sell_your_bike.dart';
import '../services/listservices/list_service_screen.dart';
import '../services/listservices/service_listing_screen.dart';

// Define routes for each tab
final Map<String, WidgetBuilder> routes = {
  '/productDetails': (context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    return ProductDetailScreen(product: product);
  },
};

// call this from Dashboard_list_widget
void onProductTap(BuildContext context, Product product) {
  // NavHelper().updateAppBarTitle?.call(product.getTitle());
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProductDetailScreen(product: product),
    ),
  );
}

void onListYourServiceTap(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ListServiceScreen(),
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

void onForgotPasswordTap(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
  );
}

void onChatTap(
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
          const AgentChatListScreen(agentId: Constants.agentUserId),
    ),
  );
}

void onServiceListingTap(BuildContext context, String category) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ServiceListingScreen(category: category),
    ),
  );
}
