class ApiUrl {
  static String baseUrl = "https://bikerverse.in/";

  static const String _appId = 'popp-71efb'; // Hardcoded appId
  static const String userPath = 'users';
  static const String userToUserChatPath = 'user_to_user_chats';
  static const String agentToUserChatPath = 'agent_user_chats';
  static const String productsPath = 'products';
  static const String adsPath = 'ads';
  static const String servicePath = 'services';
  static const String globalMessagesPath = 'global_messages';

  static String privacyLink = '${baseUrl}privacy-policy.html';

  static String customersTermsLink = '${baseUrl}customers-terms.html';

  static String businessTermsLink = '${baseUrl}business-owners-terms.html';

  static String userAgreements = '${baseUrl}user-agreements.html';

  static String frequentlyAsked = '${baseUrl}Support.html';

  static String deleteAccountPolicy = '${baseUrl}delete-account.html';

  static String welcomePage = '${baseUrl}welcome.html';

  // Default placeholder image
  static const String defaultPlaceholderImage =
      'https://images.unsplash.com/photo-1638003299152-dd1e3bf81fa5?q=80&w=2242&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
}
