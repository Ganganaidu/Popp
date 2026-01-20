import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/adbanner/model/ad_banner.dart';
import 'package:popp/src/adbanner/repository/ad_carousel_viewmodel.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:popp/src/utils/app_constants.dart';

import '../deeplink/DeepLinkConfig.dart';
import '../navigation/nav_router.dart';

class AdCarouselWidget extends StatefulWidget {
  const AdCarouselWidget({super.key});

  @override
  State<AdCarouselWidget> createState() => _AdCarouselWidgetState();
}

class _AdCarouselWidgetState extends State<AdCarouselWidget> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

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
        Provider.of<AdCarouselViewModel>(context, listen: false).loadAds(true));
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb && context.isDesktop;

    return Consumer<AdCarouselViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return SizedBox(
            height: isWeb ? 500 : 350,
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
          return _buildFallbackUI(isWeb: isWeb);
        }

        if (viewModel.ads.length == 1) {
          return SizedBox(
            height: isWeb ? 500 : 350,
            child: buildAdSlide(viewModel.ads.first, isWeb: isWeb),
          );
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            CarouselSlider(
              carouselController: _controller,
              items: viewModel.ads
                  .map((ad) => buildAdSlide(ad, isWeb: isWeb))
                  .toList(),
              options: CarouselOptions(
                height: isWeb ? 500 : 350,
                viewportFraction: 1.0,
                autoPlay: true,
                onPageChanged: (index, reason) =>
                    setState(() => _current = index),
              ),
            ),
            // Pagination Dots
            Positioned(
              bottom: isWeb ? 24.0 : 20.0,
              child: Row(
                children: List.generate(viewModel.ads.length, (index) {
                  final isActive = index == _current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? (isWeb ? 20 : 16) : (isWeb ? 16 : 12),
                    height: isWeb ? 6 : 4,
                    decoration: BoxDecoration(
                      color: isActive ? context.primaryColor : Colors.white70,
                      borderRadius: BorderRadius.circular(isWeb ? 3 : 2),
                    ),
                  );
                }),
              ),
            ),
            // Left Arrow (Web Only)
            if (isWeb)
              Positioned(
                left: 20,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _controller.previousPage(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            // Right Arrow (Web Only)
            if (isWeb)
              Positioned(
                right: 20,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _controller.nextPage(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Builds the fallback UI to show when ads are unavailable, targeting potential advertisers.
  Widget _buildFallbackUI({required bool isWeb}) {
    return Container(
      height: isWeb ? 500 : 350,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Colors.blueGrey.shade900,
            Colors.grey.shade900,
          ],
          stops: const [0.0, 1.0],
        ),
        borderRadius: isWeb ? BorderRadius.circular(16) : null,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? 48 : 24,
          vertical: isWeb ? 32 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isWeb ? 16 : 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange.shade300, width: 1.5),
              ),
              child: Icon(
                Icons.campaign_outlined,
                color: Colors.orange.shade300,
                size: isWeb ? 48 : 40,
              ),
            ),
            SizedBox(height: isWeb ? 24 : 20),
            Text(
              'Promote Your Business Here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: isWeb ? 32 : 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: isWeb ? 16 : 12),
            Text(
              'This space is available for promotions. Reach thousands of dedicated motorcycle enthusiasts in the Bikerverse community.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: isWeb ? 18 : 15,
                height: 1.5,
              ),
            ),
            SizedBox(height: isWeb ? 32 : 24),
            OutlinedButton.icon(
              icon: Icon(Icons.email_outlined, size: isWeb ? 20 : 18),
              label: Text(
                'Contact Us for more info',
                style: TextStyle(fontSize: isWeb ? 16 : 14),
              ),
              onPressed: () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: Constants.contactEmail,
                  queryParameters: {
                    'subject': 'Inquiry: Advertising on Bikerverse App',
                  },
                );
                await launchUrl(emailLaunchUri);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.orange.shade300),
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 24 : 20,
                  vertical: isWeb ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isWeb ? 8 : 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAdSlide(AdBanner ad, {required bool isWeb}) {
    if (isWeb) {
      return _buildWebAdSlide(ad);
    }
    return _buildMobileAdSlide(ad);
  }

  Widget _buildWebAdSlide(AdBanner ad) {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse(ad.buttonLink);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          AppLogger.e('Could not launch ${ad.buttonLink}');
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // LAYER 1: Full Background Image
              Positioned.fill(
                child: ad.imageUrl.isEmpty
                    ? Image.asset(
                        'assets/ads_default_image.png',
                        fit: BoxFit.cover,
                      )
                    : Image.network(
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
                          return Image.asset(
                            'assets/ads_default_image.png',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
              ),

              // LAYER 2: Gradient Overlay (Darker at bottom/left for text readability)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.3),
                      ],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                ),
              ),

              // LAYER 3: Content
              Positioned(
                left: 60, // Indent content slightly
                top: 0,
                bottom: 0,
                width: 600, // Fixed max width for content
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (ad.highlight.isNotEmpty) ...[
                      Text(
                        ad.highlight,
                        style: TextStyle(
                          color: context.primaryColor, // Theme Green
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      ad.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48, // Larger title
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Orbitron',
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      ad.subtitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                    if (ad.points.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 20,
                        runSpacing: 10,
                        children: ad.points.map((point) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: context.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                point,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 32),
                    if (ad.buttonText.isNotEmpty &&
                        ad.buttonLink.isNotEmpty)
                      ElevatedButton(
                        onPressed: () async {
                          deepLinkToTarget(ad.buttonLink);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor, // Theme Green
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Less rounded for modern look
                          ),
                          elevation: 4,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(ad.buttonText),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileAdSlide(AdBanner ad) {
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
          if (ad.imageUrl.isEmpty)
            // If no image URL is provided, show a placeholder
            Image.asset(
              'assets/ads_default_image.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          else
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
                return Image.asset(
                  'assets/ads_default_image.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              },
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(200, 0, 0, 0),
                  // Increased opacity for better contrast
                  Colors.black87,
                ],
                stops: [0.0, 0.8],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  ad.title,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.7),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ]),
                ),
                const SizedBox(height: 8),
                Text(
                  ad.highlight,
                  style: TextStyle(
                      color: context.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Orbitron',
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.7),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ]),
                ),
                const SizedBox(height: 12),
                Text(
                  ad.subtitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.7),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: ad.points
                      .map((point) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: context.primaryColor,
                                size: 18,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.7),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                point,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.7),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                if (ad.buttonText.isNotEmpty && ad.buttonLink.isNotEmpty)
                  ElevatedButton(
                    onPressed: () async {
                      deepLinkToTarget(ad.buttonLink);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      ad.buttonText,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
