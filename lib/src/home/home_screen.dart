import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:poppflutter/src/toolbar/pop_app_bar.dart';
import 'package:poppflutter/src/utils/app_constants.dart';
import 'package:poppflutter/src/utils/app_loger.dart';
import '../navigation/custom_bottom_nav_bar.dart';
import '../utils/nav_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _navHelper = NavHelper();
  final ValueNotifier<bool> _canPop = ValueNotifier(false);
  final ValueNotifier<String> _appBarTitle = ValueNotifier(Constants.appName);

  @override
  void initState() {
    super.initState();
    _navHelper.navigationChangeListener = _onNavigationChanged;
    _navHelper.updateAppBarTitle = _updateAppBarTitle;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onNavigationChanged();
    });
  }

  /// Called whenever the inner Navigator stack changes
  void _onNavigationChanged() {
    final canPop =
        _navHelper.navigatorKeys[_selectedIndex].currentState?.canPop() ??
            false;
    _canPop.value = canPop;
    // Reset title when returning to root
    if (!canPop) {
      _appBarTitle.value = Constants.appName;
    }
  }

  void _updateAppBarTitle(String newTitle) {
    _appBarTitle.value = newTitle;
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Home tab clicked
      final navigator = _navHelper.navigatorKeys[_selectedIndex].currentState;
      if (navigator != null && navigator.canPop()) {
        navigator.popUntil((route) => route.isFirst); // pop to root first
      }
    }
    setState(() {
      _selectedIndex = index;
      _onNavigationChanged();
      _appBarTitle.value = Constants.appName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        AppLogger.d("onPopInvokedWithResult didPop: $didPop");
        AppLogger.d("onPopInvokedWithResult result: $result");
        if (didPop) return;
        _navHelper.onWillPop(_selectedIndex);
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ValueListenableBuilder2<bool, String>(
            first: _canPop,
            second: _appBarTitle,
            builder: (context, canPop, title, _) {
              return PopAppBar(
                title: title,
                selectedIndex: _selectedIndex,
                navigatorKeys: _navHelper.navigatorKeys,
                canPopOverride: canPop,
              );
            },
          ),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _navHelper.widgetOptions,
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget Function(BuildContext, A, B, Widget?) builder;

  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (context, firstValue, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, secondValue, __) {
            return builder(context, firstValue, secondValue, __);
          },
        );
      },
    );
  }
}
