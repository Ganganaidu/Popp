// constants.dart
class Constants {
  const Constants._();

  static const String appName = 'POPP';

  static const String _appId = 'popp-71efb'; // Hardcoded appId
  static const String basePath = 'artifacts/$_appId/public/data';
  static const String userPath = '$basePath/users';
  static const String userToUserChatPath = '$basePath/user_to_user_chats';
  static const String agentToUserChatPath = '$basePath/agent_user_chats';
  static const String productsPath = '$basePath/products';
  static const String adsPath = '$basePath/ads';

  static const String home = 'Home';
  static const String rides = 'Rides';
  static const String routes = 'Routes';
  static const String chat = 'Chat';
  static const String help = 'Help';
  static const String explore = 'Explore';

  static const String privacyLink =
      'https://popp-71efb.web.app/privacy-policy.html';
  static const String contactNumber = '+91 995 9958 899';
  static const String contactEmail = 'preownedpremiumproducts@gmail.com';
  // Keep agentUserId consistent with Firestore rules
  static const String agentUserId = 'XsKNJMeiR2NuaLslm428EWL6zOv1';

  static const bool hideRoutes = true;
  static const bool hideRides = true;
}
