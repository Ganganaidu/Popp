import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../deeplink/DeepLinkConfig.dart';
import '../models/pop_service_item.dart';
import '../navigation/nav_router.dart';
import '../theme/bikerverse_colors.dart';
import '../utils/build_extensions.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../deeplink/DeepLinkConfig.dart';
import '../models/pop_service_item.dart';
import '../navigation/nav_router.dart';
import '../theme/bikerverse_colors.dart';
import '../utils/build_extensions.dart';

class PopServicesWidgets extends StatefulWidget {
  const PopServicesWidgets({super.key});

  @override
  State<PopServicesWidgets> createState() => _PopServicesWidgetsState();
}

class _PopServicesWidgetsState extends State<PopServicesWidgets> {
  final ScrollController _scrollController = ScrollController();

  void _handleAction(BuildContext context, String deepLinkKey) {
    final user = FirebaseAuth.instance.currentUser;

    final config = deepLinkConfigs[deepLinkKey];
    if (config == null) return;

    if (config.requiresAuth && user == null) {
      onLoginClicked(context, config.loginMessage);
      return;
    }
    config.action?.call(context);
  }

  void _scroll(double offset) {
    _scrollController.animateTo(
      _scrollController.offset + offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb && context.isDesktop;

    if (isWeb) {
      return _buildWebLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildWebLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Text(
            'Would you like to',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: BikerverseColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: Row(
            children: [
              _buildScrollButton(Icons.arrow_back_ios_new, () => _scroll(-300)),
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 20),
                  itemBuilder: (context, index) =>
                      _buildServiceItem(context, items[index], isWeb: true),
                ),
              ),
              _buildScrollButton(Icons.arrow_forward_ios, () => _scroll(300)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScrollButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 40,
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: BikerverseColors.accent),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SizedBox(
      height: 140, // Reduced height as items are compact
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20), // More padding
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20), // Details from screenshot
        itemBuilder: (context, index) =>
            _buildServiceItem(context, items[index], isWeb: false),
      ),
    );
  }


  Widget _buildServiceItem(BuildContext context, PopServiceItem item,
      {required bool isWeb}) {
    final double containerSize = isWeb ? 120 : 90; // Smaller, punchy icons (matches screenshot)
    final double iconSize = isWeb ? 50 : 32;

    return GestureDetector(
      onTap: () => _handleAction(context, item.action),
      child: SizedBox(
        width: containerSize, // Constraint width
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                // Gradient Background
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    item.color?.withOpacity(0.8) ?? const Color(0xFF1E1E1E),
                    item.color?.withOpacity(0.4) ?? const Color(0xFF1E1E1E),
                  ],
                ),
                borderRadius: BorderRadius.circular(24), // Soft rounded corners (Squircle-ish)
                // Colored Shadow / Glow
                boxShadow: item.color != null
                    ? [
                        BoxShadow(
                          color: item.color!.withOpacity(0.4),
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
                child: item.customIconPainter != null
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
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800, // Bold top text
                color: Color(0xFFE0E0E0),
                letterSpacing: 0.8,
                height: 1.0,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              item.subTitle, // Using this as subtitle based on existing code mapping
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.grey,
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
