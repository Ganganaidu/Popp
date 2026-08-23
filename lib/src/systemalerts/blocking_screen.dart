import 'dart:io' show Platform;
import '../navigation/app_routes.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:popp/src/systemalerts/system_alerts_api_services.dart';
import 'package:popp/src/utils/app_constants.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'message_data.dart';
import 'package:url_launcher/url_launcher.dart';

class BlockingScreen extends StatelessWidget {
  final SystemMessage systemMessage;

  const BlockingScreen({super.key, required this.systemMessage});

  // Helper: open the app store / play store for our app
  Future<void> _openStore() async {
    const packageId = Constants.appBundleId;
    try {
      if (Platform.isAndroid) {
        // Try opening Play Store app first, then fallback to web
        final marketUri = Uri.parse('market://details?id=$packageId');
        if (!await launchUrl(marketUri, mode: LaunchMode.externalApplication)) {
          final webUri = Uri.parse(
              'https://play.google.com/store/apps/details?id=$packageId');
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      } else if (Platform.isIOS) {
        // We don't have the numeric App Store id in constants; search by app name as a fallback
        final webUri = Uri.parse(
            'https://apps.apple.com/search?term=${Uri.encodeComponent(Constants.appName)}');
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to web play store link for other platforms
        final webUri = Uri.parse(
            'https://play.google.com/store/apps/details?id=$packageId');
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // ignore errors when opening store; user can manually update
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isHighPriority =
        systemMessage.priority == MessagePriority.high.name;
    final bool isAppUpdate =
        systemMessage.priority == MessagePriority.appUpdate.name;
    final SystemAlertsApiServices systemAlertsApiServices =
        SystemAlertsApiServices();

    AppLogger.d("message : ${systemMessage.priority}");

    return PopScope(
      canPop: !isHighPriority && !isAppUpdate,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1110), // Dark background
        body: SafeArea(
          child: Column(
            children: [
              // 1. Logo Header
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Biker",
                        style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFF2ECC71),
                            // Green color
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Orbitron',
                            fontStyle: FontStyle.italic)),
                    Text("verse",
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Orbitron',
                            fontStyle: FontStyle.italic))
                  ],
                ),
              ),

              const Spacer(),

              // 2. Glowing Rocket Icon
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2ECC71).withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    color: Colors.black,
                    size: 60,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // 3. Title
              Text(
                isAppUpdate
                    ? "UPDATE REQUIRED"
                    : getPriorityMessageTitle(systemMessage.priority)
                        .toUpperCase(),
                style: const TextStyle(
                  fontSize: 25,
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // 4. "What's New" / Message Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D1C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2ECC71).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.layers_outlined,
                              color: Color(0xFF2ECC71),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "WHAT'S NEW",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        systemMessage.message,
                        style: const TextStyle(
                          color: Colors.grey,
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 5. Version info (if update)
              if (isAppUpdate)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232625),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "REQUIRED VERSION: ${systemMessage.versionCode ?? 'LATEST'}",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              if (isAppUpdate)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    'Tap "Open store" to open the store. The app will quit so you can install the update. Re-open the app after installing to continue.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const Spacer(),

              // 6. Action Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      foregroundColor: Colors.black,
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (isAppUpdate) {
                        await _openStore();
                        SystemNavigator.pop();
                      } else {
                        // For non-update messages, save and allow dismissing
                        await systemAlertsApiServices
                            .saveMessageId(systemMessage);
                        if (!isHighPriority) {
                          if (context.mounted) {
                            context.goHome();
                          }
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isAppUpdate
                              ? "OPEN STORE"
                              : getButtonText(systemMessage.priority)
                                  .toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                        if (isAppUpdate) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            weight: 100,
                          )
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
