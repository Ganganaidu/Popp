import 'package:flutter/material.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:provider/provider.dart';
import '../chat/chat_service.dart';
import '../utils/app_constants.dart';
import '../theme/bikerverse_colors.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? BikerverseColors.background : Colors.grey[50],
            border: Border(
              top: BorderSide(
                color:
                    isDarkMode ? BikerverseColors.outline : Colors.grey.shade300,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.only(bottom: 6, top: 4),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: selectedIndex,
            selectedItemColor: context.primaryColor,
            unselectedItemColor:
                isDarkMode ? BikerverseColors.textMuted : Colors.grey,
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
                      ? Icons.search_sharp
                      : Icons.search_outlined,
                ),
                label: Constants.explore,
              ),
              BottomNavigationBarItem(
                icon: StreamBuilder<int>(
                  stream: context.read<ChatService>().totalUnreadCountStream,
                  builder: (context, snapshot) {
                    final int count = snapshot.data ?? 0;
                    return Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      child: Icon(
                        selectedIndex == 2
                            ? Icons.chat_bubble_outlined
                            : Icons.chat_bubble_outline,
                      ),
                    );
                  },
                ),
                label: Constants.chat,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  selectedIndex == 3
                      ? Icons.settings
                      : Icons.settings_outlined,
                ),
                label: Constants.settings,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
