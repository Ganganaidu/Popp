import 'package:flutter/material.dart';

import 'package:popp/src/disclaimers/app_disclaimers.dart';
import '../adbanner/ad_carousel_widget.dart';
import '../utils/app_loger.dart';
import 'homewidgets/carousel_widget.dart';
import '../dashboard/dashboard_list_widget.dart';
import 'homewidgets/pop_services_widgets.dart';

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
    AppLogger.d("Dashboard build context: $context");
    return const SingleChildScrollView(
      // Wrap the entire content with SingleChildScrollView
      child: Column(
        children: [
          AdCarouselWidget(),
          PopServicesWidgets(),
          SizedBox(height: 20.0),
          DashboardListViewWidget(),
          Disclaimers(),
        ],
      ),
    );
  }
}
