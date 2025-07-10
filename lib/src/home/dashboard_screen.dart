import 'package:flutter/material.dart';

import '../adbanner/ad_carousel_widget.dart';
import '../dashboard/dashboard_list_widget.dart';
import '../services/pop_services_widgets.dart';

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
    return const SingleChildScrollView(
      child: Column(
        children: [
          AdCarouselWidget(),
          PopServicesWidgets(),
          SizedBox(height: 20.0),
          DashboardListViewWidget(),
          // Disclaimers(),
        ],
      ),
    );
  }
}
