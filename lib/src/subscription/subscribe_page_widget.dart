import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart'; // This import should provide everything needed
import '../utils/app_loger.dart';
import 'subscription_provider.dart'; // Your provider class

class SubscribePageWidget extends StatefulWidget {
  final String userUid;
  final bool isFromSettings;

  const SubscribePageWidget({
    super.key,
    required this.userUid,
    this.isFromSettings = false,
  });

  @override
  State<SubscribePageWidget> createState() => _SubscribePageWidgetState();
}

class _SubscribePageWidgetState extends State<SubscribePageWidget> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<SubscriptionProvider>(context, listen: false);
      if (provider.purchaseError != null) {
        // provider.clearError(); // Uncomment if you add this method to your provider
      }
    });
  }

  // A helper method to show a SnackBar for errors.
  void _showErrorSnackBar(BuildContext context, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Helper widget for the promotional banner
  Widget _buildPromoBanner(BuildContext context) {
    return Positioned(
      top: 12,
      right: -40,
      child: Transform.rotate(
        angle: pi / 4.5,
        child: Container(
          color: Colors.green[700],
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 3),
          child: const Text(
            'PROMO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        // Listen for error changes and show a SnackBar
        if (provider.purchaseError != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorSnackBar(context, provider.purchaseError!);
            // provider.clearError(); // Optionally clear the error in the provider after showing it
          });
        }

        final products = provider.products;
        final bool isProcessing = provider.purchasePending;
        final theme = Theme.of(context);

        // Main UI
        return Scaffold(
          appBar: AppBar(
            title: const Text("Subscribe"),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: SafeArea(
            child: Stack(
              children: [
                // Show loading indicator when products are being fetched
                if (products.isEmpty && !provider.isAvailable)
                  const Center(child: Text("Store not available."))
                else if (products.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    children: [
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final isSelected = _selectedIndex == index;
                            final isFree = product.rawPrice == 0;
                            // Now directly using provider.currentSubscriptionId
                            final isCurrentSubscription =
                                product.id == provider.currentSubscriptionId;

                            // Define styles based on state
                            BorderSide border = BorderSide.none;
                            Color? tileColor;

                            if (isCurrentSubscription) {
                              border = BorderSide(
                                  color: Colors.blue.shade400, width: 2.5);
                              tileColor = Colors.blue.withOpacity(0.1);
                            } else if (isSelected) {
                              border = BorderSide(
                                  color: theme.primaryColor, width: 2.5);
                              tileColor = theme.primaryColor.withOpacity(0.1);
                            } else if (isFree) {
                              border = BorderSide(
                                  color: Colors.green.shade400, width: 2);
                              tileColor = Colors.green.withOpacity(0.08);
                            }

                            return GestureDetector(
                              onTap: (isProcessing || isCurrentSubscription)
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedIndex = index;
                                      });
                                    },
                              child: Card(
                                elevation: isSelected ? 3.0 : 1.0,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                color: tileColor,
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: border,
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  product.title,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text(
                                                  product.price,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: isFree
                                                        ? Colors.green[700]
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            product.description,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme
                                                  .textTheme.bodyMedium?.color
                                                  ?.withOpacity(0.7),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (isCurrentSubscription)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors
                                                            .orange.shade300,
                                                        width: 1.2),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.check_circle,
                                                          color: Colors.orange,
                                                          size: 18),
                                                      SizedBox(width: 6),
                                                      Text(
                                                        'Active Subscription',
                                                        style: TextStyle(
                                                          color: Colors.orange,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isFree) _buildPromoBanner(context),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      _buildBottomButtons(context, provider),
                    ],
                  ),
                // Show a processing overlay
                if (isProcessing)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 20),
                          Text(
                            'Processing purchase...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons(
      BuildContext context, SubscriptionProvider provider) {
    // Disable "Subscribe Now" if no item is selected, or if processing, or if the selected item is already subscribed
    final bool canSubscribe = _selectedIndex != null &&
        !provider.purchasePending &&
        (_selectedIndex! < provider.products.length &&
            provider.products[_selectedIndex!].id !=
                provider.currentSubscriptionId);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: canSubscribe
                  ? () async {
                      await provider.buy(provider.products[_selectedIndex!]);
                    }
                  : null,
              // Button is disabled if no selection or if processing or if already subscribed
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text("Subscribe Now"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: provider.purchasePending
                  ? null
                  : () {
                      if (widget.isFromSettings) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacementNamed(
                            context, '/finalCongrats');
                      }
                    },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: Text(widget.isFromSettings ? "Cancel" : "Skip"),
            ),
          ),
        ],
      ),
    );
  }
}
