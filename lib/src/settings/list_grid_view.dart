import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:popp/src/api/currency_service.dart';
import 'package:popp/src/navigation/nav_router.dart';
import 'package:popp/src/utils/product_utils.dart';
import 'package:popp/src/widgets/app_dialogs.dart';

import '../widgets/listing_card.dart';

class ListingsGridView extends StatefulWidget {
  final Query query;
  final bool showOptionsMenu;

  const ListingsGridView({
    super.key,
    required this.query,
    this.showOptionsMenu = false,
  });

  @override
  State<ListingsGridView> createState() => _ListingsGridViewState();
}

class _ListingsGridViewState extends State<ListingsGridView> {
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

        final docs = snapshot.data!.docs;
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
            final docStatus = data['status'] as String?;
            final status = isSold
                ? 'Sold'
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
              onTap: () {
                final category = data['category'] as String?;
                if (!ProductUtils.listYourServiceCategories.contains(category)) {
                  onProductDetailsTap(context, data, true);
                } else {
                  onServiceDetailsScreenTap(context, data, category!);
                }
              },
              onEdit: () {
                // Handle edit action
              },
              onSold: () {
                AppDialogs.showConfirmationDialog(
                  context: context,
                  title: "Mark as Sold",
                  content:
                      "Marking as sold will update your product status to 'Sold' and it will be automatically removed from the database after 15 days.",
                  onConfirm: () async {
                    try {
                      await FirebaseFirestore.instance
                          .doc(doc.reference.path)
                          .update({
                        'isSold': true,
                        'soldDate': FieldValue.serverTimestamp(),
                      });

                      // Show success message
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Product marked as sold successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Force a rebuild of the widget
                        setState(() {});
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Failed to mark as sold. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                );
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
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (route) => false);
              },
              icon: const Icon(Icons.add_circle),
              label: Text(widget.showOptionsMenu
                  ? "Create a Listing"
                  : "Start Exploring"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
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
