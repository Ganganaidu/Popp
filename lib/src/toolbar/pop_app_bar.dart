import 'package:flutter/material.dart';
import 'package:popp/src/navigation/nav_router.dart';

import '../utils/app_constants.dart';

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
        titleSpacing: 0.0,
        title: const Text(Constants.appName,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron')),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.favorite_border_outlined),
            onPressed: () {
              onFavScreenTap(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              onSettingsTap(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
