import 'package:flutter/cupertino.dart';

class TabNavigatorObserver extends NavigatorObserver {
  final VoidCallback onNavigationChanged;

  TabNavigatorObserver({required this.onNavigationChanged});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onNavigationChanged();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onNavigationChanged();
  }
}
