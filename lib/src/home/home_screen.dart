import 'package:flutter/material.dart';

import 'package:poppflutter/src/home/help_screen.dart';
import 'package:poppflutter/src/home/our_services.dart';
import 'package:poppflutter/src/toolbar/pop_app_bar.dart';
import 'package:poppflutter/src/utils/app_constants.dart';
import 'package:poppflutter/src/home/foryou_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    ForYouScreen(),
    OurServices(),
    HelpScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PopAppBar(
        title: Constants.appName,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
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
    );
  }
}
