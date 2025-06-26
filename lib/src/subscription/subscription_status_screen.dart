import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart'; // For ProductDetails
import 'package:popp/src/subscription/subscription_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // For deep linking

import '../utils/build_extensions.dart'; // Assuming your build_extensions for styling
import 'subscribe_page_widget.dart'; // Import SubscribePageWidget

class SubscriptionStatusScreen extends StatefulWidget {
  final ProductDetails subscribedProduct;
  final String userUid;

  const SubscriptionStatusScreen({
    super.key,
    required this.subscribedProduct,
    required this.userUid,
  });

  @override
  State<SubscriptionStatusScreen> createState() =>
      _SubscriptionStatusScreenState();
}

class _SubscriptionStatusScreenState extends State<SubscriptionStatusScreen> {
  late ProductDetails _currentProduct;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.subscribedProduct;
  }

  Future<void> _refreshSubscription() async {
    // Use Provider to get the latest subscription info
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    await provider.checkSubscriptionStatus(widget.userUid);
    final String? subId = provider.currentSubscriptionId;
    final products = provider.products;
    if (subId != null) {
      final found = products.where((p) => p.id == subId);
      if (found.isNotEmpty) {
        setState(() {
          _currentProduct = found.first;
        });
      }
    }
  }

  // Helper method to launch the subscription management URL
  Future<void> _launchSubscriptionManagementUrl(BuildContext context) async {
    Uri url;
    if (Platform.isAndroid) {
      url = Uri.parse('https://play.google.com/store/account/subscriptions');
    } else if (Platform.isIOS) {
      // For iOS, deep link directly to the App Store subscriptions
      url = Uri.parse('https://apps.apple.com/account/subscriptions');
    } else {
      // Fallback for web/desktop, or show an error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Subscription management not supported on this platform.')),
      );
      return;
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${url.scheme} link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Subscription"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Subscription Card
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.blue.shade400, width: 2.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Wrap the title in Expanded to prevent overflow
                        Expanded(
                          child: Text(
                            _currentProduct.title,
                            style: context.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _currentProduct.description,
                      style: context.bodyLarge?.copyWith(
                        color:
                            theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Price and Active badge on the same row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price: ${_currentProduct.price}',
                          style: context.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade300),
                          ),
                          child: Text(
                            'Active',
                            style: context.bodyLarge?.copyWith(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Deep link to manage subscriptions
            Text(
              "To manage or cancel your subscription (e.g., downgrade, upgrade, or cancel auto-renewal), please visit your device's app store subscription settings:",
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _launchSubscriptionManagementUrl(context),
                icon: Icon(Platform.isAndroid ? Icons.store : Icons.store,
                    size: 24),
                label: Text(
                  Platform.isAndroid
                      ? "Go to Google Play Subscriptions"
                      : "Go to App Store Subscriptions",
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Option to change subscription (opens SubscribePageWidget as bottom sheet)
            Center(
              child: OutlinedButton(
                onPressed: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (sheetContext) {
                      return FractionallySizedBox(
                        heightFactor: 0.7,
                        child: SubscribePageWidget(
                          userUid: widget.userUid,
                          isFromSettings: true,
                        ),
                      );
                    },
                  );
                  // After closing, refresh subscription
                  await _refreshSubscription();
                },
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(color: theme.primaryColor, width: 1.5),
                ),
                child: Text(
                  "Change Subscription Plan",
                  style: TextStyle(fontSize: 16, color: theme.primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
