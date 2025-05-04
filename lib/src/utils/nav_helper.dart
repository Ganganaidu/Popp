import 'package:flutter/material.dart';

import '../home/dashboard_screen.dart';
import '../home/help_screen.dart';
import '../home/our_services.dart';
import '../products/explore_products_screen.dart';
import '../toolbar/tab_navigator_observer.dart';
import 'nav_router.dart';

class NavHelper {
  // Singleton instance
  static final NavHelper _instance = NavHelper._internal();

  // Factory constructor to return the singleton instance
  factory NavHelper() {
    return _instance;
  }

  // Listener to update AppBar title
  void Function(String)? updateAppBarTitle;

  // Listener to notify HomeScreen on navigation changes
  void Function()? navigationChangeListener;

  // Private constructor
  NavHelper._internal() {
    initializeWidgetOptions();
  }

  // Define a list of GlobalKeys for each Navigator
  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

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
      buildNavigator(2, const ExploreProductsScreen()),
      buildNavigator(3, const HelpScreen()),
      buildNavigator(4, const OurServices()),
    ];
  }

  // Helper function to build a Navigator for each tab
  Widget buildNavigator(int index, Widget child) {
    return Navigator(
      key: navigatorKeys[index],
      observers: [
        TabNavigatorObserver(onNavigationChanged: () {
          // Notify HomeScreen
          navigationChangeListener?.call();
        }),
      ],
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

  Future<bool> onWillPop(int selectedIndex) async {
    // Check if the current Navigator can pop
    if (navigatorKeys[selectedIndex].currentState?.canPop() ?? false) {
      // Pop the current Navigator
      navigatorKeys[selectedIndex].currentState?.pop();
      return false; // Don't pop the root Navigator
    } else {
      return false;
    }
  }
}
