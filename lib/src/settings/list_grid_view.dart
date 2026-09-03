import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:popp/src/api/currency_service.dart';
import 'package:popp/src/navigation/app_routes.dart';
import 'package:popp/src/products/repository/product_repository.dart';
import 'package:popp/src/services/repository/service_repository.dart';
import 'package:popp/src/utils/product_utils.dart';
import 'package:popp/src/widgets/app_dialogs.dart';

import '../widgets/listing_card.dart';

class ListingsGridView extends StatefulWidget {
  final Query query;
  final bool showOptionsMenu;
  final bool showAdminSoldOption;
  /// When true, each card gets an admin-only "Delete" option that permanently
  /// removes the product / service (and its images).
  final bool isAdmin;

  const ListingsGridView({
    super.key,
    required this.query,
    this.showOptionsMenu = false,
    this.showAdminSoldOption = false,
    this.isAdmin = false,
  });

  @override
  State<ListingsGridView> createState() => _ListingsGridViewState();
}

class _ListingsGridViewState extends State<ListingsGridView> {
  final ProductRepository _productRepo = ProductRepository();
  final ServiceRepository _serviceRepo = ServiceRepository();

  Future<void> _deleteListing(
      {required String id, required bool isService}) async {
    final label = isService ? 'service' : 'product';
    final confirmed = await AppDialogs.confirmDeleteListing(
      context: context,
      itemLabel: label,
    );
    if (!confirmed) return;

    try {
      if (isService) {
        await _serviceRepo.deleteService(id);
      } else {
        await _productRepo.deleteProduct(id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${label[0].toUpperCase()}${label.substring(1)} deleted.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Delete failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(context);
        }

        var docs = snapshot.data!.docs;

        // "Mark as Sold" is a product-only concept — services (repair shops,
        // stores, events…) are never sold. Only the product management tab
        // excludes sold listings; it's done here rather than in the Firestore
        // query because that query has no `orderBy` and, for services,
        // `where('isSold', isEqualTo: false)` would silently drop every
        // document that lacks the field.
        if (widget.showAdminSoldOption) {
          docs = docs.where((d) {
            final m = d.data() as Map<String, dynamic>;
            return m['isSold'] != true &&
                (m['status']?.toString().toLowerCase() != 'sold');
          }).toList();
        }

        // Admin management tabs run unordered Firestore queries — sort the
        // most recently created listings first on the client.
        if (widget.isAdmin) {
          docs = docs.toList()
            ..sort((a, b) {
              final at = (a.data() as Map<String, dynamic>)['createdAt'];
              final bt = (b.data() as Map<String, dynamic>)['createdAt'];
              if (at is Timestamp && bt is Timestamp) return bt.compareTo(at);
              if (at is Timestamp) return -1;
              if (bt is Timestamp) return 1;
              return 0;
            });
        }

        if (docs.isEmpty) {
          return _buildEmptyState(context);
        }

        final countryCode = Localizations.localeOf(context).countryCode ?? 'US';

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final raw = doc.data() as Map<String, dynamic>;
            // Ensure the Firestore document ID is available to downstream screens
            // (ServiceDetailScreen expects `serviceData['id']` to contain the doc id).
            final data = {...raw, 'id': doc.id};

            // Logic to handle different data structures
            String title = data['name'] ?? data['brandName'] ?? '';
            String location = data['city'] ?? '';
            final brandName = data['modelName'];
            if (brandName != null && brandName.isNotEmpty) {
              title = '$title $brandName - $location';
            }
            if (title.isEmpty) {
              title = data['businessTitle'] ?? data['eventName'] ?? 'No Title';
              String address =
                  data['businessAddress'] ?? data['locationAddress'] ?? '';
              String cityAndState =
                  '${data['city'] ?? ''}, ${data['state'] ?? ''}';
              location = '$address, $cityAndState'
                  .trim()
                  .replaceAll(RegExp(r'^, |,$'), '');
              title = '$title - $location';
            }

            String? imageUrl;
            List<dynamic>? promoImages = (data['promoImageUrls'] is List)
                ? data['promoImageUrls']
                : null;
            if (promoImages == null &&
                data['promoImageUrls'] is String &&
                data['promoImageUrls'].isNotEmpty) {
              promoImages = [data['promoImageUrls']];
            }
            List<dynamic>? shopGarageImages =
                (data['shopImageUrls'] is List) ? data['shopImageUrls'] : null;

            if (promoImages != null && promoImages.isNotEmpty) {
              imageUrl = promoImages.first as String;
            } else if (shopGarageImages != null &&
                shopGarageImages.isNotEmpty) {
              imageUrl = shopGarageImages.first as String;
            } else if (data['imageUrl'] is String &&
                data['imageUrl'].isNotEmpty) {
              imageUrl = data['imageUrl'] as String;
            }

            final price = data['expectedPrice']?.toString();
            bool isApproved = data['isApproved'] ?? false;
            bool isSold = data['isSold'] ?? false;
            bool hasPendingUpdate = data['hasPendingUpdate'] ?? false;
            final docStatus = data['status'] as String?;
            final status = isSold
                ? 'Sold'
                : isApproved && hasPendingUpdate
                    ? 'Update Pending'
                    : isApproved
                        ? 'Approved'
                        : docStatus == 'sent_back'
                            ? 'Sent Back'
                            : docStatus == 'rejected'
                                ? 'Rejected'
                                : 'Pending';

            return ListingCard(
              title: title,
              imageUrl: imageUrl,
              price: CurrencyService.getProductPrice(price, countryCode),
              status: status,
              showOptionsMenu: widget.showOptionsMenu,
              showSoldOptionOnly: widget.showAdminSoldOption,
              onDelete: widget.isAdmin
                  ? () => _deleteListing(
                        id: doc.id,
                        isService: ProductUtils.listYourServiceCategories
                            .contains(data['category']),
                      )
                  : null,
              onTap: () {
                final category = data['category'] as String?;
                if (!ProductUtils.listYourServiceCategories.contains(category)) {
                  context.pushProductDetail(data, showStatus: true);
                } else {
                  context.pushServiceDetail(data, category!);
                }
              },
              onEdit: () {
                // Handle edit action
              },
              onEditApproved: () {
                context.pushEditListing(data);
              },
              onSold: () async {
                final success = await AppDialogs.confirmAndMarkAsSold(
                  context: context,
                  docRef:
                      FirebaseFirestore.instance.doc(doc.reference.path),
                );
                if (success && context.mounted) {
                  // Force a rebuild of the widget
                  setState(() {});
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/empty_state.json', width: 200, height: 200),
            const SizedBox(height: 20),
            Text(
                widget.showOptionsMenu
                    ? "No Listings Found"
                    : "No Favorites Yet",
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
                widget.showOptionsMenu
                    ? "You haven't listed any products or services yet."
                    : "Tap the heart on any item to save it here.",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.goHome();
              },
              icon: const Icon(Icons.add_circle),
              label: Text(widget.showOptionsMenu
                  ? "Create a Listing"
                  : "Start Exploring"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
