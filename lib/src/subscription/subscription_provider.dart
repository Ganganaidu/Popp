import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:popp/src/utils/app_loger.dart';

class SubscriptionProvider with ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool _available = false;
  bool _isSubscribed = false;
  // Use a dedicated state for when a purchase is in flight.
  bool _purchasePending = false;
  String? _purchaseError;
  List<ProductDetails> _products = [];

  // Public getters for the UI to consume.
  bool get isSubscribed => _isSubscribed;
  bool get isAvailable => _available;
  bool get purchasePending => _purchasePending;
  String? get purchaseError => _purchaseError;
  List<ProductDetails> get products => _products;

  SubscriptionProvider() {
    _initialize();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    _available = await _iap.isAvailable();
    if (_available) {
      await _getProducts();
      // Start listening to purchase updates
      final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
      _subscription = purchaseUpdated.listen((purchaseDetailsList) {
        // Pass the current user's UID to the listener.
        // In a real app, you might get this from an Auth provider.
        String? uid = FirebaseAuth.instance.currentUser?.uid;
        _listenToPurchases(purchaseDetailsList, uid); // Replace null with actual UID
      }, onDone: () {
        _subscription.cancel();
      }, onError: (error) {
        // Handle stream errors
        debugPrint("Error on purchase stream: $error");
        _setPurchaseError('An error occurred with the store. Please try again.');
      });
    }
    notifyListeners();
  }

  Future<void> _getProducts() async {
    const Set<String> _kIds = {'premium_subscription'}; // Your product IDs
    try {
      final response = await _iap.queryProductDetails(_kIds);
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
      }
      _products = response.productDetails;
      sortProductsByPrice(); // Assuming you want to keep this logic
    } catch (e) {
      debugPrint('Failed to get products: $e');
      _setPurchaseError('Could not connect to the store. Please check your connection.');
    }
    notifyListeners();
  }

  void sortProductsByPrice() {
    _products.sort((a, b) {
      // Your sorting logic here...
      return a.rawPrice.compareTo(b.rawPrice);
    });
  }

  Future<void> buy(ProductDetails productDetails) async {
    // Reset any previous errors and set pending state
    _setPurchasePending(true);
    _setPurchaseError(null);

    try {
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } on PlatformException catch (e) {
      debugPrint('Failed to initiate purchase: ${e.code} - ${e.message}');
      _setPurchaseError('Failed to start purchase. Please try again.');
      _setPurchasePending(false);
    } catch (e) {
      debugPrint('An unexpected error occurred during purchase initiation: $e');
      _setPurchaseError('An unexpected error occurred. Please try again.');
      _setPurchasePending(false);
    }
  }

  Future<void> _listenToPurchases(List<PurchaseDetails> purchaseDetailsList, String? uid) async {
    for (var purchase in purchaseDetailsList) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _setPurchasePending(true);
          _setPurchaseError(null);
          break;
        case PurchaseStatus.error:
          AppLogger.d('Purchase failed: ${purchase.error}');
          _setPurchaseError(purchase.error?.message ?? 'Your purchase failed.');
          _setPurchasePending(false);
          // Complete the purchase to dismiss the transaction from the queue
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
        // 1. Verify and deliver the product (update Firestore)
          final bool delivered = await _verifyAndDeliver(purchase, uid);
          if (delivered) {
            // 2. If delivered, update local state and complete the purchase
            _isSubscribed = true;
            _setPurchasePending(false);
            _setPurchaseError(null);
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
          } else {
            // 3. If delivery fails, show an error but DON'T complete the purchase
            _setPurchaseError('Failed to verify your purchase. Please contact support.');
            _setPurchasePending(false);
          }
          break;
        case PurchaseStatus.canceled:
          _setPurchasePending(false);
          _setPurchaseError(null); // User cancelled, no error to show
          break;
      }
    }
  }

  Future<bool> _verifyAndDeliver(PurchaseDetails purchaseDetails, String? uid) async {
    // This is where you grant the user entitlement.
    // For subscriptions, this involves updating their status in your database.
    if (uid == null) {
      AppLogger.d('Cannot deliver purchase without a user ID.');
      return false; // Cannot deliver without a logged-in user
    }
    // Update subscription status in FireStore
    return await updateUserSubscription(uid: uid, isSubscribed: true);
  }

  Future<bool> updateUserSubscription({ required String uid, required bool isSubscribed}) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'isSubscribed': isSubscribed});
      // The local state _isSubscribed will be set in the listener after this succeeds
      return true;
    } catch (e) {
      AppLogger.d('Failed to update subscription in Firestore: $e');
      return false; // Return false to indicate delivery failure
    }
  }

  Future<void> checkSubscriptionStatus(String? uid) async {
    if (uid == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        _isSubscribed = userDoc.data()?['isSubscribed'] ?? false;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.d('Failed to check subscription status: $e');
    }
  }

  // Helper methods to manage state and notify listeners
  void _setPurchasePending(bool pending) {
    _purchasePending = pending;
    notifyListeners();
  }

  void _setPurchaseError(String? error) {
    _purchaseError = error;
    notifyListeners();
  }
}
