import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../navigation/nav_router.dart';
import '../utils/app_constants.dart';

class ExploreProductsScreen extends StatefulWidget {
  const ExploreProductsScreen({super.key});

  @override
  State<ExploreProductsScreen> createState() => _ExploreProductsScreenState();
}

class _ExploreProductsScreenState extends State<ExploreProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _results = [];
  String _lastQuery = '';

  // Shortcuts for default suggestions
  final List<String> _shortcuts = [
    'Bike Rentals',
    'Events',
    'Accessories',
    'Premium bikes',
    'Track day',
    'Training day',
  ];

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
      _lastQuery = query;
    });
    final firestore = FirebaseFirestore.instance;
    final List<Map<String, dynamic>> results = [];
    // Search products
    final productsSnap = await firestore
        .collection(Constants.productsPath)
        .where('searchKeywords', arrayContainsAny: [query.toLowerCase()]).get();
    results.addAll(productsSnap.docs.map((doc) => {
          ...doc.data(),
          'type': 'product',
          'id': doc.id,
        }));
    // Search services
    final servicesSnap = await firestore
        .collection(Constants.servicePath)
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

  // Returns a list of all image URLs from the item (product or service)
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
        padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
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
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (!_isLoading &&
                _results.isEmpty &&
                _searchController.text.isNotEmpty)
              const Center(child: Text('No results found.')),
            // Default details/shortcuts when no search is active
            if (!_isLoading &&
                _results.isEmpty &&
                _searchController.text.isEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'What can you search?',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Try searching for products, services, or use these shortcuts:',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _shortcuts
                          .map((shortcut) => ActionChip(
                                label: Text(shortcut),
                                onPressed: () => _onShortcutTap(shortcut),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            if (!_isLoading && _results.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final item = _results[index];
                    Widget? leadingWidget;
                    // Try to get image URL from common fields and lists
                    final allImageUrls = _extractAllImageUrls(item);
                    final imageUrl = allImageUrls.isNotEmpty
                        ? allImageUrls.first
                        : Constants.defaultPlaceholderImage;
                    if (imageUrl.isNotEmpty) {
                      leadingWidget = ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              item['type'] == 'product'
                                  ? Icons.shopping_bag
                                  : Icons.miscellaneous_services),
                        ),
                      );
                    } else {
                      leadingWidget = Icon(item['type'] == 'product'
                          ? Icons.shopping_bag
                          : Icons.miscellaneous_services);
                    }
                    return ListTile(
                      leading: leadingWidget,
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
}
