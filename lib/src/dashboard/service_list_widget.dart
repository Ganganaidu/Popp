import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../services/service_category_list_widget.dart';
import 'viewmodel/service_viewmodel.dart';

class ServiceListWidget extends StatefulWidget {
  const ServiceListWidget({super.key});

  @override
  State<ServiceListWidget> createState() => _ServiceListWidgetState();
}

class _ServiceListWidgetState extends State<ServiceListWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceViewModel>(
      builder: (context, viewModel, _) {

        if (viewModel.isLoading) {
          return _shimmerLoading();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: viewModel.categories
              .map((category) => ServiceCategoryListWidget(
                    categoryName: category.name,
                    services: category.products ?? [],
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageWidget({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Colors.grey[500]),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerLoading() {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(width: 60, height: 60, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            height: 16,
                            width: double.infinity,
                            color: Colors.white),
                        const SizedBox(height: 8),
                        Container(height: 14, width: 150, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
