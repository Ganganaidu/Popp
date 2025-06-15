import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    // Use a post-frame callback to listen for errors that might occur
    // during the purchase flow and show a SnackBar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SubscriptionProvider>(context, listen: false);
      // It's good practice to clear any lingering errors when the page is first built.
      if (provider.purchaseError != null) {
        // Assuming you add a method to clear the error in your provider
        // provider.clearError();
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
    // Use Consumer to react to changes in the provider
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {

        // Listen for error changes and show a SnackBar
        if (provider.purchaseError != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorSnackBar(context, provider.purchaseError!);
            // Optionally clear the error in the provider after showing it
            // provider.clearError();
          });
        }

        // If the user becomes subscribed while on this page, handle it.
        if (provider.isSubscribed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Navigate away once the subscription is confirmed.
            if (mounted) {
              if (!widget.isFromSettings) {
                Navigator.pushReplacementNamed(context, '/finalCongrats');
              } else {
                Navigator.pop(context);
              }
            }
          });
          // Show a success view while navigating
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 50),
                  SizedBox(height: 16),
                  Text('Purchase Successful!', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          );
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
                            // A reliable check for the free promotional item.
                            final isFree = product.rawPrice == 0;

                            // Define styles based on state
                            final BorderSide border = isSelected
                                ? BorderSide(color: theme.primaryColor, width: 2.5)
                                : isFree
                                ? BorderSide(color: Colors.green.shade400, width: 2)
                                : BorderSide.none;

                            final Color? tileColor = isSelected
                                ? theme.primaryColor.withOpacity(0.1)
                                : isFree
                                ? Colors.green.withOpacity(0.08)
                                : null;

                            return GestureDetector(
                              onTap: isProcessing ? null : () { // Disable tap during processing
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },
                              child: Card(
                                elevation: isSelected ? 3.0 : 1.0,
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.title,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            product.description,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              product.price,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: isFree ? Colors.green[700] : null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if(isFree) _buildPromoBanner(context),
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

  Widget _buildBottomButtons(BuildContext context, SubscriptionProvider provider) {
    final bool canSubscribe = _selectedIndex != null && !provider.purchasePending;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: canSubscribe
                  ? () async {
                // No need to pop here, the UI will update based on provider state
                await provider.buy(provider.products[_selectedIndex!]);
              }
                  : null, // Button is disabled if no selection or if processing
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text("Subscribe Now"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: provider.purchasePending ? null : () { // Disable during processing
                if (widget.isFromSettings) {
                  Navigator.pop(context);
                } else {
                  // This button should probably not update the subscription status
                  Navigator.pushReplacementNamed(context, '/finalCongrats');
                }
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: Text(widget.isFromSettings ? "Cancel" : "Skip"),
            ),
          ),
        ],
      ),
    );
  }
}
