import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../deeplink/DeepLinkConfig.dart';
import '../models/pop_service_item.dart';
import '../navigation/app_routes.dart';

class PopServicesWidgets extends StatefulWidget {
  const PopServicesWidgets({super.key});

  @override
  State<PopServicesWidgets> createState() => _PopServicesWidgetsState();
}

class _PopServicesWidgetsState extends State<PopServicesWidgets> {
  void _handleAction(BuildContext context, String deepLinkKey) {
    final user = FirebaseAuth.instance.currentUser;
    final config = deepLinkConfigs[deepLinkKey];
    if (config == null) return;
    if (config.requiresAuth && user == null) {
      context.showLoginPrompt(config.loginMessage);
      return;
    }
    config.action?.call(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: popServiceItemList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (_, index) =>
            _buildServiceItem(cs, popServiceItemList[index]),
      ),
    );
  }

  Widget _buildServiceItem(ColorScheme cs, PopServiceItem item) {
    const double containerSize = 90;
    const double iconSize = 50;

    return GestureDetector(
      onTap: () => _handleAction(context, item.action),
      child: SizedBox(
        width: containerSize,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    item.color?.withOpacity(0.8) ?? const Color(0xFF1E1E1E),
                    item.color?.withOpacity(0.6) ?? const Color(0xFF1E1E1E),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: item.color != null
                    ? [
                        BoxShadow(
                          color: item.color!.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                          spreadRadius: -2,
                        ),
                      ]
                    : [],
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: item.imageUrl != null
                    ? Image.asset(
                        item.imageUrl!,
                        width: item.width,
                        height: item.height,
                        fit: BoxFit.cover,
                      )
                    : item.customIconPainter != null
                        ? CustomPaint(
                            size: Size(iconSize, iconSize),
                            painter: item.customIconPainter,
                          )
                        : item.icon != null
                            ? Icon(
                                item.icon,
                                size: iconSize,
                                color: Colors.white.withOpacity(0.95),
                              )
                            : const SizedBox(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                letterSpacing: 0.8,
                height: 1.0,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              item.subTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: cs.onSurface.withOpacity(0.5),
                height: 1.0,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
