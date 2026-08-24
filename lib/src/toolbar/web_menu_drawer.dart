import 'package:flutter/material.dart';
import 'package:popp/src/chat/chat_service.dart';
import 'package:popp/src/utils/app_constants.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:provider/provider.dart';

class WebMenuDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const WebMenuDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = cs.onSurface;

    return Drawer(
      backgroundColor: cs.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: context.primaryColor,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Biker",
                    style: TextStyle(
                      fontSize: 24,
                      color: cs.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                  Text(
                    "verse",
                    style: TextStyle(
                      fontSize: 24,
                      color: context.primaryColorDark, 
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  index: 0,
                  icon: selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                  label: Constants.home,
                  color: textColor,
                ),
                _buildDrawerItem(
                  context,
                  index: 1,
                  icon: selectedIndex == 1 ? Icons.search_sharp : Icons.search_outlined,
                  label: Constants.explore,
                  color: textColor,
                ),
                // Custom item for Chat to include Badge
                ListTile(
                  leading: StreamBuilder<int>(
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
                          color: selectedIndex == 2 ? context.primaryColor : textColor,
                        ),
                      );
                    },
                  ),
                  title: Text(
                    Constants.chat,
                    style: TextStyle(
                      color: selectedIndex == 2 ? context.primaryColor : textColor,
                      fontWeight: selectedIndex == 2 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    onItemTapped(2);
                    Navigator.pop(context); // Close drawer
                  },
                ),
                _buildDrawerItem(
                  context,
                  index: 3,
                  icon: selectedIndex == 3 ? Icons.help_center_rounded : Icons.help_center_outlined,
                  label: Constants.help,
                  color: textColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = selectedIndex == index;
    final itemColor = isSelected ? context.primaryColor : color;

    return ListTile(
      leading: Icon(
        icon,
        color: itemColor,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: itemColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        onItemTapped(index);
        Navigator.pop(context); // Close drawer
      },
    );
  }
}
