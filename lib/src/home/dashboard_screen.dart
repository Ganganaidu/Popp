import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../adbanner/ad_carousel_widget.dart';
import '../dashboard/product_list_dashboard_screen.dart';
import '../dashboard/service_list_dashboard_screen.dart';
import '../dashboard/viewmodel/dashboard_viewmodel.dart';
import '../dashboard/viewmodel/service_viewmodel.dart';
import '../services/pop_services_widgets.dart';
import '../utils/build_extensions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final context = this.context;
      Provider.of<DashboardViewModel>(context, listen: false)
          .loadCategories(context, true);
      Provider.of<ServiceViewModel>(context, listen: false)
          .loadCategories(context, true);
    });
  }

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
          SizedBox(height: 15.0),
          PopServicesWidgets(),
          SizedBox(height: 12.0),
          ProductListDashboardScreen(),
          // ServiceListDashboardScreen(),
        ],
      ),
    );
  }
}
