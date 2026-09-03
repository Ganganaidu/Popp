import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/toolbar/common_app_bar.dart';
import 'package:popp/src/utils/app_constants.dart';

import '../adbanner/ui/ad_list_page.dart';
import '../settings/list_grid_view.dart';
import 'repository/admin_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminRepository _repository = AdminRepository();

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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'You do not have administrative privileges to view this page.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
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
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
            query: _repository.pendingProducts(),
            showOptionsMenu: false,
            isAdmin: true,
          ),
          ListingsGridView(
            query: _repository.pendingServices(),
            showOptionsMenu: false,
            isAdmin: true,
          ),
          const AdListPage(),
          ListingsGridView(
            query: _repository.approvedProducts(),
            showAdminSoldOption: true,
            isAdmin: true,
          ),
          // Services (repair shops, stores, events…) are never "sold", so this
          // tab shows all approved services with no sold filter / sold action.
          ListingsGridView(
            query: _repository.approvedServices(),
            isAdmin: true,
          ),
        ],
      ),
    );
  }
}