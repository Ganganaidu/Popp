import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';
import 'widgets/service_card.dart';

class ServiceCategoryListWidget extends StatelessWidget {
  final String categoryName;
  final List<Map<String, dynamic>> services;

  const ServiceCategoryListWidget({
    super.key,
    required this.categoryName,
    required this.services,
  });

  void _navigateToCategoryPage(BuildContext context) {
    context.pushServiceListing(categoryName);
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb &&
        defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS;
    if (isWeb) {
      return _buildWebLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildWebLayout(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(context, theme, isWeb: true),
          const SizedBox(height: 16),
          _buildWebProductGrid(context),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth * 0.8; // Wider card for services

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(context, theme, isWeb: false),
          const SizedBox(height: 15),
          SizedBox(
            height: 220, // Adjust height based on card content
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: services.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final service = services[index];
                return ServiceCard(
                  service: service,
                  category: categoryName,
                  width: itemWidth,
                  onTap: () {
                    context.pushServiceDetail(service, categoryName);
                  },
                  isApproved: service['isApproved'] == true,
                );
              },
            ),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, TextTheme theme,
      {required bool isWeb}) {
    if (!isWeb) {
      return InkWell(
        onTap: () => _navigateToCategoryPage(context),
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _navigateToCategoryPage(context),
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  children: [
                    Text(
                      'VIEW ALL',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _navigateToCategoryPage(context),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isWeb ? 12.0 : 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                categoryName,
                style: TextStyle(
                  fontSize: isWeb ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                size: isWeb ? 20 : 18,
              ),
              onPressed: () => _navigateToCategoryPage(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebProductGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid based on available width
        int crossAxisCount;
        int maxItems;
        if (constraints.maxWidth > 1000) {
          crossAxisCount = 4;
          maxItems = 8;
        } else if (constraints.maxWidth > 700) {
          crossAxisCount = 3;
          maxItems = 6;
        } else {
          crossAxisCount = 2;
          maxItems = 4;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2, // Wider aspect ratio for service cards
          ),
          itemCount: services.length > maxItems ? maxItems : services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return ServiceCard(
              service: service,
              category: categoryName,
              width: 300,
              // Fixed width for grid items if needed, but GridView controls width
              onTap: () {
                context.pushServiceDetail(service, categoryName);
              },

              isApproved: service['isApproved'] == true,
            );
          },
        );
      },
    );
  }
}
