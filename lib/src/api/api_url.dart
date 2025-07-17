class ApiUrl {
  static String baseUrl = "https://popp-71efb.web.app";

  static const String _appId = 'popp-71efb'; // Hardcoded appId
  static const String basePath = 'artifacts/$_appId/public/data';
  static const String userPath = '$basePath/users';
  static const String userToUserChatPath = '$basePath/user_to_user_chats';
  static const String agentToUserChatPath = '$basePath/agent_user_chats';
  static const String productsPath = '$basePath/products';
  static const String adsPath = '$basePath/ads';
  static const String servicePath = '$basePath/services';

  static const String privacyLink =
      'https://popp-71efb.web.app/privacy-policy.html';

  // Default placeholder image
  static const String defaultPlaceholderImage =
      'https://images.unsplash.com/photo-1638003299152-dd1e3bf81fa5?q=80&w=2242&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
}
