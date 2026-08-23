import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../api/api_url.dart';
import '../navigation/app_router.dart';
import '../navigation/app_routes.dart';
import '../services/listservices/service_detail_screen.dart';

/// Holds a product/service deep link that arrived while the user was signed
/// out. Consumed once by the router's redirect callback right after login
/// succeeds so the user lands on the intended page instead of the link
/// being dropped.
class PendingDeepLink {
  static Uri? uri;
}

/// Fetches the product/service referenced by [uri] and pushes its detail
/// screen. Assumes the caller already confirmed the user is signed in and
/// that [uri] has the `/product/<id>` or `/service/<id>` shape.
Future<void> openDeepLinkUri(Uri uri) async {
  final segments = uri.pathSegments;
  if (segments.length != 2 ||
      (segments[0] != 'service' && segments[0] != 'product')) {
    return;
  }

  final productType = segments[0];
  final id = segments[1];
  final collectionPath =
      productType == 'service' ? ApiUrl.servicePath : ApiUrl.productsPath;

  try {
    final doc = await FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(id)
        .get();

    if (!doc.exists) return;
    final raw = doc.data() as Map<String, dynamic>;
    final data = {...raw, 'id': doc.id};

    if (productType == 'service') {
      // TODO(arch): migrate onto a go_router route when the services feature
      // is moved to the new architecture.
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => ServiceDetailScreen(
            serviceData: data,
            category: data['category'] ?? '',
          ),
        ),
      );
    } else {
      router.push(
        AppRoutes.productDetail,
        extra: ProductDetailArgs(product: data),
      );
    }
  } catch (e) {
    // Optionally handle error
  }
}
