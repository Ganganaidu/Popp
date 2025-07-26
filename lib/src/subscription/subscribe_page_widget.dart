import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:provider/provider.dart';
import 'subscription_provider.dart'; // Your provider class



// TODO Apple needs this information to be displayed on the subscription page:
// - Title of auto-renewing subscription (this may be the same as the in-app purchase product name)
// - Length of subscription
// - Price of subscription, and price per unit if appropriate

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
  late SubscriptionProvider _subscriptionProvider;
  int? _selectedIndex;

  String _getUniqueId(ProductDetails productDetails) {
    if (productDetails is GooglePlayProductDetails) {
      // For Android, we need to dig into the wrapped details to find the true unique ID.
      final GooglePlayProductDetails details = productDetails;
      // The `offerToken` is unique for each offer, including the base plan's default offer.
      // The `basePlanId` is what you define in the Play Console.
      // The offer ID is null for a base plan but present for an introductory offer.
      // We prioritize the offer ID if it exists, otherwise we use the base plan ID.
      final offerDetails =
          details.productDetails.subscriptionOfferDetails?.firstWhere(
        (offer) => offer.offerIdToken == details.offerToken,
        orElse: () => SubscriptionOfferDetailsWrapper(
            pricingPhases: const [],
            offerTags: const [],
            offerIdToken: '',
            basePlanId: productDetails.id),
      );
      return offerDetails?.offerId ??
          offerDetails?.basePlanId ??
          productDetails.id;
    }
    // On iOS, the productDetails.id is the correct unique identifier.
    return productDetails.id;
  }

  // Helper function to map product IDs to user-friendly titles on Android.
  String _getPlanTitle(String productId) {
    // IMPORTANT: Make sure these IDs match your Base Plan IDs and Offer IDs in Google Play Console.
    switch (productId) {
      case 'premium-yearly': // Example ID
        return 'Yearly Plan';
      case 'premium-monthly': // Example ID
        return 'Monthly Plan';
      case 'premium-quarterly': // Example ID
        return '3-Month Plan';
      case 'quarterly-trial': // Example ID for a trial offer
        return '3-Month Trial';
      default:
        // This might be the parent ID or an unmapped ID, so give it a generic name.
        return 'Premium Subscription';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscriptionProvider =
          Provider.of<SubscriptionProvider>(context, listen: false);
      _subscriptionProvider.addListener(_handleProviderChanges);
    });
  }

  @override
  void dispose() {
    _subscriptionProvider.removeListener(_handleProviderChanges);
    super.dispose();
  }

  void _handleProviderChanges() {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    if (provider.purchaseError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.purchaseError!),
            backgroundColor: Colors.red,
          ),
        );
        // Clear the error after showing it.
        provider.clearPurchaseError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        final isProcessing = provider.purchasePending;

        return Scaffold(
          appBar: AppBar(title: const Text("Subscribe")),
          body: SafeArea(
            child: Stack(
              children: [
                if (provider.products.isEmpty && !provider.isAvailable)
                  const Center(child: Text("Store not available."))
                else if (provider.products.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  _buildProductList(context, provider),
                if (isProcessing) _buildProcessingOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductList(
      BuildContext context, SubscriptionProvider provider) {
    final products = provider.products;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(
                context: context,
                index: index,
                provider: provider,
                productDetails: product,
                isSelected: _selectedIndex == index,
                onTap: () => setState(() => _selectedIndex = index),
              );
            },
          ),
        ),
        _buildBottomButtons(context, provider),
      ],
    );
  }

  Widget _buildProductCard({
    required BuildContext context,
    required int index,
    required SubscriptionProvider provider,
    required ProductDetails productDetails,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isProcessing = provider.purchasePending;

    final String uniqueId = _getUniqueId(productDetails);
    final bool isCurrentSubscription =
        uniqueId == provider.currentSubscriptionId;

    // Use the helper to get a friendly title on Android.
    final String displayTitle = Platform.isAndroid
        ? _getPlanTitle(uniqueId)
        : productDetails.title; // iOS title is correct from the store.

    final bool isTrialOffer =
        productDetails.price == '0.00' || productDetails.price.contains('Free');

    // Styling logic...
    BorderSide border = BorderSide.none;
    Color? tileColor;
    if (isTrialOffer) {
      border = BorderSide(color: Colors.green.shade400, width: 2.5);
      tileColor = Colors.green.withOpacity(0.1);
    }
    if (isCurrentSubscription) {
      border = BorderSide(color: Colors.blue.shade400, width: 2.5);
      tileColor = Colors.blue.withOpacity(0.1);
    } else if (isSelected) {
      border = BorderSide(color: theme.primaryColor, width: 2.5);
      tileColor = theme.primaryColor.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: (isProcessing || isCurrentSubscription) ? null : onTap,
      child: Card(
        elevation: isSelected ? 3.0 : 1.0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: tileColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), side: border),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              Text(productDetails.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isCurrentSubscription)
                    const Chip(
                        label: Text('Active'),
                        backgroundColor: Colors.blue,
                        labelStyle: TextStyle(color: Colors.white)),
                  const Spacer(),
                  Text(productDetails.price,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(
      BuildContext context, SubscriptionProvider provider) {
    ProductDetails? selectedProduct;
    if (_selectedIndex != null && _selectedIndex! < provider.products.length) {
      selectedProduct = provider.products[_selectedIndex!];
    }

    // Use the helper to get the correct ID for comparison
    final String selectedUniqueId =
        selectedProduct != null ? _getUniqueId(selectedProduct) : '';

    final bool canSubscribe = selectedProduct != null &&
        !provider.purchasePending &&
        (selectedUniqueId != provider.currentSubscriptionId);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: canSubscribe
                  ? () async {
                      // The `buy` method is now simpler and more reliable.
                      // The provider handles storing the pending plan ID for Android internally.
                      await provider.buy(
                        productDetails: selectedProduct!,
                      );
                    }
                  : null,
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
              child: Text(widget.isFromSettings ? "Cancel" : "Skip"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text('Processing purchase...',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
