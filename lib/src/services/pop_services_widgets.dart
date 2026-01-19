import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../deeplink/DeepLinkConfig.dart';
import '../models/pop_service_item.dart';
import '../navigation/nav_router.dart';
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

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 300,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 300,
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
      return _buildMobileLayout(context);
    }
  }

  Widget _buildWebLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(25),
          child: Text(
            'Would you like to',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200, // Fixed height for the container
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Arrow
              Container(
                height: 120,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(2, 0), // Shadow to right
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _scrollLeft,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                ),
              ),
              
              // Scrollable List
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 32),
                  itemBuilder: (context, index) {
                    final popServices = items[index];
                    return Align(
                      alignment: Alignment.topCenter,
                      child: _buildServiceCard(context, popServices, isWeb: true),
                    );
                  },
                ),
              ),

              // Right Arrow
              Container(
                height: 120,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(-2, 0), // Shadow to left
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _scrollRight,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final popServices = items[index];
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 16.0 : 0.0,
                  right: 16.0,
                ),
                child: _buildServiceCard(context, popServices, isWeb: false),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(BuildContext context, PopServiceItem popServices,
      {required bool isWeb}) {
    if (isWeb) {
      // Simplified Web Design
      return InkWell(
        onTap: () => _handleAction(context, popServices.action),
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.transparent, // Disable default hover color
        child: SizedBox( // Use SizedBox to constrain width
          width: 100,
          // Removed fixed height to prevent overflow
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100, // Slightly smaller icon container
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50, // Very subtle background
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  popServices.assetImageUrl,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                popServices.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600, // Semi-bold for clean look
                  color: context.primaryColorLight, // Use primary color for text to match theme
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Existing Mobile Design
    return InkWell(
      onTap: () => _handleAction(context, popServices.action),
      splashColor: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'service-image-${popServices.title}',
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white70,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  popServices.assetImageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
                height: 40,
                // Give the text container a fixed height
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Center(
                    // Center the text vertically
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 100),
                      child: Text(
                        popServices.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
