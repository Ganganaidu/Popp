import 'package:flutter/material.dart';
import 'package:popp/src/chat/chat_service.dart';
import 'package:popp/src/models/pop_category.dart';
import 'package:popp/src/utils/app_constants.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:popp/src/utils/product_utils.dart';
import 'package:provider/provider.dart';
import '../navigation/app_routes.dart';

class WebSideBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const WebSideBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? context.primaryColorDark : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // _buildLogo(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildMenuSection(context, textColor),
                const Divider(height: 32, thickness: 1),
                _buildCategoriesSection(context, textColor, isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          const Text(
            "Biker",
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              // Or dynamic based on theme, but design showed black/green
              fontWeight: FontWeight.bold,
              fontFamily: 'Orbitron',
            ),
          ),
          Text(
            "verse",
            style: TextStyle(
              fontSize: 24,
              color: context.primaryColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'Orbitron',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            "Menu",
            style: TextStyle(
              color: context.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        _buildMenuItem(
          context,
          index: 0,
          allowedIndex: 0,
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: Constants.home,
          textColor: textColor,
        ),
        _buildMenuItem(
          context,
          index: 1,
          // Using 1 for Products/Explore
          allowedIndex: 1,
          icon: Icons.search_outlined,
          activeIcon: Icons.search_sharp,
          label: Constants.explore,
          // "Products" in design, but "Explore" in app constants
          textColor: textColor,
        ),
        // Chat Item with Badge
        StreamBuilder<int>(
          stream: context.read<ChatService>().totalUnreadCountStream,
          builder: (context, snapshot) {
            final int count = snapshot.data ?? 0;
            return _buildMenuItem(
              context,
              index: 2,
              allowedIndex: 2,
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble_outlined,
              // Badge is tricky inside generic builder, let's custom build it if needed or just append badge
              label: Constants.chat,
              textColor: textColor,
              badgeCount: count,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required int index,
    required int allowedIndex,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color textColor,
    int? badgeCount,
  }) {
    final isSelected = selectedIndex == allowedIndex;
    return InkWell(
      onTap: () => onItemTapped(allowedIndex),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Badge(
              isLabelVisible: (badgeCount ?? 0) > 0,
              label: Text('${badgeCount ?? 0}'),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(
      BuildContext context, Color textColor, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            "CATEGORIES",
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),

        // 1. Premium Bikes (Single Item)
        _buildCategoryTile(
          context,
          title: ProductUtils.premiumBikes,
          onTap: () =>
              _navigateToTargetPage(context, ProductUtils.premiumBikes, null),
          textColor: textColor,
        ),

        // 2. Categories from catList (e.g. Protection Gear, Luggage - usually have subcats)
        ...catList
            .where((c) =>
                c.name != ProductUtils.premiumBikes &&
                c.name != "Other Products")
            .map((category) {
          if (category.subcategories != null &&
              category.subcategories!.isNotEmpty) {
            return ExpansionTile(
              title: Text(
                category.name,
                style: TextStyle(fontSize: 14, color: textColor),
              ),
              childrenPadding: const EdgeInsets.only(left: 16),
              collapsedIconColor: Colors.grey,
              iconColor: context.primaryColor,
              shape: const Border(),
              // Remove default borders
              children: category.subcategories!.map((sub) {
                return ListTile(
                  title: Text(
                    sub,
                    style: TextStyle(
                        fontSize: 13, color: textColor.withOpacity(0.8)),
                  ),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  onTap: () =>
                      _navigateToTargetPage(context, category.name, sub),
                );
              }).toList(),
            );
          } else {
            return _buildCategoryTile(
              context,
              title: category.name,
              onTap: () => _navigateToTargetPage(context, category.name, null),
              textColor: textColor,
            );
          }
        }),

        // 3. Service Categories (Find Mechanic, Bike Rentals, etc.)
        ...ProductUtils.listYourServiceCategories.map((serviceCat) {
          return _buildCategoryTile(
            context,
            title: serviceCat,
            onTap: () => _navigateToTargetPage(context, serviceCat, null),
            textColor: textColor,
          );
        }),
      ],
    );
  }

  Widget _buildCategoryTile(BuildContext context,
      {required String title,
      required VoidCallback onTap,
      required Color textColor}) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 14, color: textColor),
      ),
      dense: true,
      visualDensity: VisualDensity.compact,
      onTap: onTap,
    );
  }

  void _navigateToTargetPage(
      BuildContext context, String categoryName, String? subCategory) {
    if (!categoryName.contains(ProductUtils.premiumBikes) &&
        subCategory == null) {
      // It's a service listing
      context.pushServiceListing(categoryName, subCategory: subCategory);
    } else {
      // It's a product listing
      context.pushCategoryDetail(
          CategoryDetailArgs.forCategory(categoryName, subCategory: subCategory));
    }
  }
}
