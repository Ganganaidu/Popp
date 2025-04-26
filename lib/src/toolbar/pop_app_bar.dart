import 'package:flutter/material.dart';
import 'package:poppflutter/src/home/search_screen.dart';
import 'package:poppflutter/src/login/login_screen.dart';

class PopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int selectedIndex;
  final List<Widget>? actions;

  const PopAppBar({
    super.key,
    required this.title,
    this.actions,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Add your search functionality here
            showSearch(context: context,
                delegate: SearchScreen());
          },
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () {
            // Add your search functionality here
          },
        ),
        IconButton(
          icon: const Icon(Icons.account_box),
          onPressed: () {
            // Add your search functionality here
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
