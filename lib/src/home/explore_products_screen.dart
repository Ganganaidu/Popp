import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../api/api_url.dart';
import '../models/shortcut_category.dart';
import '../navigation/nav_router.dart';

class ExploreProductsScreen extends StatefulWidget {
  const ExploreProductsScreen({super.key});

  @override
  State<ExploreProductsScreen> createState() => _ExploreProductsScreenState();
}

class _ExploreProductsScreenState extends State<ExploreProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _results = [];

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final fireStore = FirebaseFirestore.instance;
    final List<Map<String, dynamic>> results = [];
    // Search products
    final productsSnap = await fireStore
        .collection(ApiUrl.productsPath)
        .where('searchKeywords', arrayContainsAny: [query.toLowerCase()]).get();
    results.addAll(productsSnap.docs.map((doc) => {
          ...doc.data(),
          'type': 'product',
          'id': doc.id,
        }));
    // Search services
    final servicesSnap = await fireStore
        .collection(ApiUrl.servicePath)
        .where('searchKeywords', arrayContainsAny: [query.toLowerCase()]).get();
    results.addAll(servicesSnap.docs.map((doc) => {
          ...doc.data(),
          'type': 'service',
          'id': doc.id,
        }));
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  void _onShortcutTap(String keyword) {
    _searchController.text = keyword;
    _search(keyword);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _extractAllImageUrls(Map<String, dynamic> item) {
    List<String> allImageUrls = [];
    List<dynamic>? promoImages;
    if (item['promoImageUrls'] is List) {
      promoImages = item['promoImageUrls'] as List<dynamic>?;
    } else if (item['promoImageUrls'] is String &&
        (item['promoImageUrls'] as String).isNotEmpty) {
      promoImages = [(item['promoImageUrls'] as String)];
    } else if (item['thumbImageUrls'] is List) {
      promoImages = item['thumbImageUrls'] as List<dynamic>?;
    } else if (item['shopImageUrls'] is String &&
        (item['shopImageUrls'] as String).isNotEmpty) {
      promoImages = [(item['shopImageUrls'] as String)];
    }
    if (promoImages != null && promoImages.isNotEmpty) {
      allImageUrls.addAll(promoImages.cast<String>());
    }
    return allImageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products or services...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _results = [];
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.trim().isEmpty) {
                  setState(() {
                    _results = [];
                  });
                }
              },
              onSubmitted: _search,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_results.isEmpty && _searchController.text.isNotEmpty)
              const Expanded(child: Center(child: Text('No results found.')))
            else if (_results.isEmpty && _searchController.text.isEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Categories',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2, // Adjusted for icon layout
                        ),
                        // --- Use the new variable name ---
                        itemCount: shortcutCategories.length,
                        itemBuilder: (context, index) {
                          final shortcut = shortcutCategories[index];
                          return _buildCategoryCard(
                            title: shortcut.title,
                            icon: shortcut.icon,
                            color: shortcut.color,
                            onTap: () => _onShortcutTap(shortcut.title),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            else
              // Display search results
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final item = _results[index];
                    final allImageUrls = _extractAllImageUrls(item);
                    final imageUrl = allImageUrls.isNotEmpty
                        ? allImageUrls.first
                        : ApiUrl.defaultPlaceholderImage;

                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              item['type'] == 'product'
                                  ? Icons.shopping_bag
                                  : Icons.miscellaneous_services),
                        ),
                      ),
                      title: Text(item['businessTitle'] ??
                          item['eventName'] ??
                          item['brandName'] ??
                          item['modelName'] ??
                          'No Title'),
                      subtitle: Text(
                        item['registrationPlace'] ??
                            item['locationName'] ??
                            item['locationAddress'] ??
                            item['businessAddress'] ??
                            (item['type'] == 'product' ? 'Product' : 'Service'),
                      ),
                      onTap: () {
                        if (item['type'] == 'product') {
                          onProductDetailsTap(context, item);
                        } else if (item['type'] == 'service') {
                          onServiceDetailsScreenTap(context, item,
                              item['category'] ?? 'Uncategorized');
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
