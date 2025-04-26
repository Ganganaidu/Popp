import 'package:flutter/material.dart';

import 'package:poppflutter/src/disclaimers/app_disclaimers.dart';
import 'homewidgets/carousel_widget.dart';
import 'homewidgets/dashboard_list_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Dashboard build context: $context");
    return SingleChildScrollView(
      // Wrap the entire content with SingleChildScrollView
      child: Column(
        children: [
          const CarouselWidget(),
          DashboardListViewWidget(context: context),
          const Disclaimers(),
        ],
      ),
    );
  }
}
