import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:popp/src/navigation/nav_router.dart';
import 'package:popp/src/utils/build_extensions.dart';

class WebTopBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final List<GlobalKey<NavigatorState>> navigatorKeys;

  const WebTopBar({
    super.key,
    required this.selectedIndex,
    required this.navigatorKeys,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 65, // Increased height for better spacing
      color: isDarkMode ? context.primaryColorDark : Colors.grey[50], // User requested black theme
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SafeArea(
        child: Row(
          children: [
            // Branding / Logo
            _buildBrandLogo(context),
            const SizedBox(width: 40),

            // Search Bar (Center)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: _buildSearchBar(context),
              ),
            ),

            const SizedBox(width: 40),
            // Actions (Right)
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandLogo(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Biker",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
        Text(
          "verse",
          style: TextStyle(
            fontSize: 24,
            color: context.primaryColor, // Branding Green
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 40, // Slightly taller search bar
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Search Button
          InkWell(
            onTap: () => onSearchTap(context),
            child: Container(
              width: 50,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Icon(
                Icons.search,
                color: context.primaryColor,
              ),
            ),
          ),
          // Actual Search Input Area
          Expanded(
            child: InkWell(
              onTap: () => onSearchTap(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Search produce and services ...",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          return Row(
            children: [
              _buildActionButton(
                context,
                icon: Icons.favorite_border_outlined,
                label: "Favorites",
                onTap: () => onFavScreenTap(context),
              ),
              const SizedBox(width: 20),
              _buildActionButton(
                context,
                icon: Icons.settings_outlined,
                label: "Settings",
                onTap: () => onSettingsTap(context),
              ),
              const SizedBox(width: 20),
              if (user == null)
                _buildActionButton(
                  context,
                  icon: Icons.login_outlined,
                  label: "Login",
                  onTap: () => onLoginTap(context),
                )
              else
                _buildActionButton(
                  context,
                  icon: Icons.logout_outlined,
                  label: "Logout",
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),
            ],
          );
        });
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: context.primaryColor, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: context.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(250); // Increased height
}
