import 'dart:developer' as AppLogger;

import 'package:flutter/material.dart';
import 'package:popp/src/home/search_screen.dart';
import 'package:popp/src/models/pop_category.dart';
import 'package:popp/src/products/category_detail_screen.dart';
import 'package:popp/src/utils/product_content_data.dart';
import '../models/shortcut_category.dart';
import '../navigation/nav_router.dart';
import '../utils/app_utils.dart';
import '../utils/product_utils.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSearchbar(context),
          const SizedBox(height: 24),
          _buildExploreCategories(context, isDarkMode),
          const SizedBox(height: 24),
          ..._buildSubCategorySections(context, isDarkMode),
        ],
      ),
    );
  }

  void _navigateToTargetPage(
      BuildContext context, String categoryName, String? subCategory) {
    AppLogger.log('Navigating to category: $categoryName');
    if (!categoryName.contains(ProductUtils.premiumBikes) &&
        subCategory == null) {
      AppLogger.log('Navigating to service listing for: $categoryName');
      onServiceListingTap(context, categoryName, subCategory, false);
    } else {
      navigateToCategoryPage(context, categoryName, subCategory, null);
    }
  }

  Widget _buildSearchbar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search products or services...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionGrid(BuildContext context, bool isDarkMode,
      List<String> items, void Function(String) onTap) {
    const int crossAxisCount = 2;
    final int rowCount = (items.length / crossAxisCount).ceil();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final int row = index ~/ crossAxisCount;
        final int col = index % crossAxisCount;
        final bool isTop = row == 0;
        final bool isBottom = row == rowCount - 1;
        final bool isLeft = col == 0;
        final bool isRight = col == crossAxisCount - 1;
        BorderRadius borderRadius = BorderRadius.zero;
        if (isTop && isLeft) {
          borderRadius = const BorderRadius.only(topLeft: Radius.circular(18));
        } else if (isTop && isRight) {
          borderRadius = const BorderRadius.only(topRight: Radius.circular(18));
        } else if (isBottom && isLeft) {
          borderRadius =
              const BorderRadius.only(bottomLeft: Radius.circular(18));
        } else if (isBottom && isRight) {
          borderRadius =
              const BorderRadius.only(bottomRight: Radius.circular(18));
        }
        return InkWell(
          onTap: () => onTap(items[index]),
          borderRadius: borderRadius,
          child: Container(
              margin: const EdgeInsets.all(1.0),
              // space between cards
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .cardColor, // use light version of primary color
                borderRadius: borderRadius,
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              child: Text(
                items[index],
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              )),
        );
      },
    );
  }

  Widget _buildExploreCategories(BuildContext context, bool isDarkMode) {
    final List<String> categoriesWithPremiumBikes = [
      ...serviceCategories,
      ProductUtils.premiumBikes,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text(
            'Explore Categories',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionGrid(
          context,
          isDarkMode,
          categoriesWithPremiumBikes,
          (name) => _navigateToTargetPage(context, name, null),
        ),
      ],
    );
  }

  List<Widget> _buildSubCategorySections(
      BuildContext context, bool isDarkMode) {
    final sections = <Widget>[];
    for (final category in catList) {
      if (category.subcategories != null &&
          category.subcategories!.isNotEmpty) {
        sections.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  'Explore ${category.name}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionGrid(
                context,
                isDarkMode,
                category.subcategories!,
                (name) => _navigateToTargetPage(context, category.name, name),
              ),
              const SizedBox(height: 16)
            ],
          ),
        );
      }
    }
    return sections;
  }
}
