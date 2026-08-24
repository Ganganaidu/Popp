import '../navigation/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:popp/src/toolbar/common_app_bar.dart';
import '../widgets/title_text.dart';
import 'package:popp/src/widgets/web_constrained_box.dart';
import 'list_grid_view.dart';
import 'repository/listings_repository.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ListingsRepository _repository = ListingsRepository();

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
        appBar: const CommonAppBar(titleWidget: TitleText("My Listings")),
        body: WebConstrainedBox(
          child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Please log in to see your listings."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.goLogin(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary),
                child: const Text("Login"),
              )
            ],
          ),
        ),
        ),
      );
    }

    return Scaffold(
      appBar: CommonAppBar(
        titleWidget: const TitleText("My Listings"),
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
      body: WebConstrainedBox(
        child: TabBarView(
        controller: _tabController,
        children: [
          // Using the reusable widget for Products
          ListingsGridView(
            query: _repository.myProducts(user.uid),
            showOptionsMenu: true,
          ),
          // Using the reusable widget for Services
          ListingsGridView(
            query: _repository.myServices(user.uid),
            showOptionsMenu: true,
          ),
        ],
      ),
      ),
    );
  }
}
