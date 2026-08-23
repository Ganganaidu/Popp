import 'package:flutter/material.dart';

import '../api/api_url.dart';
import '../navigation/app_routes.dart';
import '../toolbar/common_app_bar.dart';
import '../widgets/app_network_image.dart';
import 'repository/search_repository.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final SearchRepository _searchRepository = SearchRepository();
  bool _isLoading = false;
  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

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
    final results = await _searchRepository.search(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        titleWidget: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search products or services...',
            border: InputBorder.none,
            filled: false,
          ),
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty && _searchController.text.isNotEmpty
              ? const Center(child: Text('No results found'))
              : _results.isEmpty
                  ? const Center(child: Text('Search results will appear here'))
                  : _buildSearchResults(context),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];
        final allImageUrls = _extractAllImageUrls(item);
        final imageUrl = allImageUrls.isNotEmpty
            ? allImageUrls.first
            : ApiUrl.defaultPlaceholderImage;

        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              if (item['type'] == 'product') {
                context.pushProductDetail(item);
              } else if (item['type'] == 'service') {
                context.pushServiceDetail(
                    item, item['category'] ?? 'Uncategorized');
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: AppNetworkImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: Icon(
                          item['type'] == 'product'
                              ? Icons.shopping_bag
                              : Icons.miscellaneous_services,
                          size: 30,
                        ),
                      ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item['businessTitle'] ??
                        item['eventName'] ??
                        item['brandName'] ??
                        item['modelName'] ??
                        'No Title',
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    item['registrationPlace'] ??
                        item['locationName'] ??
                        item['locationAddress'] ??
                        item['businessAddress'] ??
                        (item['type'] == 'product' ? 'Product' : 'Service'),
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
}
