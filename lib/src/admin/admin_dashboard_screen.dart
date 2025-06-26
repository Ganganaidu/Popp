import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/firebase/firebase_save_prodcuts_api.dart';
import 'package:popp/src/utils/build_extensions.dart'; // Import your build_extensions

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseProductsService _productsService = FirebaseProductsService();

  // Replace with your actual admin UID from Firestore Rules
  final String _adminUid = 'XsKNJMeiR2NuaLslm428EWL6zOv1';

  bool get _isAdmin => FirebaseAuth.instance.currentUser?.uid == _adminUid;

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Approval Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Unapproved Services',
                  icon: Icon(Icons.miscellaneous_services)),
              Tab(text: 'Unapproved Products', icon: Icon(Icons.shopping_bag)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUnapprovedServices(),
            _buildUnapprovedProducts(),
          ],
        ),
      ),
    );
  }

  Widget _buildUnapprovedServices() {
    // Example categories, adjust as needed
    final List<String> allCategories = [
      'Book your service', 'Bike Rentals', 'Track day', 'Training day'
    ];
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _productsService.fetchServicesByCategories(allCategories, false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: \\${snapshot.error}'));
        }
        final services = snapshot.data ?? [];
        if (services.isEmpty) {
          return Center(child: Text('All services approved!'));
        }
        // Group by category
        final Map<String, List<Map<String, dynamic>>> grouped = {};
        for (final service in services) {
          final String category = service['category'] ?? 'Uncategorized';
          grouped.putIfAbsent(category, () => []).add(service);
        }
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: grouped.entries.map((entry) {
            final category = entry.key;
            final items = entry.value;
            return ExpansionTile(
              title: Text(
                  '$category (\\${items.length})', style: context.titleLarge),
              children: items.map((service) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                        service['businessTitle'] ?? service['eventName'] ??
                            'No Title'),
                    subtitle: Text(service['businessDescription'] ??
                        service['eventDetailedDescription'] ?? ''),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/serviceDetail',
                        arguments: {
                          'serviceData': service,
                          'category': category,
                          'isAdmin': true,
                        },
                      );
                    },
                  ),
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildUnapprovedProducts() {
    return FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
      future: _productsService.fetchProductsGroupedByCategory(
          isApproved: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: \\${snapshot.error}'));
        }
        final grouped = snapshot.data ?? {};
        if (grouped.isEmpty) {
          return const Center(child: Text('All products approved!'));
        }
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: grouped.entries.map((entry) {
            final category = entry.key;
            final items = entry.value;
            return ExpansionTile(
              title: Text(
                  '$category (\\${items.length})', style: context.titleLarge),
              children: items.map((product) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  elevation: 2,
                  child: ListTile(
                    title: Text(product['modelName'] ?? 'No Title'),
                    subtitle: Text(product['description'] ?? ''),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/productDetail',
                        arguments: {
                          'productData': product,
                          'category': category,
                          'isAdmin': true,
                        },
                      );
                    },
                  ),
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }
}
