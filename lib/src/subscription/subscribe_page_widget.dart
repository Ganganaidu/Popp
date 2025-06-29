import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:popp/src/utils/app_loger.dart';
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
  SubscriptionProvider? _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = Provider.of<SubscriptionProvider>(context, listen: false);
    _provider?.addListener(_onProviderUpdate);
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderUpdate);
    super.dispose();
  }

  void _onProviderUpdate() {
    if (_provider?.purchaseError != null &&
        _provider!.purchaseError!.isNotEmpty) {
      final error = _provider!.purchaseError!;
      AppLogger.d("error $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      _provider?.clearPurchaseError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        // ... (error handling and processing overlay logic remains the same)
        final bool isProcessing = provider.purchasePending;

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
                  Platform.isAndroid
                      ? _buildAndroidList(context, provider)
                      : _buildIOSList(context, provider),
                if (isProcessing) _buildProcessingOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIOSList(BuildContext context, SubscriptionProvider provider) {
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

  Widget _buildAndroidList(
      BuildContext context, SubscriptionProvider provider) {
    // On Android, each GooglePlayProductDetails represents a subscription offer/base plan
    AppLogger.d("Product: ${provider.products.length}");
    final List<ProductDetails> products = [];

    final playProductList = provider.products.cast<GooglePlayProductDetails>();
    for (int i = 0; i < playProductList.length; i++) {
      final product = playProductList[i];
      final list = playProductList[i].productDetails.subscriptionOfferDetails;
      String? basePlanId = list?[i].basePlanId;
      AppLogger.d("basePlanId $basePlanId");
      if (product.currencySymbol == 'Free') {
        basePlanId = 'quarterly-trial';
      }
      final productDetail = ProductDetails(
          id: product.id,
          title: _getPlanTitle(basePlanId!),
          description: product.description,
          price: product.price,
          rawPrice: product.rawPrice,
          currencyCode: product.currencyCode);
      AppLogger.d("Product ID: $basePlanId");

      products.add(productDetail);
    }
    // sort the products by rawPrice
    // products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));

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

  // Helper function to map product IDs to user-friendly titles on Android.
  String _getPlanTitle(String productId) {
    // IMPORTANT: Make sure these IDs match your Base Plan IDs in Google Play Console.
    switch (productId) {
      case 'premium-yearly':
        return 'Yearly Plan';
      case 'premium-monthly':
        return 'Monthly Plan';
      case 'premium-quarterly':
        return '3-Month Plan';
      case 'quarterly-trial':
        return '3-Month Trial';
      default:
        // This might be the parent ID, so give it a generic name.
        return 'Premium Subscription';
    }
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Positioned(
      top: 12,
      right: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          'FREE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required BuildContext context,
    required SubscriptionProvider provider,
    required ProductDetails productDetails,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final bool isProcessing = provider.purchasePending;

    // For Android, productDetails is GooglePlayProductDetails, for iOS it's ProductDetails
    final String title = productDetails.title;
    final String price = productDetails.price;
    final String productId = productDetails.id;
    final String description = productDetails.description.isNotEmpty
        ? productDetails.description
        : 'Unlock bike info, contact owners & premium features.';
    final bool isFree = (productDetails.rawPrice == 0);
    final bool isCurrentSubscription =
        productId == provider.currentSubscriptionId;

    AppLogger.d("Product ID: $productId");
    AppLogger.d("currentSubscriptionId ID: ${provider.currentSubscriptionId}");
    // Styling logic...
    BorderSide border = BorderSide.none;
    Color? tileColor;
    if (isCurrentSubscription) {
      border = BorderSide(color: Colors.blue.shade400, width: 2.5);
      tileColor = Colors.blue.withOpacity(0.1);
    } else if (isSelected) {
      border = BorderSide(color: theme.primaryColor, width: 2.5);
      tileColor = theme.primaryColor.withOpacity(0.1);
    } else if (isFree) {
      border = BorderSide(color: Colors.green.shade400, width: 2);
      tileColor = Colors.green.withOpacity(0.08);
    }

    return GestureDetector(
      onTap: (isProcessing || isCurrentSubscription) ? null : onTap,
      child: Stack(
        children: [
          Card(
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
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.7))),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isCurrentSubscription)
                        const Chip(
                            label: Text('Activated'),
                            backgroundColor: Colors.blue,
                            labelStyle: TextStyle(color: Colors.white)),
                      const Spacer(),
                      Text(price,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isFree
                                  ? Colors.green[700]
                                  : theme.primaryColor)),
                    ],
                  )
                ],
              ),
            ),
          ),
          if (isFree) _buildPromoBanner(context),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(
      BuildContext context, SubscriptionProvider provider) {
    final bool isAndroid = Platform.isAndroid;
    ProductDetails? selectedProduct;

    if (_selectedIndex != null) {
      if (isAndroid) {
        if (_selectedIndex! < provider.products.length) {
          selectedProduct = provider.products[_selectedIndex!];
        }
      } else {
        // iOS
        if (_selectedIndex! < provider.products.length) {
          selectedProduct = provider.products[_selectedIndex!];
        }
      }
    }

    final String selectedId = selectedProduct?.id ?? '';
    final String? androidBasePlanId = isAndroid
        ? (selectedProduct is GooglePlayProductDetails &&
                selectedProduct.productDetails.subscriptionOfferDetails !=
                    null &&
                selectedProduct
                    .productDetails.subscriptionOfferDetails!.isNotEmpty
            ? selectedProduct
                .productDetails
                .subscriptionOfferDetails![
                    selectedProduct.subscriptionIndex ?? 0]
                .basePlanId
            : null)
        : null;
    final bool canSubscribe = selectedProduct != null &&
        !provider.purchasePending &&
        (selectedId != provider.currentSubscriptionId);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: canSubscribe
                  ? () async {
                      if (selectedProduct == null) return;
                      await provider.buy(
                        productDetails: selectedProduct,
                        androidOfferToken:
                            (selectedProduct is GooglePlayProductDetails)
                                ? (selectedProduct).offerToken
                                : null,
                        androidBasePlanId:
                            androidBasePlanId, // Not needed, offerToken is enough
                      );
                    }
                  : null,
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
