import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/navigation/nav_router.dart';
import 'package:popp/src/notifications/notification_service.dart';
import 'package:popp/src/theme/bikerverse_colors.dart';
import 'AppBarIconButton.dart';

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
    final currentUser = FirebaseAuth.instance.currentUser;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: BikerverseColors.background,
      child: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0.0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              AnimatedSwitcher(
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
                          icon: const Icon(Icons.arrow_back,
                              color: BikerverseColors.textPrimary),
                          onPressed: () {
                            navigatorKeys[selectedIndex].currentState?.pop();
                          },
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('emptySpace')),
              ),
              const Row(children: [
                Text("Biker",
                    style: TextStyle(
                        fontSize: 25,
                        color: BikerverseColors.accent,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Orbitron')),
                Text("verse",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: BikerverseColors.textPrimary,
                        fontFamily: 'Orbitron'))
              ]),
            ],
          ),
        ),
        centerTitle: false,
        actions: <Widget>[
          AppBarIconButton(
            icon: Icons.search,
            onTap: () => onSearchTap(context),
          ),
          AppBarIconButton(
            icon: Icons.favorite_border_outlined,
            onTap: () => onFavScreenTap(context),
          ),
          // Notification bell with unread badge
          _NotificationBell(uid: currentUser?.uid),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _NotificationBell extends StatelessWidget {
  final String? uid;

  const _NotificationBell({this.uid});

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return AppBarIconButton(
        icon: Icons.notifications_outlined,
        onTap: () => onNotificationsTap(context),
      );
    }
    return StreamBuilder<int>(
      stream: NotificationService.unreadCountStream(uid!),
      builder: (context, snapshot) {
        final int count = snapshot.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            AppBarIconButton(
              icon: Icons.notifications_outlined,
              onTap: () => onNotificationsTap(context),
            ),
            if (count > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}