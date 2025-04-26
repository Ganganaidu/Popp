import 'package:flutter/material.dart';

import 'package:poppflutter/src/home/help_screen.dart';
import 'package:poppflutter/src/home/our_services.dart';
import 'package:poppflutter/src/toolbar/pop_app_bar.dart';
import 'package:poppflutter/src/utils/app_constants.dart';
import 'package:poppflutter/src/home/dashboard_screen.dart';
import 'package:poppflutter/src/utils/app_loger.dart';

import '../utils/nav_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _navHelper = NavHelper();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          AppLogger.d("onPopInvokedWithResult didPop: $didPop");
          AppLogger.d("onPopInvokedWithResult result: $result");
          if (didPop) {
            return;
          }
          _onWillPop();
        },
        child: Scaffold(
          appBar: PopAppBar(
            title: Constants.appName,
            selectedIndex: _selectedIndex,
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: _navHelper.widgetOptions,
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: Constants.home,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_tree),
                label: Constants.service,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.help_center),
                label: Constants.help,
              )
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue[800],
            onTap: _onItemTapped,
          ),
        ));
  }

  Future<bool> _onWillPop() async {
    // Check if the current Navigator can pop
    if (_navHelper.navigatorKeys[_selectedIndex].currentState?.canPop() ??
        false) {
      // Pop the current Navigator
      _navHelper.navigatorKeys[_selectedIndex].currentState?.pop();
      return false; // Don't pop the root Navigator
    } else {
      return false;
      // If the current Navigator can't pop, show a confirmation dialog
      // final shouldPop = await showDialog<bool>(
      //   context: context,
      //   builder: (context) {
      //     return AlertDialog(
      //       title: const Text('Do you want to exit the app?'),
      //       actions: [
      //         TextButton(
      //           onPressed: () => Navigator.of(context).pop(false),
      //           child: const Text('No'),
      //         ),
      //         TextButton(
      //           onPressed: () => Navigator.of(context).pop(true),
      //           child: const Text('Yes'),
      //         ),
      //       ],
      //     );
      //   },
      // );
      // return shouldPop ?? false; // Pop the root Navigator if confirmed
    }
  }
}
