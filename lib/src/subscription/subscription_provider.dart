import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:popp/src/utils/app_loger.dart';

import '../utils/app_constants.dart';

class SubscriptionProvider with ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool _available = false;
  bool _isSubscribed = false;
  String? _currentSubscriptionId;
  bool _purchasePending = false;
  String? _purchaseError;
  List<ProductDetails> _products = [];

  // Temporarily store the selected plan ID during an Android purchase
  String? _pendingAndroidPurchasePlanId;

  // Public getters
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
    // Platform-specific product IDs
    Set<String> kIds;
    if (Platform.isAndroid) {
      // For Android, query the main Subscription ID
      kIds = {'premium_membership'};
    } else if (Platform.isIOS) {
      // For iOS, query each individual plan ID
      kIds = {
        'monthly_subscription',
        'premium_subscription',
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
      sortProductsByPrice();
      // Sorting is more relevant for iOS where multiple products are returned
      // if (Platform.isIOS) {
      //   sortProductsByPrice();
      // }
    } catch (e) {
      AppLogger.e('Failed to get products: $e');
      _setPurchaseError(
          'Could not connect to the store. Please check your connection.');
    }
    notifyListeners();
  }

  void sortProductsByPrice() {
    _products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
  }

  /// Cross-platform method to initiate a purchase.
  Future<void> buy({
    required ProductDetails productDetails,
    String? androidOfferToken, // Required for Android
    String? androidBasePlanId, // Required to track pending Android purchase
  }) async {
    _setPurchasePending(true);
    _setPurchaseError(null);

    late PurchaseParam purchaseParam;

    if (Platform.isAndroid) {
      // Ensure we have the necessary details for an Android purchase
      if (androidOfferToken == null || androidBasePlanId == null) {
        _setPurchaseError('Offer details are missing for this plan.');
        _setPurchasePending(false);
        AppLogger.w('Initiating androidOfferToken: $androidOfferToken');
        return;
      }
      final googlePlayProductDetails =
          productDetails as GooglePlayProductDetails;
      // Store the specific plan being purchased to correctly update state later
      _pendingAndroidPurchasePlanId = androidBasePlanId;

      purchaseParam = GooglePlayPurchaseParam(
        productDetails: googlePlayProductDetails,
        applicationUserName: null,
        offerToken: androidOfferToken,
      );
    } else if (Platform.isIOS) {
      purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: null,
      );
    } else {
      _setPurchaseError('Unsupported platform for purchases.');
      _setPurchasePending(false);
      AppLogger.w('Initiating androidOfferToken: $androidOfferToken');
      return;
    }

    try {
      AppLogger.d('Initiating androidOfferToken: $androidBasePlanId');
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      // If the user cancels the purchase flow (backs out), reset pending after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (_purchasePending) {
          _setPurchasePending(false);
        }
      });
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
      String? subscribedProductId;

      // Determine the actual product/plan ID
      if (Platform.isIOS) {
        subscribedProductId = purchase.productID;
      } else if (Platform.isAndroid) {
        // If an Android purchase was pending and the product ID matches,
        // use the stored base plan ID.
        if (_pendingAndroidPurchasePlanId != null &&
            purchase.productID == 'premium_membership') {
          subscribedProductId = _pendingAndroidPurchasePlanId;
          _pendingAndroidPurchasePlanId = null; // Clear after use
        } else {
          // Fallback for restores where we might not have a pending ID
          subscribedProductId = purchase.productID;
        }
      }

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _setPurchasePending(true);
          _setPurchaseError(null);
          break;
        case PurchaseStatus.error:
          // Handle error...
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
              await _verifyAndDeliver(purchase, uid, subscribedProductId);
          if (delivered) {
            _isSubscribed = true;
            _currentSubscriptionId = subscribedProductId;
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
    return await updateUserSubscription(
      uid: uid,
      isSubscribed: true,
      subscribedProductId: subscribedProductId,
    );
  }

  Future<bool> updateUserSubscription(
      {required String uid,
      required bool isSubscribed,
      String? subscribedProductId}) async {
    try {
      AppLogger.d("_pendingPurchasePrice owner ${_pendingAndroidPurchasePlanId ?? subscribedProductId}");
      AppLogger.d(
          "_pendingAndroidPurchasePlanId $_pendingAndroidPurchasePlanId");
      await FirebaseFirestore.instance
          .collection(Constants.userPath)
          .doc(uid)
          .update({
        'isSubscribed': isSubscribed,
        'subscribedProductId': isSubscribed
            ? _pendingAndroidPurchasePlanId ?? subscribedProductId
            : null,
      });
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

  // Helper methods
  void _setPurchasePending(bool pending) {
    _purchasePending = pending;
    notifyListeners();
  }

  void _setPurchaseError(String? error) {
    _purchaseError = error;
    AppLogger.d("_purchaseError");
    notifyListeners();
  }

  void clearPurchaseError() {
    _setPurchasePending(false);
    _setPurchaseError(null);
  }
}
