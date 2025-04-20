import 'package:flutter/material.dart';
import 'package:poppflutter/src/home/search_screen.dart';
import 'package:poppflutter/src/home/dashboard_screen.dart';

// TODO example screen with top viewpage sliding.
class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(
                tabs: [
                  Tab(
                    text: 'Biker',
                  ),
                  Tab(
                    text: 'Luggage',
                  ),
                  Tab(
                    text: 'Lights',
                  ),
                ],
              )
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DashboardScreen(),
          ],
        ),
      ),
    );
  }
}
