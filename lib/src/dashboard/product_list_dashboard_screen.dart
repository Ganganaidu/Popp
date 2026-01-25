import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../products/category_list_widget.dart';
import 'viewmodel/dashboard_viewmodel.dart';
import 'viewmodel/service_viewmodel.dart';

class ProductListDashboardScreen extends StatefulWidget {
  const ProductListDashboardScreen({super.key});

  @override
  State<ProductListDashboardScreen> createState() =>
      _ProductListDashboardScreenState();
}

class _ProductListDashboardScreenState extends State<ProductListDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    String countryCode = Localizations.localeOf(context).countryCode ?? 'US';
    return Consumer2<DashboardViewModel, ServiceViewModel>(
      builder: (context, viewModel, serviceViewModel, _) {
        if (viewModel.isLoading) {
          return _shimmerLoading();
        }

        if (viewModel.error != null) {
          return _buildMessageWidget(
            icon: Icons.error_outline,
            title: "Oops!",
            message: "Something went wrong.\n${viewModel.error}",
          );
        }

        if (viewModel.categories.isEmpty) {
          // Only show "No Products Found" if BOTH products and services are empty.
          // If services are present, we just return an empty container here,
          // because the ServiceListWidget (which is separate) will show the services.
          if (serviceViewModel.categories.isEmpty) {
            return _buildMessageWidget(
              icon: Icons.inventory_2_outlined,
              title: "No Products Found",
              message:
                  "Your product list is waiting to grow. Get started by adding one using our services!",
            );
          } else {
            return const SizedBox.shrink();
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: viewModel.categories
              .map((category) => CategoryListWidget(
                    categoryName: category.name,
                    products: (category.products ?? []).reversed.toList(),
                    countryCode: countryCode,
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
