import 'package:flutter/material.dart';
import 'package:popp/src/widgets/title_text.dart';

import '../../api/firebase/firebase_api_service.dart';
import '../../navigation/nav_router.dart';
import '../../utils/product_utils.dart';
import '../widgets/service_card.dart';
import '../../widgets/web_constrained_box.dart';

class ServiceListingScreen extends StatefulWidget {
  final String category;
  final String? subCategory;

  const ServiceListingScreen(
      {super.key, required this.category, required this.subCategory});

  @override
  State<ServiceListingScreen> createState() => _ServiceListingScreenState();
}

class _ServiceListingScreenState extends State<ServiceListingScreen> {
  final FirebaseApiService _productsService = FirebaseApiService();
  late Future<List<Map<String, dynamic>>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    String category = widget.category;
    if (category.contains(ProductUtils.premiumInspection)) {
      // Only display Premium Inspection, and
      // search for 'Book your Bike service' and
      // filter by doYouInspectPremiumBikes == 'Yes'
      _servicesFuture = _productsService
          .fetchServicesByCategories([ProductUtils.findMechanic], true).then(
              (services) => services
                  .where((s) => s['doYouInspectPremiumBikes'] == 'Yes')
                  .toList());
    } else {
      final List<String> categories =
          category.split(',').map((e) => e.trim()).toList();
      _servicesFuture = _productsService.fetchServicesByCategories(
          categories, true,
          subCategory: widget.subCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = ProductUtils.getServiceAppBarTitle(widget.category);
    return Scaffold(
      appBar: AppBar(
        title: TitleText(appBarTitle),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    // Only this icon when NO services found
                    size: 100, // Adjust size as needed
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No services found for this category yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Be the first to list a "${widget.category}" service!',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            final services = snapshot.data!;
            return WebConstrainedBox(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: services.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return SizedBox(
                      height: 220,
                      child: ServiceCard(
                        service: service,
                        category: widget.category,
                        width: double.infinity,
                        onTap: () {
                          onServiceDetailsScreenTap(
                              context, service, widget.category);
                        },
                        isApproved: service['isApproved'] == true,
                      ),
                    );
                  },
                ),
            );
          }
        },
      ),
    );
  }
}
