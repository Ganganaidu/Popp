import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:popp/src/utils/app_loger.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  // Private constructor
  RemoteConfigService._(this._remoteConfig);

  // Singleton instance
  static RemoteConfigService? _instance;

  static Future<RemoteConfigService> getInstance() async {
    if (_instance == null) {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        // Use a low minimum fetch interval for testing.
        // In production, you'll want a higher value (e.g., 1 hour)
        minimumFetchInterval: const Duration(seconds: 30),
      ));
      // Set default values in case fetching fails
      await remoteConfig.setDefaults({
        'is_subscription_feature_enabled': false,
      });
      _instance = RemoteConfigService._(remoteConfig);
    }
    return _instance!;
  }

  // Getter for your feature flag
  bool get isSubscriptionFeatureEnabled =>
      _remoteConfig.getBool('is_subscription_feature_enabled');

  // Fetch the latest values from the server
  Future<void> fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      AppLogger.e("Remote Config fetch failed: $e");
    }
  }
}
