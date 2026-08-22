import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/toolbar/common_app_bar.dart';
import 'package:popp/src/utils/app_constants.dart';

import '../adbanner/ui/ad_list_page.dart';
import '../api/api_url.dart';
import '../settings/list_grid_view.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool get _isAdmin =>
      FirebaseAuth.instance.currentUser?.uid == Constants.adminUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        appBar: const CommonAppBar(title: 'Admin Dashboard'),
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
      appBar: CommonAppBar(
        title: 'Admin Dashboard',
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.storefront), text: "Products"),
            Tab(icon: Icon(Icons.miscellaneous_services), text: "Services"),
            Tab(icon: Icon(Icons.campaign), text: "Ads"),
            Tab(icon: Icon(Icons.inventory_2_outlined), text: "All Products"),
            Tab(icon: Icon(Icons.home_repair_service_outlined), text: "All Services"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListingsGridView(
            query: FirebaseFirestore.instance
                .collection(ApiUrl.productsPath)
                .where(Filter.or(
                  Filter('isApproved', isEqualTo: false),
                  Filter('hasPendingUpdate', isEqualTo: true),
                )),
            showOptionsMenu: false,
          ),
          ListingsGridView(
            query: FirebaseFirestore.instance
                .collection(ApiUrl.servicePath)
                .where(Filter.or(
                  Filter('isApproved', isEqualTo: false),
                  Filter('hasPendingUpdate', isEqualTo: true),
                )),
            showOptionsMenu: false,
          ),
          const AdListPage(),
          ListingsGridView(
            query: FirebaseFirestore.instance
                .collection(ApiUrl.productsPath)
                .where('isApproved', isEqualTo: true)
                .where('isSold', isEqualTo: false)
                .orderBy('createdAt', descending: true),
            showAdminSoldOption: true,
          ),
          ListingsGridView(
            query: FirebaseFirestore.instance
                .collection(ApiUrl.servicePath)
                .where('isApproved', isEqualTo: true)
                .where('isSold', isEqualTo: false)
                .orderBy('createdAt', descending: true),
            showAdminSoldOption: true,
          ),
        ],
      ),
    );
  }
}