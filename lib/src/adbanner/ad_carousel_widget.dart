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
          alignment: Alignment.bottomCenter,
          children: [
            CarouselSlider(
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
                      color: isActive ? Colors.orange : Colors.white70,
                      borderRadius: BorderRadius.circular(isWeb ? 3 : 2),
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
              // LAYER 1: Background Image (Right Aligned)
              Positioned.fill(
                child: ad.imageUrl.isEmpty
                    ? Image.asset(
                        'assets/ads_default_image.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                      )
                    : Image.network(
                        ad.imageUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
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
                            alignment: Alignment.centerRight,
                          );
                        },
                      ),
              ),

              // LAYER 2: Gradient Overlay (Left -> Right Fade)
              // This ensures text is readable regardless of the image content behind it
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        context.primaryColorLight,
                        context.primaryColorLight.withOpacity(0.70),
                        context.primaryColorLight.withOpacity(0.0),
                        context.primaryColorLight.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.4, 0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // LAYER 3: Content (Left Side)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 600, // Fixed max width or percentage for content
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ad.title,
                          style: const TextStyle(
                            color: Colors.white, // User's choice
                            fontSize: 25, // User's choice
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Orbitron',
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          ad.highlight,
                          style: TextStyle(
                            color: context.primaryColorDark, // User's choice
                            fontSize: 20, // User's choice
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Orbitron',
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          ad.subtitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 18,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 15),
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
                                  size: 18, // User's choice
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  point,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        if (ad.buttonText.isNotEmpty &&
                            ad.buttonLink.isNotEmpty)
                          ElevatedButton(
                            onPressed: () async {
                              deepLinkToTarget(ad.buttonLink);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
                              shadowColor:
                                  context.primaryColor.withOpacity(0.4),
                            ),
                            child: Text(
                              ad.buttonText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
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
