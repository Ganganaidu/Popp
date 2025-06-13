import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:popp/src/utils/app_loger.dart';
import '../login/model/user_data_model.dart';

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
          _verifyAndActivate(purchase);
        } else if (purchase.status == PurchaseStatus.error) {
          debugPrint('Purchase failed: ${purchase.error}');
        }
      }
    });
  }

  void _verifyAndActivate(PurchaseDetails purchase) async {
   // //  Instead of just trusting the client
   //  final isValid = await myBackend.verifyPurchase(purchase);
   //  if (isValid) {
   //    _isSubscribed = true;
   //    notifyListeners();
   //  }
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
        'isSubscribed': isSubscribed,
        'registrationComplete': true,
      });
      _isSubscribed = isSubscribed;
      notifyListeners();
    } catch (e) {
      AppLogger.e('Failed to update subscription: $e');
    }
  }

}
