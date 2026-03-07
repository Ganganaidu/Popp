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
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 1.0,
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
    return Card(
      elevation: 6, // Slightly increased elevation for better shadow visibility
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _getCategoryIcon(category, context),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding:
                  const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 20.0),
              child: Text(
                category,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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

  Widget _getCategoryIcon(String category, BuildContext context) {
    String assetPath;

    if (category == ProductUtils.findMechanic) {
      assetPath = 'assets/find_mechanic.png';
    } else if (category == ProductUtils.bikeRentals) {
      assetPath = 'assets/bike_rentals.png';
    } else if (category == ProductUtils.trackDay) {
      assetPath = 'assets/track_training_day.png';
    } else if (category == ProductUtils.trainingDay) {
      assetPath = 'assets/track_training_day.png';
    } else if (category == ProductUtils.accessoryStore) {
      assetPath = 'assets/accessory_store.png';
    } else if (category == ProductUtils.tyreShop) {
      assetPath = 'assets/tyre_shops.png';
    } else {
      return Icon(
        Icons.category_outlined,
        size: 32,
        color: context.primaryColor,
      );
    }

    return Image.asset(
      assetPath,
      width: 200,
      height: 200,
    );
  }
}
