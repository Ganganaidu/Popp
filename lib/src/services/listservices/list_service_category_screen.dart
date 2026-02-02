import 'package:flutter/material.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:popp/src/utils/product_utils.dart';
import 'package:popp/src/widgets/title_text.dart';

import 'list_service_form_screen.dart';

class ListServiceCategoryScreen extends StatelessWidget {
  const ListServiceCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitleText("Select Category"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.1, 
          ),
          itemCount: ProductUtils.listYourServiceCategories.length,
          itemBuilder: (context, index) {
            final category = ProductUtils.listYourServiceCategories[index];
            return _buildCategoryCard(context, category);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category) {
    // Generate a consistent color based on category name
    final randomColor = Colors
        .accents[category.hashCode.abs() % Colors.accents.length];

    return Card(
      elevation: 6, // Slightly increased elevation for better shadow visibility
      shadowColor: randomColor.withOpacity(0.5), // Use the colored shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // Border removed as per request
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListServiceFormScreen(category: category),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: randomColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(category),
                size: 32,
                color: context.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                category,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category == ProductUtils.findMechanic) return Icons.build_circle_outlined;
    if (category == ProductUtils.bikeRentals) return Icons.two_wheeler_outlined;
    if (category == ProductUtils.trackDay) return Icons.track_changes;
    if (category == ProductUtils.trainingDay) return Icons.gradient_rounded;
    if (category == ProductUtils.accessoryStore) return Icons.shopping_bag_outlined;
    if (category == ProductUtils.tyreShop) return Icons.tire_repair;
    return Icons.category_outlined;
  }
}
