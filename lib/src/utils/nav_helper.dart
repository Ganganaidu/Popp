import 'package:flutter/material.dart';
import '../bikes/vehicle_details_widget_page.dart';
import '../home/dashboard_screen.dart';
import '../home/help_screen.dart';
import '../home/our_services.dart';

class NavHelper {
  // Singleton instance
  static final NavHelper _instance = NavHelper._internal();

  // Factory constructor to return the singleton instance
  factory NavHelper() {
    return _instance;
  }

  // Private constructor
  NavHelper._internal() {
    initializeWidgetOptions();
  }

  // Define a list of GlobalKeys for each Navigator
  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  // Define routes for each tab
  final Map<String, WidgetBuilder> routes = {
    '/vehicleDetails': (context) => const VehicleDetailsWidgetPage(),
  };

  // // Define routes for each tab
  // final Map<String, WidgetBuilder> routes = {
  //   '/vehicleDetails': (context) {
  //     // final product = ModalRoute.of(context)!.settings.arguments as Product;
  //     // return VehicleDetailsWidgetPage(product: product);
  //     return const VehicleDetailsWidgetPage();
  //   },
  // };

  static const List<String> widgetTitles = <String>[
    'Dashboard',
    'Our Services',
    'Help',
  ];

  // List to hold the widget options
  late List<Widget> widgetOptions;

  // Method to initialize widgetOptions
  void initializeWidgetOptions() {
    widgetOptions = <Widget>[
      buildNavigator(0, const DashboardScreen()),
      buildNavigator(1, const OurServices()),
      buildNavigator(2, const HelpScreen()),
    ];
  }

  // Helper function to build a Navigator for each tab
  Widget buildNavigator(int index, Widget child) {
    return Navigator(
      key: navigatorKeys[index],
      onGenerateRoute: (settings) {
        // Check if the route is defined in the routes map
        if (routes.containsKey(settings.name)) {
          return MaterialPageRoute(
            settings: settings,
            builder: routes[settings.name]!,
          );
        }
        // Default route
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => child,
        );
      },
    );
  }
}
