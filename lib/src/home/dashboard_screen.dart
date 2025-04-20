import 'package:flutter/material.dart';

import 'package:poppflutter/src/homepagewidgets/carousel_widget.dart';
import 'package:poppflutter/src/homepagewidgets/dashboard_list_widget.dart';
import 'package:poppflutter/src/disclaimers/app_disclaimers.dart';

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
    return const Scaffold(
      body: SingleChildScrollView(
        // Wrap the entire content with SingleChildScrollView
        child: Column(
          children: [
            CarouselWidget(),
            DashboardListViewWidget(),
            SizedBox(height: 50),
            Disclaimers(),
          ],
        ),
      ),
    );
  }
}

