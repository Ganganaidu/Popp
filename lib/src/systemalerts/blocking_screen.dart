import 'dart:io' show Platform;
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

  @override
  Widget build(BuildContext context) {
    final bool isHighPriority =
        systemMessage.priority == MessagePriority.high.name;
    final SystemAlertsApiServices systemAlertsApiServices =
        SystemAlertsApiServices();

    AppLogger.d("message : ${systemMessage.priority}");
    // Helper: open the app store / play store for our app
    Future<void> openStore() async {
      const packageId = Constants.appBundleId;
      try {
        if (Platform.isAndroid) {
          // Try opening Play Store app first, then fallback to web
          final marketUri = Uri.parse('market://details?id=$packageId');
          if (!await launchUrl(marketUri,
              mode: LaunchMode.externalApplication)) {
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

    return PopScope(
      canPop: !isHighPriority,
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                Row(children: [
                  Text("Biker",
                      style: TextStyle(
                          fontSize: 25,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbitron')),
                  const Text("verse",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbitron'))
                ]),
              ],
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    isHighPriority
                        ? Icons.lock_outline_rounded
                        : Icons.info_outline_rounded,
                    size: 80,
                    color: isHighPriority
                        ? Colors.redAccent
                        : Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    getPriorityMessageTitle(systemMessage.priority),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    systemMessage.message,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // If this is an app update, show required version and instructions inline
                  if (systemMessage.priority ==
                      MessagePriority.appUpdate.name) ...[
                    Text(
                      'Required version: ${systemMessage.versionCode ?? 'latest'}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap "${getButtonText(systemMessage.priority)}" to open the store. '
                      'The app will quit so you can install the update. Re-open the app after installing to continue.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    onPressed: () async {
                      // For appUpdate messages: open the store and quit the app so the user can update.
                      if (systemMessage.priority ==
                          MessagePriority.appUpdate.name) {
                        await openStore();
                        // Quit the app. On Android this will close the activity;
                        // on iOS programmatic exit is discouraged but we call pop.
                        SystemNavigator.pop();
                        return;
                      }

                      // For non-update messages, save and allow dismissing low priority messages
                      await systemAlertsApiServices
                          .saveMessageId(systemMessage);
                      if (systemMessage.priority == MessagePriority.low.name) {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    child: Text(getButtonText(systemMessage.priority)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
