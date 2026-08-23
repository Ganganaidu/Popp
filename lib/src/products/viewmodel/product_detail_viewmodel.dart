import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../../api/api_url.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_loger.dart';
import '../../utils/product_utils.dart';
import '../repository/product_repository.dart';

/// Holds all state and actions for the product detail screen. The widget layer
/// renders these fields and forwards user intent here — it performs no Firestore
/// work of its own.
class ProductDetailViewModel extends ChangeNotifier {
  final ProductRepository repository;
  final Map<String, dynamic> product;

  bool isFavorite = false;
  bool favButtonDisabled = false;
  bool isApproved = false;
  bool isSold = false;
  String status = '';

  ProductDetailViewModel({
    required this.repository,
    required this.product,
  }) {
    _initFromProduct();
  }

  void _initFromProduct() {
    isApproved = product['isApproved'] == true;
    isSold = product['isSold'] == true;
    final docStatus = product['status'] as String?;
    if (isSold) {
      status = 'Sold';
    } else if (isApproved) {
      status = 'Approved';
    } else if (docStatus == 'sent_back') {
      status = 'Sent Back';
    } else if (docStatus == 'rejected') {
      status = 'Rejected';
    } else {
      status = 'Pending';
    }

    AppLogger.d('ProductDetailViewModel init: status = $status');

    final favoritedBy = product['favoritedBy'] as List<dynamic>?;
    final uid = repository.currentUserId;
    isFavorite = favoritedBy != null && uid != null && favoritedBy.contains(uid);
  }

  String get productId => product['id'] as String? ?? '';

  bool get isAdmin => repository.currentUserId == Constants.adminUserId;

  bool get isOwner => !isAdmin && product['userId'] == repository.currentUserId;

  Future<void> toggleFavorite() async {
    if (favButtonDisabled) return;
    final previous = isFavorite;
    isFavorite = !isFavorite;
    favButtonDisabled = true;
    notifyListeners();

    final success = await repository.toggleFavorite(productId);
    favButtonDisabled = false;
    if (!success) {
      isFavorite = previous;
    }
    notifyListeners();
  }

  void shareProduct() {
    final serviceId = product['id'];
    final serviceName = ProductUtils.getTitle(product);
    // Path must be singular ("product") to match the intent-filter / AppLinks
    // parsing in main.dart — the deep link contract, not the (plural) Firestore
    // collection name.
    final String deepLink = '${ApiUrl.baseUrl}product/$serviceId';
    final String shareText = 'Check out $serviceName on Bikerverse! $deepLink';
    AppLogger.i('shareText $shareText');
    SharePlus.instance.share(
      ShareParams(text: shareText, subject: 'Check out this product!'),
    );
  }

  /// Called by the UI after the user confirms the mark-as-sold dialog (which
  /// performs the Firestore write). Updates local state to reflect it.
  void onMarkedSold() {
    isSold = true;
    status = 'Sold';
    notifyListeners();
  }

  /// Runs an admin moderation action. [reason] is required for `sent_back` and
  /// `rejected`. Returns a user-facing result message, or null if [action] is
  /// unknown.
  Future<String?> runAdminAction(String action, {String? reason}) async {
    if (productId.isEmpty) return null;

    switch (action) {
      case 'approved':
        await repository.approve(productId);
        isApproved = true;
        status = 'Approved';
        notifyListeners();
        return 'Product approved. User will be notified.';
      case 'sent_back':
        await repository.sendBack(productId, reason);
        status = 'Sent Back';
        notifyListeners();
        return 'Sent back to user for corrections.';
      case 'rejected':
        await repository.reject(productId, reason);
        status = 'Rejected';
        notifyListeners();
        return 'Listing rejected. User will be notified.';
      default:
        return null;
    }
  }
}
