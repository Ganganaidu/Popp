import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:popp/src/utils/app_loger.dart';

import '../utils/app_constants.dart';

class SubscriptionProvider with ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool _available = false;
  bool _isSubscribed = false;
  String?
      _currentSubscriptionId; // Stores the ID of the currently active subscription
  bool _purchasePending =
      false; // Indicates if any purchase/restore/cancel operation is in flight
  String? _purchaseError;
  List<ProductDetails> _products = [];

  // Public getters for the UI to consume.
  bool get isSubscribed => _isSubscribed;

  bool get isAvailable => _available;

  bool get purchasePending => _purchasePending;

  String? get purchaseError => _purchaseError;

  List<ProductDetails> get products => _products;

  String? get currentSubscriptionId => _currentSubscriptionId;

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
        String? uid = FirebaseAuth.instance.currentUser?.uid;
        _listenToPurchases(purchaseDetailsList, uid);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (error) {
        AppLogger.e("Error on purchase stream: $error");
        _setPurchaseError(
            'An error occurred with the store. Please try again.');
      });

      // After products are fetched and listener is set up, check current subscription status
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await checkSubscriptionStatus(uid);
      }
    }
    notifyListeners();
  }

  Future<void> _getProducts() async {
    const Set<String> _kIds = {
      'premium_subscription', // Example product ID
      'yearly_subscription', // Example product ID
      'monthly_subscription' // Example product ID
    };
    try {
      final response = await _iap.queryProductDetails(_kIds);
      if (response.notFoundIDs.isNotEmpty) {
        AppLogger.w('Products not found: ${response.notFoundIDs}');
      }
      _products = response.productDetails;
      sortProductsByPrice();
    } catch (e) {
      AppLogger.e('Failed to get products: $e');
      _setPurchaseError(
          'Could not connect to the store. Please check your connection.');
    }
    notifyListeners();
  }

  void sortProductsByPrice() {
    _products.sort((a, b) {
      return a.rawPrice.compareTo(b.rawPrice);
    });
  }

  Future<void> buy(ProductDetails productDetails) async {
    _setPurchasePending(true);
    _setPurchaseError(null);

    try {
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      // Use buyNonConsumable for one-time purchases, buySubscription for subscriptions
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } on PlatformException catch (e) {
      AppLogger.w('Failed to initiate purchase: ${e.code} - ${e.message}');
      _setPurchaseError(
          'Failed to start purchase: ${e.message ?? 'Unknown error'}.');
      _setPurchasePending(false);
    } catch (e) {
      AppLogger.e(
          'An unexpected error occurred during purchase initiation: $e');
      _setPurchaseError('An unexpected error occurred. Please try again.');
      _setPurchasePending(false);
    }
  }

  Future<void> _listenToPurchases(
      List<PurchaseDetails> purchaseDetailsList, String? uid) async {
    for (var purchase in purchaseDetailsList) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _setPurchasePending(true);
          _setPurchaseError(null);
          break;
        case PurchaseStatus.error:
          AppLogger.d('Purchase failed: \\${purchase.error}');
          _setPurchaseError(purchase.error?.message ?? 'Your purchase failed.');
          _setPurchasePending(false);
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          // Update Firestore to mark as not subscribed on error
          if (uid != null) {
            await updateUserSubscription(
              uid: uid,
              isSubscribed: false,
              subscribedProductId: null,
            );
          }
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final bool delivered = await _verifyAndDeliver(purchase, uid);
          if (delivered) {
            _isSubscribed = true;
            _currentSubscriptionId = purchase.productID;
            _setPurchasePending(false);
            _setPurchaseError(null);
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
            // Update Firestore to mark as subscribed
            if (uid != null) {
              await updateUserSubscription(
                uid: uid,
                isSubscribed: true,
                subscribedProductId: purchase.productID,
              );
            }
          } else {
            _setPurchaseError(
                'Failed to verify your purchase. Please contact support.');
            _setPurchasePending(false);
            // Update Firestore to mark as not subscribed if verification fails
            if (uid != null) {
              await updateUserSubscription(
                uid: uid,
                isSubscribed: false,
                subscribedProductId: null,
              );
            }
          }
          break;
        case PurchaseStatus.canceled:
          _setPurchasePending(false);
          _setPurchaseError(null); // User cancelled, no error to show
          // Update Firestore to mark as not subscribed on cancel
          if (uid != null) {
            await updateUserSubscription(
              uid: uid,
              isSubscribed: false,
              subscribedProductId: null,
            );
          }
          break;
      }
    }
  }

  Future<bool> _verifyAndDeliver(
      PurchaseDetails purchaseDetails, String? uid) async {
    if (uid == null) {
      AppLogger.d('Cannot deliver purchase without a user ID.');
      return false;
    }
    return await updateUserSubscription(
      uid: uid,
      isSubscribed: true,
      subscribedProductId: purchaseDetails.productID,
    );
  }

  Future<bool> updateUserSubscription({
    required String uid,
    required bool isSubscribed,
    String? subscribedProductId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection(Constants.userPath)
          .doc(uid)
          .update({
        'isSubscribed': isSubscribed,
        'subscribedProductId': isSubscribed ? subscribedProductId : null,
      });
      return true;
    } catch (e) {
      AppLogger.d('Failed to update subscription in Firestore: $e');
      return false;
    }
  }

  // Method to handle subscription cancellation
  // IMPORTANT: This method simulates cancellation in your app's state and Firestore.
  // In a real app, direct cancellation usually involves deep-linking to store's subscription management page.
  Future<void> cancelSubscription(String uid) async {
    _setPurchasePending(true); // Indicate a pending operation
    _setPurchaseError(null); // Clear any previous errors

    try {
      // Update Firestore to mark user as unsubscribed
      final bool updated = await updateUserSubscription(
        uid: uid,
        isSubscribed: false,
        subscribedProductId: null, // Clear the subscribed product ID
      );

      if (updated) {
        _isSubscribed = false; // Update local state
        _currentSubscriptionId = null; // Clear local subscribed product ID
        _setPurchasePending(false);
        AppLogger.d('Subscription cancelled successfully for $uid');
      } else {
        _setPurchaseError(
            'Failed to cancel subscription in database. Please try again.');
        _setPurchasePending(false);
      }
    } catch (e) {
      AppLogger.e('Error cancelling subscription: $e');
      _setPurchaseError('An unexpected error occurred during cancellation.');
      _setPurchasePending(false);
    }
  }

  Future<void> checkSubscriptionStatus(String? uid) async {
    if (uid == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection(Constants.userPath)
          .doc(uid)
          .get();
      if (userDoc.exists) {
        _isSubscribed = userDoc.data()?['isSubscribed'] ?? false;
        _currentSubscriptionId =
            userDoc.data()?['subscribedProductId'] as String?;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.d('Failed to check subscription status: $e');
    }
  }

  /// Call this method when the app resumes or user returns to the app
  Future<void> refreshSubscriptionFromStore() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (!_available || uid == null) return;
    try {
      // This will emit restored purchases on the purchaseStream
      await _iap.restorePurchases();
      // No need to process here; restored purchases will be handled in _listenToPurchases
    } catch (e) {
      AppLogger.e('Failed to refresh subscription from store: $e');
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
