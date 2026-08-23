import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/navigation/app_routes.dart';
import 'package:popp/src/notifications/notification_service.dart';
import 'package:popp/src/theme/bikerverse_colors.dart';
import 'AppBarIconButton.dart';

class PopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PopAppBar({super.key});

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
        title: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              Row(children: [
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
            iconSemanticLabel: "Search",
            icon: Icons.search,
            onTap: () => context.pushSearch(),
          ),
          AppBarIconButton(
            iconSemanticLabel: "Favorites",
            icon: Icons.favorite_border_outlined,
            onTap: () => context.pushFavorites(),
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
        onTap: () => context.pushNotifications(),
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
              iconSemanticLabel: "Notifications",
              icon: Icons.notifications_outlined,
              onTap: () => context.pushNotifications(),
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