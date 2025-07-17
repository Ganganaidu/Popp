import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:popp/src/utils/app_loger.dart';

import '../api/api_url.dart';

class SubscriptionProvider with ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool _available = false;
  bool _isSubscribed = false;
  String? _currentSubscriptionId;
  String? _currentSubscriptionUniqueId; // <-- new field
  bool _purchasePending = false;
  String? _purchaseError;
  List<ProductDetails> _products = [];

  // Temporarily store the selected plan ID during an Android purchase
  // because the purchase result only returns the parent subscription ID.
  String? _pendingAndroidPurchasePlanId;

  // Public getters
  bool get isSubscribed => _isSubscribed;

  bool get isAvailable => _available;

  bool get purchasePending => _purchasePending;

  String? get purchaseError => _purchaseError;

  List<ProductDetails> get products => _products;

  String? get currentSubscriptionId => _currentSubscriptionId;

  String? get currentSubscriptionUniqueId =>
      _currentSubscriptionUniqueId; // <-- new getter

  SubscriptionProvider() {
    _initialize();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    // Enable pending purchases on Android
    if (Platform.isAndroid) {
      // InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
    }

    _available = await _iap.isAvailable();
    if (_available) {
      await _getProducts();
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
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await checkSubscriptionStatus(uid);
      }
    }
    notifyListeners();
  }

  Future<void> _getProducts() async {
    Set<String> kIds;
    if (Platform.isAndroid) {
      // For Android, query the main Subscription ID. This returns a list of
      // ProductDetails, one for each base plan and available offer.
      kIds = {'premium_membership'};
    } else if (Platform.isIOS) {
      // For iOS, query each individual plan ID
      kIds = {
        'monthly_subscription',
        'premium_subscription', // Assuming this is your 3-month plan ID
        'yearly_subscriptions'
      };
    } else {
      kIds = {};
    }

    try {
      final response = await _iap.queryProductDetails(kIds);
      if (response.notFoundIDs.isNotEmpty) {
        AppLogger.w('Products not found: ${response.notFoundIDs}');
      }
      _products = response.productDetails;
      // Sorting is still useful to ensure a consistent order
      sortProductsByPrice();
    } catch (e) {
      AppLogger.e('Failed to get products: $e');
      _setPurchaseError(
          'Could not connect to the store. Please check your connection.');
    }
    notifyListeners();
  }

  void sortProductsByPrice() {
    // A more robust sort that handles potential "Free" prices correctly.
    _products.sort((a, b) {
      if (a.rawPrice == 0 && b.rawPrice > 0) return -1;
      if (b.rawPrice == 0 && a.rawPrice > 0) return 1;
      return a.rawPrice.compareTo(b.rawPrice);
    });
  }

  Future<void> buy({required ProductDetails productDetails}) async {
    _setPurchasePending(true);
    _setPurchaseError(null);

    // On Android, we must store the selected plan ID before purchase.
    if (Platform.isAndroid) {
      _pendingAndroidPurchasePlanId = productDetails.id;
    }

    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);

    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } on PlatformException catch (e) {
      AppLogger.w('Failed to initiate purchase: ${e.code} - ${e.message}');
      _setPurchaseError(
          'Failed to start purchase: ${e.message ?? 'Unknown error'}.');
      _setPurchasePending(false);
    } catch (e) {
      AppLogger.e('An unexpected error occurred: $e');
      _setPurchaseError('An unexpected error occurred. Please try again.');
      _setPurchasePending(false);
    }
  }

  Future<void> _listenToPurchases(
      List<PurchaseDetails> purchaseDetailsList, String? uid) async {
    for (var purchase in purchaseDetailsList) {
      String? purchasedIdForUpdate;

      // This is the CRITICAL logic for Android.
      if (Platform.isAndroid) {
        if (_pendingAndroidPurchasePlanId != null &&
            purchase.productID == 'premium_membership') {
          // If a purchase for the parent subscription comes through,
          // use the specific plan ID we stored before the purchase.
          purchasedIdForUpdate = _pendingAndroidPurchasePlanId;
          _pendingAndroidPurchasePlanId = null; // Clear after use
        } else {
          // This handles restores where we don't have a pending purchase.
          // Note: This may not be perfectly accurate without server-side receipt validation.
          purchasedIdForUpdate = purchase.productID;
        }
      } else {
        // iOS provides the correct product ID directly.
        purchasedIdForUpdate = purchase.productID;
      }

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _setPurchasePending(true);
          _setPurchaseError(null);
          break;
        case PurchaseStatus.error:
          AppLogger.d('Purchase failed: ${purchase.error}');
          _setPurchaseError(purchase.error?.message ?? 'Your purchase failed.');
          _setPurchasePending(false);
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final bool delivered =
              await _verifyAndDeliver(purchase, uid, purchasedIdForUpdate);
          if (delivered) {
            _isSubscribed = true;
            _currentSubscriptionId = purchasedIdForUpdate;
            _setPurchasePending(false);
            _setPurchaseError(null);
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
          } else {
            _setPurchaseError(
                'Failed to verify your purchase. Please contact support.');
            _setPurchasePending(false);
          }
          break;
        case PurchaseStatus.canceled:
          _setPurchasePending(false);
          _setPurchaseError(null);
          if (uid != null) {
            await updateUserSubscription(uid: uid, isSubscribed: false);
          }
          break;
      }
    }
  }

  Future<bool> _verifyAndDeliver(PurchaseDetails purchaseDetails, String? uid,
      String? subscribedProductId) async {
    if (uid == null) {
      AppLogger.d('Cannot deliver purchase without a user ID.');
      return false;
    }
    // We pass the corrected (or iOS-provided) ID to our backend/DB.
    return await updateUserSubscription(
      uid: uid,
      isSubscribed: true,
      subscribedProductId: subscribedProductId,
    );
  }

  Future<bool> updateUserSubscription({
    required String uid,
    required bool isSubscribed,
    String? subscribedProductId,
    String? uniqueProductId, // <-- new param
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection(ApiUrl.userPath)
          .doc(uid)
          .update({
        'isSubscribed': isSubscribed,
        'subscribedProductId': isSubscribed ? subscribedProductId : null,
        'uniqueProductId': isSubscribed ? uniqueProductId : null,
        // <-- save unique id
      });
      _currentSubscriptionUniqueId = isSubscribed ? uniqueProductId : null;
      return true;
    } catch (e) {
      AppLogger.d('Failed to update subscription in Firestore: $e');
      return false;
    }
  }

  Future<void> checkSubscriptionStatus(String? uid) async {
    if (uid == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection(ApiUrl.userPath)
          .doc(uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data();
        _isSubscribed = data?['isSubscribed'] ?? false;
        _currentSubscriptionId = data?['subscribedProductId'] as String?;
        _currentSubscriptionUniqueId = data?['uniqueProductId'] as String?;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.d('Failed to check subscription status: $e');
    }
  }

  // Helper methods
  void _setPurchasePending(bool pending) {
    _purchasePending = pending;
    notifyListeners();
  }

  void _setPurchaseError(String? error) {
    _purchaseError = error;
    notifyListeners();
  }

  void clearPurchaseError() {
    if (_purchaseError != null) {
      _purchaseError = null;
      notifyListeners();
    }
  }
}
