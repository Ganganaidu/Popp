import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../products/category_list_widget.dart';
import '../../viewmodel/dashboard_viewmodel.dart';

class DashboardListViewWidget extends StatefulWidget {
  const DashboardListViewWidget({super.key});

  @override
  State<DashboardListViewWidget> createState() =>
      _DashboardListViewWidgetState();
}

class _DashboardListViewWidgetState extends State<DashboardListViewWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<DashboardViewModel>(context, listen: false)
            .loadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Center(child: Text("Error: ${viewModel.error}"));
        }

        if (viewModel.categories.isEmpty) {
          return const Center(child: Text("No products found."));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: viewModel.categories
              .map((category) => CategoryListWidget(
                    categoryName: category.name,
                    products: category.products ?? [],
                  ))
              .toList(),
        );
      },
    );
  }
}
