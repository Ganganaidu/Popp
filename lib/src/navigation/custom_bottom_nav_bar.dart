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
              const BottomNavigationBarItem(
                icon: SizedBox.shrink(), // Center gap (empty)
                label: '',
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
        Positioned(
          bottom: 20,
          child: GestureDetector(
            onTap: () {
              onItemTapped(2); // Center button = index 2
            },
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: selectedIndex == 2 ? Colors.blueAccent : Colors.orange,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.search_sharp,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
