import 'package:flutter/material.dart';
import 'package:poppflutter/src/repository/product_repository.dart';
import 'package:poppflutter/src/viewmodel/dashboard_viewmodel.dart';
import 'package:provider/provider.dart';
import 'adbanner/repository/ad_carousel_viewmodel.dart';
import 'adbanner/repository/ad_repository.dart';

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
        // Add other global ViewModels here
      ],
      child: child,
    );
  }
}
