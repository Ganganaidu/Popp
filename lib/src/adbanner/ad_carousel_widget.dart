import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/adbanner/model/ad_banner.dart';
import 'package:popp/src/adbanner/repository/ad_carousel_viewmodel.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../deeplink/DeepLinkConfig.dart';
import '../navigation/nav_router.dart';

class AdCarouselWidget extends StatefulWidget {
  const AdCarouselWidget({super.key});

  @override
  State<AdCarouselWidget> createState() => _AdCarouselWidgetState();
}

class _AdCarouselWidgetState extends State<AdCarouselWidget> {
  int _current = 0;

  deepLinkToTarget(String deepLink) async {
    try {
      final uri = Uri.parse(deepLink);
      // Check if it's a valid URL with scheme
      if (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (e) {
      // Not a valid URI, continue with deep link handling
    }

    final user = FirebaseAuth.instance.currentUser;

    // Find the matching configuration
    final config = deepLinkConfigs.entries
        .firstWhere(
          (entry) => deepLink.contains(entry.key),
          orElse: () => MapEntry('', DeepLinkConfig()),
        )
        .value;

    // Handle authentication and action
    if (config.requiresAuth && user == null) {
      onLoginClicked(context, config.loginMessage);
      return;
    }

    // Execute the action if available
    config.action?.call(context);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AdCarouselViewModel>(context, listen: false).loadAds());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdCarouselViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return SizedBox(
            height: 350,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                color: Colors.white,
              ),
            ),
          );
        }

        // If there's an error or no ads, show the engaging business-focused fallback UI.
        if (viewModel.error != null || viewModel.ads.isEmpty) {
          return _buildFallbackUI();
        }

        if (viewModel.ads.length == 1) {
          return SizedBox(
            height: 350,
            child: buildAdSlide(viewModel.ads.first),
          );
        }

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CarouselSlider(
              items: viewModel.ads.map(buildAdSlide).toList(),
              options: CarouselOptions(
                height: 350,
                viewportFraction: 1.0,
                autoPlay: true,
                onPageChanged: (index, reason) =>
                    setState(() => _current = index),
              ),
            ),
            Positioned(
              bottom: 20.0,
              child: Row(
                children: List.generate(viewModel.ads.length, (index) {
                  final isActive = index == _current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 16 : 12,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.orange : Colors.white70,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds the fallback UI to show when ads are unavailable, targeting potential advertisers.
  Widget _buildFallbackUI() {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Colors.blueGrey.shade900,
            Colors.grey.shade900,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange.shade300, width: 1.5),
              ),
              child: Icon(Icons.campaign_outlined,
                  color: Colors.orange.shade300, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Promote Your Business Here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This space is available for promotions. Reach thousands of dedicated motorcycle enthusiasts in the Bikerverse community.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 15,
                  height: 1.5),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.email_outlined, size: 18),
              label: const Text('Contact Us for more info'),
              onPressed: () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'preownedpremiumproducts@gmail.com',
                  queryParameters: {
                    'subject': 'Inquiry: Advertising on Bikerverse App',
                  },
                );
                await launchUrl(emailLaunchUri);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.orange.shade300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAdSlide(AdBanner ad) {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse(ad.buttonLink);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          AppLogger.e('Could not launch ${ad.buttonLink}');
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            ad.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(color: Colors.white),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              // If a single image fails to load, show a placeholder
              return Container(
                color: Colors.grey.shade700,
                child: const Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      color: Colors.white38, size: 50),
                ),
              );
            },
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.fromARGB(120, 0, 0, 0), Colors.black54],
                stops: [0.0, 0.8],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(ad.title,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                Text(ad.highlight,
                    style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(ad.subtitle,
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: ad.points
                      .map((point) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Colors.orange, size: 18),
                              const SizedBox(width: 4),
                              Text(point,
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                if (ad.buttonText.isNotEmpty && ad.buttonLink.isNotEmpty)
                  ElevatedButton(
                    onPressed: () async {
                      deepLinkToTarget(ad.buttonLink);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(ad.buttonText),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
