import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/widgets/web_constrained_box.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_url.dart';
import '../navigation/nav_router.dart';
import '../utils/app_constants.dart';
import '../utils/app_loger.dart';
import '../widgets/app_dialogs.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
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

    return Scaffold(
      body: WebConstrainedBox(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // _buildAnimatedAppBar(
                  //     context, isLoggedIn, user, backgroundImage),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildContent(context, user),
                    ),
                  ),
                ],
              ),
            ),
            // This ensures the button is always at the bottom
            // _buildBottomButton(context, isLoggedIn),
          ],
        ),
      ),
    );
  }

  // Widget _buildAnimatedAppBar(BuildContext context, bool isLoggedIn, User? user,
  //     ImageProvider<Object> backgroundImage) {
  //   return SliverAppBar(
  //     expandedHeight: 220.0,
  //     backgroundColor: Theme.of(context).primaryColor,
  //     flexibleSpace: FlexibleSpaceBar(
  //       centerTitle: true,
  //       title: const TitleText(
  //         "More",
  //         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  //       ),
  //       background: Stack(
  //         fit: StackFit.expand,
  //         children: [
  //           // Animated background
  //           Lottie.asset(
  //             'assets/popp_animated_background.json',
  //             width: 200,
  //             height: 200,
  //             fit: BoxFit.cover,
  //           ),
  //           // Gradient overlay for better text visibility
  //           Container(
  //             decoration: BoxDecoration(
  //               gradient: LinearGradient(
  //                 begin: Alignment.topCenter,
  //                 end: Alignment.bottomCenter,
  //                 colors: [
  //                   Colors.black.withOpacity(0.3),
  //                   Colors.transparent,
  //                   Colors.black.withOpacity(0.5),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           // User Info (Clickable)
  //           if (isLoggedIn)
  //             Center(
  //               child: GestureDetector(
  //                 onTap: () {
  //                   if (isLoggedIn) {
  //                     onProfileDetailsTap(context);
  //                   } else {
  //                     AppDialogs.showUserLoginDialog(context, () {
  //                       if (context.mounted) {
  //                         onLoginTap(context);
  //                       }
  //                     }, "login to view profile");
  //                   }
  //                 },
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     CircleAvatar(
  //                       radius: 45,
  //                       backgroundImage: backgroundImage,
  //                       backgroundColor: Colors.white.withOpacity(0.8),
  //                     ),
  //                     const SizedBox(height: 12),
  //                     FutureBuilder<String>(
  //                       future: _fetchUsername(user!.uid),
  //                       builder: (context, snapshot) {
  //                         return Text(
  //                           snapshot.data ?? 'Rider',
  //                           style: const TextStyle(
  //                             color: Colors.white,
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 18,
  //                             shadows: [
  //                               Shadow(
  //                                 blurRadius: 2.0,
  //                                 color: Colors.black,
  //                                 offset: Offset(1.0, 1.0),
  //                               ),
  //                             ],
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildContent(BuildContext context, User? user) {
    final bool isLoggedIn = user != null;
    String userId = user?.uid ?? '';
    bool isAdmin = userId == Constants.adminUserId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("SUPPORT & HELP"),
        if (isAdmin)
          _buildListTile(
            title: 'Chat user list',
            icon: Icons.chat_bubble_outline,
            onTap: () {
              onAgentChatTap(context);
            },
          )
        else
          _buildListTile(
            title: 'Chat with us',
            icon: Icons.chat_bubble_outline,
            onTap: () {
              if (FirebaseAuth.instance.currentUser == null) {
                AppDialogs.showUserLoginDialog(context, () {
                  if (context.mounted) {
                    onLoginTap(context);
                  }
                }, "Chat with us");
                return;
              } else {
                onAgentToUserChatTap(context, Constants.adminUserId,
                    FirebaseAuth.instance.currentUser?.uid ?? '');
              }
            },
          ),
        _buildListTile(
          title: 'Call us',
          icon: Icons.call_outlined,
          onTap: () {
            launchUrl(Uri(scheme: 'tel', path: Constants.contactNumber));
          },
        ),
        _buildListTile(
          title: 'Email us',
          icon: Icons.email_outlined,
          onTap: () {
            launchUrl(Uri(scheme: 'mailto', path: Constants.contactEmail));
          },
        ),
        _buildListTile(
          title: 'Frequently Asked Questions',
          icon: Icons.question_answer_outlined,
          onTap: () async {
            launchUrl(Uri.parse(ApiUrl.frequentlyAsked));
          },
        ),
        _buildListTile(
          title: 'Privacy Policy',
          icon: Icons.privacy_tip_outlined,
          onTap: () async {
            launchUrl(Uri.parse(ApiUrl.privacyLink));
          },
        ),
        _buildListTile(
          title: 'Terms & Conditions',
          icon: Icons.description_outlined,
          onTap: () async {
            launchUrl(Uri.parse(ApiUrl.customersTermsLink));
          },
        ),
        const SizedBox(height: 24),
        _buildSectionTitle("APP SETTINGS"),
        if (isLoggedIn && isAdmin)
          _buildListTile(
            title: "Admin Dashboard",
            icon: Icons.admin_panel_settings_outlined,
            isHighlight: true,
            onTap: () => onAdminDashboardTap(context),
          ),
        _buildListTile(
          title: "My Listings",
          icon: Icons.list_alt,
          enabled: isLoggedIn,
          onTap: () => onMyListingScreenTap(context, false),
        ),
        _buildListTile(
          title: "About Us",
          icon: Icons.info_outline,
          onTap: () => onAboutUsTap(context),
        ),
        const SizedBox(height: 20),
        _buildBottomButton(context, isLoggedIn),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 16.0),
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

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    bool enabled = true,
    bool isHighlight = false,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final color = isHighlight
        ? Theme.of(context).primaryColor
        : Theme.of(context).iconTheme.color;

    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              fontSize: 15),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ??
            (enabled
                ? const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey)
                : null),
        enabled: enabled,
        onTap: enabled ? onTap : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, bool isLoggedIn) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: isLoggedIn
                ? Colors.redAccent.withOpacity(0.1)
                : Theme.of(context).primaryColor,
            foregroundColor: isLoggedIn ? Colors.redAccent : Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: isLoggedIn ? const BorderSide(color: Colors.redAccent) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            )),
        onPressed: () async {
          if (isLoggedIn) {
            await FirebaseAuth.instance.signOut();
          }
          if (context.mounted) {
            onLoginTap(context);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isLoggedIn ? Icons.logout : Icons.login, size: 20),
            const SizedBox(width: 8),
            Text(isLoggedIn ? "LOGOUT ACCOUNT" : "LOGIN",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
