import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/widgets/title_text.dart';
import 'package:popp/src/widgets/web_constrained_box.dart';

import '../api/api_url.dart';
import 'list_grid_view.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    var primaryColor = Theme.of(context).primaryColor;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const TitleText("Favorites")),
        body: WebConstrainedBox(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Please log in to see your favorites."),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white),
                  child: const Text("Login"),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const TitleText("My Favorites"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.storefront), text: "Products"),
            Tab(icon: Icon(Icons.miscellaneous_services), text: "Services"),
          ],
        ),
      ),
      body: WebConstrainedBox(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Using the reusable widget for Products
            ListingsGridView(
              query: FirebaseFirestore.instance
                  .collection(ApiUrl.productsPath)
                  .where('favoritedBy', arrayContains: user.uid),
              showOptionsMenu: false, // Show edit/delete options
            ),
            // Using the reusable widget for Services
            ListingsGridView(
              query: FirebaseFirestore.instance
                  .collection(ApiUrl.servicePath)
                  .where('favoritedBy', arrayContains: user.uid),
              showOptionsMenu: false, // Show edit/delete options
            ),
          ],
        ),
      ),
    );
  }
}
