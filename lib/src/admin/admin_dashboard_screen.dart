import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_constants.dart';

import '../api/api_url.dart';
import '../settings/list_grid_view.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  // final FirebaseApiService _firebaseApiService = FirebaseApiService();
  late TabController _tabController;

  bool get _isAdmin =>
      FirebaseAuth.instance.currentUser?.uid == Constants.adminUserId;

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
    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Dashboard')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.red),
              SizedBox(height: 20),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'You do not have administrative privileges to view this page.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
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
                .where('isApproved', isEqualTo: false),
            showOptionsMenu: false, // Show edit/delete options
          ),
          // Using the reusable widget for Services
          ListingsGridView(
            query: FirebaseFirestore.instance
                .collection(ApiUrl.servicePath)
                .where('isApproved', isEqualTo: false),
            showOptionsMenu: false, // Show edit/delete options
          ),
        ],
      ),
    );
  }
}
