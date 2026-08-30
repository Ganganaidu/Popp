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
  Widget build(BuildContext context) => _buildMobileLayout(context);

  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth * 0.8; // Wider card for services

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(context, theme),
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

  Widget _buildCategoryHeader(BuildContext context, TextTheme theme) {
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.55),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
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
}
