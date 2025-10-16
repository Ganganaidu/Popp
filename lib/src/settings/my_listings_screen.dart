import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../api/api_url.dart';
import '../widgets/title_text.dart';
import 'list_grid_view.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen>
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

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const TitleText("My Listings")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Please log in to see your listings."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white),
                child: const Text("Login"),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const TitleText("My Listings"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.storefront), text: "Products"),
            Tab(icon: Icon(Icons.miscellaneous_services), text: "Services"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Using the reusable widget for Products
          ListingsGridView(
            query: FirebaseFirestore.instance
                .collection(ApiUrl.productsPath)
                .where('userId', isEqualTo: user.uid),
            showOptionsMenu: true, // Show edit/delete options
          ),
          // Using the reusable widget for Services
          ListingsGridView(
            query: FirebaseFirestore.instance
                .collection(ApiUrl.servicePath)
                .where('userId', isEqualTo: user.uid),
            showOptionsMenu: true, // Show edit/delete options
          ),
        ],
      ),
    );
  }
}
