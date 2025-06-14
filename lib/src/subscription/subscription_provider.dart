import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:popp/src/utils/app_loger.dart';

class SubscriptionProvider with ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;

  bool _available = false;
  bool _isSubscribed = false;
  List<ProductDetails> _products = [];

  bool get isSubscribed => _isSubscribed;
  List<ProductDetails> get products => _products;

  SubscriptionProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _available = await _iap.isAvailable();
    if (_available) {
      await _getProducts();
      _listenToPurchases();
    }
  }

  Future<void> _getProducts() async {
    const Set<String> _kIds = {'premium_subscription'};
    final response = await _iap.queryProductDetails(_kIds);
    _products = response.productDetails;
    sortProductsByPrice();
    notifyListeners();
  }

  void sortProductsByPrice() {
    _products.sort((a, b) {
      bool aIsFree = a.price.toLowerCase() == 'free' || a.price == '0' || a.price == '0.00' || a.price == '₹0' || a.price == '₹0.00';
      bool bIsFree = b.price.toLowerCase() == 'free' || b.price == '0' || b.price == '0.00' || b.price == '₹0' || b.price == '₹0.00';
      if (aIsFree && !bIsFree) return -1;
      if (!aIsFree && bIsFree) return 1;
      return a.price.compareTo(b.price);
    });
    notifyListeners();
  }

  Future<void> buy(ProductDetails productDetails) async {
    final purchaseParam = PurchaseParam(productDetails: productDetails);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam); // works for subscriptions
  }

  void _listenToPurchases() {
    _iap.purchaseStream.listen((List<PurchaseDetails> purchases) {
      for (var purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
          _isSubscribed = true;
          notifyListeners();
        } else if (purchase.status == PurchaseStatus.error) {
          debugPrint('Purchase failed: ${purchase.error}');
        }
      }
    });
  }

  Future<void> updateUserSubscription({
    required String? uid,
    required bool isSubscribed,
  }) async {
    try {
      if (uid == null) {
        AppLogger.e('No user is currently signed in.');
        return;
      }
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isSubscribed': isSubscribed
      });
      _isSubscribed = isSubscribed;
      notifyListeners();
    } catch (e) {
      AppLogger.e('Failed to update subscription: $e');
    }
  }

  Future<void> checkSubscriptionStatus(String? uid) async {
    if (uid == null) {
      AppLogger.e('No user is currently signed in.');
      return;
    }
    try {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        _isSubscribed = userDoc.data()?['isSubscribed'] ?? false;
        notifyListeners();
      } else {
        AppLogger.e('User document does not exist.');
      }
    } catch (e) {
      AppLogger.e('Failed to check subscription status: $e');
    }
  }
}
