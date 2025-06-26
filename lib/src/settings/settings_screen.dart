import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../main.dart';
import '../navigation/nav_router.dart';
import '../subscription/subscribe_page_widget.dart';
import '../subscription/subscription_provider.dart';
import '../subscription/subscription_status_screen.dart';
import '../utils/app_constants.dart';
import '../utils/app_loger.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<String> _fetchUsername(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection(Constants.userPath)
        .doc(uid)
        .get();
    final data = doc.data();
    if (data != null &&
        data['username'] != null &&
        data['username'].toString().isNotEmpty) {
      return data['username'];
    }
    return 'No Name';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    AppLogger.d("Current user: $user");
    final bool isLoggedIn = user != null;
    final String userEmailOrPhone = user?.email ?? user?.phoneNumber ?? '';
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
          final bool isSubscribed = subscriptionProvider.isSubscribed;
          final String? currentSubId =
              subscriptionProvider.currentSubscriptionId;
          final List<ProductDetails> products = subscriptionProvider.products;
          ProductDetails? subscribedProduct;
          if (isSubscribed && currentSubId != null) {
            try {
              subscribedProduct =
                  products.firstWhere((p) => p.id == currentSubId);
            } catch (_) {}
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text("Profile Settings"),
              centerTitle: true,
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: backgroundImage,
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: isLoggedIn
                                ? FutureBuilder<String>(
                                    future: _fetchUsername(user.uid),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Text('Loading...');
                                      }
                                      return Text(snapshot.data ?? 'No Name');
                                    },
                                  )
                                : const Text('No Name'),
                            subtitle: userEmailOrPhone.isNotEmpty
                                ? Text(userEmailOrPhone)
                                : null,
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            enabled: isLoggedIn,
                            onTap: isLoggedIn
                                ? () {
                                    // Navigate to profile details
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildDisabledCard(
                          context,
                          icon: Icons.motorcycle,
                          title: "My Listings",
                          enabled: isLoggedIn,
                        ),
                        _buildDisabledCard(
                          context,
                          icon: Icons.favorite,
                          title: "Favorites",
                          enabled: isLoggedIn,
                        ),
                        // Subscriptions card with status and navigation
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(Icons.chat),
                            title: const Text("Subscriptions"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSubscribed)
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'SUBSCRIBED',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                const Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                            enabled: isLoggedIn,
                            onTap: isLoggedIn
                                ? () {
                                    if (isSubscribed &&
                                        subscribedProduct != null) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              SubscriptionStatusScreen(
                                            subscribedProduct:
                                                subscribedProduct!,
                                            userUid: user.uid,
                                          ),
                                        ),
                                      );
                                    } else {
                                      _showSubscribeBottomSheet(
                                          context, user.uid);
                                    }
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Other Settings",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ValueListenableBuilder<ThemeMode>(
                          valueListenable: themeNotifier,
                          builder: (context, themeMode, _) {
                            return SwitchListTile(
                              title: const Text("Dark Mode"),
                              value: themeMode == ThemeMode.dark,
                              onChanged: (value) {
                                themeNotifier.toggle(value);
                              },
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.lock),
                          title: const Text("Change Password"),
                          enabled: isLoggedIn,
                          onTap: isLoggedIn
                              ? () {
                                  onForgotPasswordTap(context);
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isLoggedIn ? Colors.redAccent : Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          )),
                      onPressed: () async {
                        if (isLoggedIn) {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        } else {
                          Navigator.pushNamed(context, '/login');
                        }
                      },
                      child: Text(isLoggedIn ? "Logout" : "Login"),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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

  Widget _buildDisabledCard(BuildContext context,
      {required IconData icon,
      required String title,
      required bool enabled,
      VoidCallback? onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        enabled: enabled,
        onTap: onTap ?? (enabled ? () {} : null),
      ),
    );
  }
}
