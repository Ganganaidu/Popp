import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../api/api_url.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
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

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
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
      body: const Center(
        child: Text('Search results will appear here'),
      ),
    );
  }
}
