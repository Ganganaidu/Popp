import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:popp/src/models/pop_category.dart';

import '../../api/api_url.dart';
import '../../utils/product_utils.dart';

class ServiceRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<PopCategory>> fetchServicesGroupedByCategory(bool isApproved) async {
    QuerySnapshot snapshot = await _db
        .collection(ApiUrl.servicePath)
        .where('isApproved', isEqualTo: isApproved)
        .where('isActive', isEqualTo: true)
        .get();
    return _processSnapshot(snapshot);
  }

  Stream<List<PopCategory>> getServicesStream(bool isApproved) {
    return _db
        .collection(ApiUrl.servicePath)
        .where('isApproved', isEqualTo: isApproved)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) => _processSnapshot(snapshot));
  }

  Future<List<PopCategory>> _processSnapshot(QuerySnapshot snapshot) async {
    if (snapshot.docs.isEmpty) return [];

    List<Map<String, dynamic>> services = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> serviceMap =
          Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
      serviceMap['id'] = doc.id;
      services.add(serviceMap);
    }

    Map<String, List<Map<String, dynamic>>> grouped = {};

    // Initialize groups with empty lists for all target categories
    for (var category in ProductUtils.listYourServiceCategories) {
      grouped[category] = [];
    }

    for (var service in services) {
      // The category field in service documents seems to be 'category' (String)
      // based on ServiceListingScreen usage: widget.category
      // and ProductUtils.listYourServiceCategories are strings.
      // We need to check if the service has a 'category' field that matches.
      
      // In ServiceListingScreen:
      // final List<String> categories = category.split(',').map((e) => e.trim()).toList();
      // _productsService.fetchServicesByCategories(categories, ...)
      
      // Assuming 'category' field exists and holds the category name.
      // Or maybe 'selectedCategory' or similar. 
      // Let's check ServiceListingScreen again or assume 'category' or check how fetchServicesByCategories works.
      
      // In FirebaseApiService (which ServiceListingScreen uses):
      // .where('category', whereIn: categories)
      
      // So the field name is 'category'.
      
      final categoryName = service['category'] as String?;
      
      if (categoryName != null && grouped.containsKey(categoryName)) {
        grouped[categoryName]!.add(service);
      }
    }

    // Convert to List<PopCategory>
    // We don't have categoryId for these string categories, so we'll use the name as ID too.
    List<PopCategory> result = [];
    
    for (var categoryName in ProductUtils.listYourServiceCategories) {
      if (grouped[categoryName] != null && grouped[categoryName]!.isNotEmpty) {
        result.add(PopCategory(
          categoryId: categoryName, // Use name as ID
          name: categoryName,
          products: grouped[categoryName], // We reuse 'products' field for services
        ));
      }
    }

    return result;
  }
}
