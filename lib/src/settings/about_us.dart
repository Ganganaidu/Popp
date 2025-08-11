import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:popp/src/utils/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  String _version = 'Loading...';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  /// Fetches the app version from the package info.
  Future<void> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = "${packageInfo.version} (${packageInfo.buildNumber})";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _version = 'N/A';
        });
      }
    }
  }

  /// Launches the default email client.
  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: Constants.contactEmail,
      queryParameters: {
        'subject': 'Bikerverse App Support Inquiry',
      },
    );

    await launchUrl(emailLaunchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Bikerverse'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildSection(
              title: 'Bikerverse',
              content:
                  "The all-in-one app built for motorcycle enthusiasts and bike businesses. Whether you're a rider looking to buy, sell, or explore, or a service provider wanting to reach the biking community, Bikerverse brings everything you need into one seamless experience.",
            ),
            const SizedBox(height: 32),
            _buildSection(
              title: 'For Riders',
              child: Column(
                children: [
                  _buildFeatureTile(
                    context: context,
                    icon: Icons.sell_outlined,
                    title: 'Sell Your Bike & Accessories',
                    subtitle:
                        'List your motorcycle, gear, or accessories to a wide audience of verified buyers.',
                  ),
                  _buildFeatureTile(
                    context: context,
                    icon: Icons.shield_moon_outlined,
                    title: 'Premium Bike Inspection',
                    subtitle:
                        'Get expert verification before purchasing any listed bike for complete peace of mind.',
                  ),
                  _buildFeatureTile(
                    context: context,
                    icon: Icons.event_seat_outlined,
                    title: 'Find Bike Rentals',
                    subtitle:
                        'Discover and compare a wide range of rental bikes for your next trip.',
                  ),
                  _buildFeatureTile(
                    context: context,
                    icon: Icons.engineering_outlined,
                    title: 'Connect with Trusted Mechanics',
                    subtitle:
                        'Find certified mechanics and service centers, check reviews, and book appointments.',
                  ),
                  _buildFeatureTile(
                    context: context,
                    icon: Icons.speed_outlined,
                    title: 'Track Days & Rider Training',
                    subtitle:
                        'Find and book upcoming track day events and rider training programs in your area.',
                  ),
                  _buildFeatureTile(
                    context: context,
                    icon: Icons.explore_outlined,
                    title: 'Explore Routes & Biking Events',
                    subtitle:
                        'Discover scenic routes, popular trails, and community events like group rides and rallies.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              title: 'For Businesses & Service Providers',
              content:
                  'Popp gives you a powerful platform to list your offerings and connect with a growing community of riders.',
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildFeatureTile(
                  context: context,
                  icon: Icons.storefront_outlined,
                  title: 'List Your Services',
                  subtitle:
                      'Promote rentals, events, training programs, repair services, and more.',
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              title: 'Get in Touch',
              content:
                  'Have questions, feedback, or suggestions? We\'d love to hear from you!',
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildFeatureTile(
                  context: context,
                  icon: Icons.email_outlined,
                  title: 'support@popp.app',
                  subtitle: 'Tap to send us an email',
                  onTap: _launchEmail,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              title: 'Safe, Secure & Simple',
              content:
                  'Your safety and privacy matter. All listings go through an approval process to maintain quality, and our support team is always here to help.',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Version $_version',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the header section with the app logo and name.
  Widget _buildHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/app_icon_trans.png', // Ensure you have a logo in your assets folder
            height: 80,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.two_wheeler_rounded,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Bikerverse',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your Ultimate Bike Companion',
            style: Theme.of(context).textTheme.titleMedium
          ),
        ],
      ),
    );
  }

  /// A reusable widget for creating section headers and content.
  Widget _buildSection({
    required String title,
    String? content,
    Widget? child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (content != null)
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
        if (child != null) const SizedBox(height: 8),
        if (child != null) child,
      ],
    );
  }

  /// A reusable widget for displaying a feature with an icon and text.
  Widget _buildFeatureTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.orange.shade300, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        onTap: onTap,
      ),
    );
  }
}
