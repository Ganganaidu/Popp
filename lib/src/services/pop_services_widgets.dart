import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../deeplink/DeepLinkConfig.dart';
import '../models/pop_service_item.dart';
import '../navigation/nav_router.dart';
import '../utils/build_extensions.dart';

class PopServicesWidgets extends StatelessWidget {
  const PopServicesWidgets({super.key});

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
          padding: EdgeInsets.only(bottom: 24.0),
          child: Text(
            'Would you like to',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive grid based on available width
            int crossAxisCount;
            if (constraints.maxWidth > 1000) {
              crossAxisCount = 4;
            } else if (constraints.maxWidth > 700) {
              crossAxisCount = 3;
            } else {
              crossAxisCount = 2;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.0,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final popServices = items[index];
                return _buildServiceCard(context, popServices, isWeb: true);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 20.0, left: 16.0, bottom: 8.0),
          child: Text(
            'Would you like to',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
    return InkWell(
      onTap: () => _handleAction(context, popServices.action),
      splashColor: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          border: isWeb ? Border.all(color: Colors.grey.shade200) : null,
          boxShadow: isWeb
              ? [
                  const BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'service-image-${popServices.title}',
              child: Container(
                width: isWeb ? 80 : 100,
                height: isWeb ? 80 : 100,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  shape: BoxShape.circle,
                  boxShadow: isWeb
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                padding: EdgeInsets.all(isWeb ? 16 : 12),
                child: Image.asset(
                  popServices.assetImageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: isWeb ? 16 : 8),
            SizedBox(
                height: isWeb ? 40 : 36,
                // Give the text container a fixed height
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 0),
                  child: Center(
                    // Center the text vertically
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isWeb ? 150 : 100),
                      child: Text(
                        popServices.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isWeb ? 16 : 14,
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
