import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 5),
            ],
          ),
          padding: const EdgeInsets.only(bottom: 5),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: selectedIndex,
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.grey,
            onTap: onItemTapped,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                ),
                label: Constants.home,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  selectedIndex == 1
                      ? Icons.two_wheeler
                      : Icons.two_wheeler_outlined,
                ),
                label: Constants.rides,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  selectedIndex == 2 ? Icons.search_sharp : Icons.search_outlined,
                ),
                label: Constants.explore,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  selectedIndex == 3 ? Icons.map : Icons.map_outlined,
                ),
                label: Constants.routes,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  selectedIndex == 4
                      ? Icons.chat_bubble
                      : Icons.chat_bubble_outline,
                ),
                label: Constants.chat,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
