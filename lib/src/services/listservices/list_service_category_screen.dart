import 'package:flutter/material.dart';
import 'package:popp/src/toolbar/common_app_bar.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:popp/src/utils/product_utils.dart';
import 'package:popp/src/widgets/title_text.dart';

import '../../navigation/app_routes.dart';

class ListServiceCategoryScreen extends StatelessWidget {
  const ListServiceCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        titleWidget: TitleText("Select Category"),
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
        onTap: () => context.pushListServiceForm(category: category),
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
    // Use the current theme's icon color so icons adapt to light/dark modes
    final Color iconColor = Theme.of(context).iconTheme.color ?? Theme.of(context).colorScheme.onSurface;

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
    } else if (category == ProductUtils.towingService) {
      assetPath = 'assets/towing_service.png';
    } else {
      return Icon(
        Icons.category_outlined,
        size: 32,
        color: iconColor,
      );
    }

    // Tint the asset with the theme icon color. This works best for monochrome/transparent
    // assets. Use srcIn so the provided color replaces the image color.
    return Image.asset(
      assetPath,
      width: 64,
      height: 64,
      fit: BoxFit.contain,
      color: iconColor,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}
