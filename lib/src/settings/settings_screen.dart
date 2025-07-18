import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lottie/lottie.dart'; // Added for animations
import 'package:popp/src/utils/build_extensions.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../api/api_url.dart';
import '../navigation/nav_router.dart';
import '../subscription/subscribe_page_widget.dart';
import '../subscription/subscription_provider.dart';
import '../subscription/subscription_status_screen.dart';
import '../utils/app_constants.dart';
import '../utils/app_loger.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<String> _fetchUsername(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(ApiUrl.userPath)
          .doc(uid)
          .get();
      final data = doc.data();
      if (data != null &&
          data['username'] != null &&
          data['username'].toString().isNotEmpty) {
        return data['username'];
      }
    } catch (e) {
      AppLogger.e("Error fetching username: $e");
    }
    return 'Rider'; // A more friendly default
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = user != null;
    final String? photoURL = user?.photoURL;

    ImageProvider<Object> backgroundImage;
    if (photoURL != null && photoURL.isNotEmpty) {
      backgroundImage = NetworkImage(photoURL);
    } else {
      backgroundImage = const AssetImage('assets/user_avatar.png');
    }

    return ChangeNotifierProvider(
      create: (_) => SubscriptionProvider(),
      child: Consumer<SubscriptionProvider>(
        builder: (context, subscriptionProvider, _) {
          return Scaffold(
            // Use a body with a bottom-aligned button
            body: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      _buildAnimatedAppBar(
                          context, isLoggedIn, user, backgroundImage),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildSettingsList(
                              context, user, subscriptionProvider),
                        ),
                      ),
                    ],
                  ),
                ),
                // This ensures the button is always at the bottom
                _buildBottomButton(context, isLoggedIn),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedAppBar(BuildContext context, bool isLoggedIn, User? user,
      ImageProvider<Object> backgroundImage) {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(1.0, 1.0),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Animated background (now using GIF instead of Lottie)
            Lottie.asset(
              'assets/popp_animated_background.json',
              // Add a Lottie file for empty state
              width: 200,
              height: 200,
            ),
            // Image.asset(
            //   'assets/popp_animated_background.gif',
            //   fit: BoxFit.cover,
            // ),
            // Gradient overlay for better text visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            // User Info
            if (isLoggedIn)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: backgroundImage,
                      backgroundColor: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<String>(
                      future: _fetchUsername(user!.uid),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'Rider',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            shadows: [
                              Shadow(
                                blurRadius: 2.0,
                                color: Colors.black,
                                offset: Offset(1.0, 1.0),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, User? user,
      SubscriptionProvider subscriptionProvider) {
    final bool isLoggedIn = user != null;
    final bool isSubscribed = subscriptionProvider.isSubscribed;
    final String? currentSubId = subscriptionProvider.currentSubscriptionId;
    final List<ProductDetails> products = subscriptionProvider.products;
    ProductDetails? subscribedProduct;
    if (isSubscribed && currentSubId != null) {
      try {
        subscribedProduct = products.firstWhere((p) => p.id == currentSubId);
      } catch (_) {}
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSettingsSectionTitle("Account"),
        _buildListTile(
          context,
          icon: Icons.person_outline,
          title: "Profile Identifier",
          subtitle: user?.email ?? user?.phoneNumber,
          enabled: isLoggedIn,
          disableArrow: false,
          onTap: () => {},
        ),
        _buildListTile(
          context,
          icon: Icons.lock_outline,
          title: "Change Password",
          enabled: isLoggedIn,
          onTap: () => onForgotPasswordTap(context, true),
        ),
        if (isLoggedIn && user.uid == Constants.adminUserId)
          _buildListTile(
            context,
            icon: Icons.admin_panel_settings_outlined,
            title: "Admin Dashboard",
            isHighlight: true,
            onTap: () => onAdminDashboardTap(context),
          ),
        const SizedBox(height: 24),
        _buildSettingsSectionTitle("Activity"),
        _buildListTile(
          context,
          icon: Icons.motorcycle_outlined,
          title: "My Listings",
          enabled: isLoggedIn,
          onTap: () => onMyListingScreenTap(context, false),
        ),
        _buildListTile(
          context,
          icon: Icons.star_border,
          title: "Subscriptions",
          enabled: isLoggedIn,
          trailing: isSubscribed
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              : null,
          onTap: () {
            if (isSubscribed && subscribedProduct != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SubscriptionStatusScreen(
                    subscribedProduct: subscribedProduct!,
                    userUid: user!.uid,
                  ),
                ),
              );
            } else {
              _showSubscribeBottomSheet(context, user!.uid);
            }
          },
        ),
        const SizedBox(height: 24),
        _buildSettingsSectionTitle("App Settings"),
        _buildDarkModeSwitch(),
        _buildListTile(
          context,
          icon: Icons.info_outline,
          title: "About Us",
          onTap: () => onAboutUsTap(context),
        ),
        const SizedBox(height: 20), // Space for the bottom button
      ],
    );
  }

  Widget _buildSettingsSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    bool enabled = true,
    bool disableArrow = true,
    bool isHighlight = false,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final color =
        isHighlight ? context.primaryColor : Theme.of(context).iconTheme.color;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ??
            (disableArrow && enabled
                ? const Icon(Icons.arrow_forward_ios, size: 16)
                : null),
        enabled: enabled,
        onTap: enabled ? onTap : null,
      ),
    );
  }

  Widget _buildDarkModeSwitch() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, themeMode, _) {
          return SwitchListTile(
            title: const Text("Dark Mode"),
            secondary: const Icon(Icons.brightness_6_outlined),
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeNotifier.toggle(value);
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, bool isLoggedIn) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: isLoggedIn ? Colors.redAccent : Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            )),
        onPressed: () async {
          if (isLoggedIn) {
            await FirebaseAuth.instance.signOut();
          }
          if (context.mounted) {
            onLoginTap(context);
          }
        },
        child: Text(isLoggedIn ? "Logout" : "Login",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  void _showSubscribeBottomSheet(BuildContext context, String userUid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: SubscribePageWidget(
          userUid: userUid,
          isFromSettings: true,
        ),
      ),
    );
  }
}
