import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../deeplink/DeepLinkConfig.dart';
import '../models/pop_service_item.dart';
import '../navigation/app_routes.dart';
import '../theme/bikerverse_colors.dart';
import '../utils/build_extensions.dart';

class PopServicesWidgets extends StatefulWidget {
  const PopServicesWidgets({super.key});

  @override
  State<PopServicesWidgets> createState() => _PopServicesWidgetsState();
}

class _PopServicesWidgetsState extends State<PopServicesWidgets> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollState);
  }

  void _updateScrollState() {
    setState(() {
      _canScrollLeft = _scrollController.offset > 0;
      _canScrollRight =
          _scrollController.offset < _scrollController.position.maxScrollExtent;
    });
  }

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

  void _scroll(double offset) {
    _scrollController.animateTo(
      (_scrollController.offset + offset).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollState);
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

  // ── WEB LAYOUT ──────────────────────────────────────────────────────────────

  Widget _buildWebLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Would you like to',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: BikerverseColors.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 210,
                child: ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 56),
                  itemCount: popServiceItemList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) =>
                      _buildWebServiceCard(context, popServiceItemList[index]),
                ),
              ),
              if (_canScrollLeft)
                Positioned(
                  left: 8,
                  child: _buildNavButton(
                    icon: Icons.chevron_left,
                    onTap: () => _scroll(-360),
                  ),
                ),
              if (_canScrollRight)
                Positioned(
                  right: 8,
                  child: _buildNavButton(
                    icon: Icons.chevron_right,
                    onTap: () => _scroll(360),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black38,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.black87, size: 22),
        ),
      ),
    );
  }

  Widget _buildWebServiceCard(BuildContext context, PopServiceItem item) {
    return _WebServiceCard(
      item: item,
      onTap: () => _handleAction(context, item.action),
    );
  }

  // ── MOBILE LAYOUT ────────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: popServiceItemList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) =>
            _buildServiceItem(context, popServiceItemList[index], isWeb: false),
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, PopServiceItem item,
      {required bool isWeb}) {
    final double containerSize = isWeb ? 120 : 90;
    final double iconSize = isWeb ? 50 : 50;

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
                    item.color?.withOpacity(0.4) ?? const Color(0xFF1E1E1E),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
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
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFFE0E0E0),
                letterSpacing: 0.8,
                height: 1.0,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              item.subTitle,
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

// ── Web card with hover effect ─────────────────────────────────────────────────

class _WebServiceCard extends StatefulWidget {
  final PopServiceItem item;
  final VoidCallback onTap;

  const _WebServiceCard({required this.item, required this.onTap});

  @override
  State<_WebServiceCard> createState() => _WebServiceCardState();
}

class _WebServiceCardState extends State<_WebServiceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _elevation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _elevation = Tween<double>(begin: 4.0, end: 14.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final baseColor = item.color ?? const Color(0xFF1E1E1E);

    return MouseRegion(
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) => Transform.scale(
            scale: _scale.value,
            child: child,
          ),
          child: Container(
            width: 150,
            height: 210,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(0.45),
                  blurRadius: _elevation.value,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Base color
                  ColoredBox(color: baseColor),

                  // Asset image
                  if (item.imageUrl != null)
                    Image.asset(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                    ),

                  // Bottom gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          baseColor.withOpacity(0.92),
                        ],
                        stops: const [0.38, 1.0],
                      ),
                    ),
                  ),

                  // Title + subtitle pinned to bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subTitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
