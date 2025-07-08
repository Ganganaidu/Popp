import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:popp/src/navigation/nav_router.dart';
import 'package:popp/src/utils/product_content_data.dart';

import '../widgets/shimmer_image.dart';

class ListingsGridView extends StatelessWidget {
  final Query query;
  final bool showOptionsMenu;

  const ListingsGridView({
    super.key,
    required this.query,
    this.showOptionsMenu = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
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
            final data = doc.data() as Map<String, dynamic>;

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

            return _buildListingCard(
              context,
              title: title,
              imageUrl: imageUrl,
              price: price,
              showOptionsMenu: showOptionsMenu,
              onTap: () {
                final category = data['category'] as String?;
                if (serviceCategories.contains(category)) {
                  onServiceDetailsScreenTap(context, data, category!);
                } else {
                  onProductDetailsTap(context, data);
                }
              },
              onEdit: () {
                /* TODO: Implement Edit */
              },
              onSold: () {
                /* TODO: Implement Delete */
              },
            );
          },
        );
      },
    );
  }

  Widget _buildListingCard(BuildContext context,
      {required String title,
      String? imageUrl,
      String? price,
      bool showOptionsMenu = false,
      VoidCallback? onTap,
      VoidCallback? onEdit,
      VoidCallback? onSold}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? ShimmerImage(imageUrl: imageUrl)
                        : _buildPlaceholderImage(),
                  ),
                  if (showOptionsMenu)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _buildOptionsMenu(context, onEdit!, onSold!),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (price != null && price.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      price,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsMenu(
      BuildContext context, VoidCallback onEdit, VoidCallback onSold) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') onSold();
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
            value: 'edit',
            child: ListTile(
                leading: Icon(Icons.edit_outlined), title: Text('Edit'))),
        const PopupMenuItem<String>(
            value: 'sold',
            child: ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.orange),
                title: Text('Sold',
                    style: TextStyle(color: Colors.orange)))),
      ],
      icon: Container(
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
        child: const Icon(Icons.more_vert, color: Colors.white),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(Icons.two_wheeler, color: Colors.grey.shade400, size: 40),
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
            Text(showOptionsMenu ? "No Listings Found" : "No Favorites Yet",
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
                showOptionsMenu
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
              label: Text(
                  showOptionsMenu ? "Create a Listing" : "Start Exploring"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
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
