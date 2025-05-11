import 'package:flutter/material.dart';
import 'package:poppflutter/src/home/search_screen.dart';
import 'package:poppflutter/src/login/login_screen.dart';

class PopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int selectedIndex;
  final List<Widget>? actions;
  final List<GlobalKey<NavigatorState>> navigatorKeys;
  final bool canPopOverride;

  const PopAppBar({
    super.key,
    required this.title,
    this.actions,
    required this.navigatorKeys,
    required this.selectedIndex,
    this.canPopOverride = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: Colors.white,
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: canPopOverride
              ? Hero(
            tag: 'backButtonHero',
            child: IconButton(
              key: const ValueKey('backButton'),
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                navigatorKeys[selectedIndex].currentState?.pop();
              },
            ),
          )
              : const SizedBox(key: ValueKey('emptySpace')),
        ),
        title: Text(title),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_box),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showSearch(context: context, delegate: SearchScreen());
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}