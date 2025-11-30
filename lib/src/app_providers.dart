import 'package:flutter/material.dart';
import 'package:popp/src/subscription/subscription_provider.dart';
import 'package:provider/provider.dart';

import 'adbanner/repository/ad_carousel_viewmodel.dart';
import 'adbanner/repository/ad_repository.dart';
import 'dashboard/repository/product_repository.dart';
import 'dashboard/repository/service_repository.dart';
import 'dashboard/viewmodel/dashboard_viewmodel.dart';
import 'dashboard/viewmodel/service_viewmodel.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => DashboardViewModel(ProductRepository())),
        ChangeNotifierProvider(
            create: (_) => AdCarouselViewModel(AdRepository())),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(
            create: (_) => ServiceViewModel(ServiceRepository())),
      ],
      child: child,
    );
  }
}
