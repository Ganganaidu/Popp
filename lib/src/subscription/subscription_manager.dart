import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// TODO: Remove this class and use SubscriptionProvider instead
class SubscriptionManager with ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = false;
  List<ProductDetails> _products = [];
  bool isSubscribed = false;

  List<ProductDetails> get products => _products;

  Future<void> init() async {
    _available = await _iap.isAvailable();
    if (_available) {
      const Set<String> _kIds = {'premium_subscription'};
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(_kIds);
      _products = response.productDetails;
      notifyListeners();
    }
  }

  Future<void> buy(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    await _iap.buyNonConsumable(
        purchaseParam: purchaseParam); // For subscriptions, still works
  }

  void listenToPurchases() {
    _iap.purchaseStream.listen((List<PurchaseDetails> purchases) {
      for (var purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          _verifyAndUpdateSubscription(purchase);
        }
      }
    });
  }

  Future<void> _verifyAndUpdateSubscription(PurchaseDetails purchase) async {
    // Ideally verify on backend here with receipt/token
    isSubscribed = true;
    notifyListeners();
  }
}
