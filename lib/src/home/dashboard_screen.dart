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
    final isWeb = kIsWeb && context.isDesktop;

    if (isWeb) {
      return _buildWebLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildWebLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Hero section with ad carousel - centered with max width
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildWebHeroSection(),
            ),
          ),
          const SizedBox(height: 48),
          // Services section - full width with centered content
          _buildWebServicesSection(),
          const SizedBox(height: 48),
          // Products section - full width with centered content
          _buildWebProductsSection(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return const SingleChildScrollView(
      child: Column(
        children: [
          _MobileHeroStack(),
          SizedBox(height: 12.0),
          ProductListDashboardScreen(),
          // ServiceListDashboardScreen(),
        ],
      ),
    );
  }

  Widget _buildWebHeroSection() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: const AdCarouselWidget(),
      ),
    );
  }

  Widget _buildWebServicesSection() {
    return Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const PopServicesWidgets(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebProductsSection() {
    return Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const ProductListDashboardScreen(),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const ServiceListDashboardScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileHeroStack extends StatelessWidget {
  const _MobileHeroStack();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 500, // Reduced height to fit the new design
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            bottom: 50, // Leave space at bottom so image doesn't go all the way down behind the list
            child: AdCarouselWidget(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0, // Align to bottom of the sized box
            child: PopServicesWidgets(),
          ),
        ],
      ),
    );
  }
}
