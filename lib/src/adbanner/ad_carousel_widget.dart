import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/adbanner/model/ad_banner.dart';
import 'package:popp/src/adbanner/repository/ad_carousel_viewmodel.dart';
import 'package:popp/src/utils/app_constants.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../deeplink/DeepLinkConfig.dart';
import '../navigation/nav_router.dart';
import '../widgets/app_network_image.dart';

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
          return isWeb
              ? _webShimmer()
              : SizedBox(
                  height: 420,
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

        if (viewModel.error != null || viewModel.ads.isEmpty) {
          return isWeb
              ? const SizedBox(height: 8)
              : _buildFallbackUI(isWeb: false);
        }

        // Web: compact 3-up card row
        if (isWeb) return _buildWebAds(viewModel.ads);

        // Mobile: full-screen carousel
        if (viewModel.ads.length == 1) {
          return SizedBox(
            height: 420,
            child: buildAdSlide(viewModel.ads.first, isWeb: false),
          );
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            CarouselSlider(
              carouselController: _controller,
              items: viewModel.ads
                  .map((ad) => buildAdSlide(ad, isWeb: false))
                  .toList(),
              options: CarouselOptions(
                height: 420,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
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
                      color: isActive ? context.primaryColor : Colors.white70,
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

  Widget _buildWebAds(List<AdBanner> ads) {
    final visible = ads.take(3).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(visible.length, (i) {
          final ad = visible[i];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? 0 : 8,
                right: i == visible.length - 1 ? 0 : 8,
              ),
              child: _WebAdCard(ad: ad, onTap: () => deepLinkToTarget(ad.buttonLink)),
            ),
          );
        }),
      ),
    );
  }

  Widget _webShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
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
                    : AppNetworkImage(
                        imageUrl: ad.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: Image.asset(
                          'assets/ads_default_image.png',
                          fit: BoxFit.cover,
                        ),
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
                left: 60,
                // Indent content slightly
                top: 0,
                bottom: 0,
                width: 600,
                // Fixed max width for content
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
                        fontSize: 48,
                        // Larger title
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
                    if (ad.buttonText.isNotEmpty && ad.buttonLink.isNotEmpty)
                      ElevatedButton(
                        onPressed: () async {
                          deepLinkToTarget(ad.buttonLink);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          // Theme Green
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8), // Less rounded for modern look
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
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (ad.imageUrl.isEmpty)
              Image.asset(
                'assets/book_track_trainings.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            else
              AppNetworkImage(
                imageUrl: ad.imageUrl,
                fit: BoxFit.cover,
                placeholder: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: Image.asset(
                  'assets/book_track_trainings.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            // Darker overlay for better text contrast
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                // Centered vertically in available space
                children: [
                  const Spacer(flex: 2),
                  // Push content down explicitly
                  if (ad.highlight.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B4332).withOpacity(0.8),
                        // Dark Green background
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: const Color(0xFF2D6A4F), width: 1),
                      ),
                      child: Text(
                        ad.highlight.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF4ADE80), // Bright Green text
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  if (ad.title.isNotEmpty) const SizedBox(height: 16),
                  Text(
                    ad.title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      // Assuming this font is available or fallback
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  if (ad.subtitle.isNotEmpty) const SizedBox(height: 12),
                  Text(
                    ad.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (ad.subtitle.isNotEmpty &&
                      ad.buttonText.isNotEmpty &&
                      ad.buttonLink.isNotEmpty)
                    _buildMobileCta(ad),
                  const Spacer(flex: 3),
                  // Leave space for PopServicesWidgets at bottom
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCta(AdBanner ad) {
    return InkWell(
      onTap: () async {
        deepLinkToTarget(ad.buttonLink);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ad.buttonText.toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                size: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebAdCard extends StatelessWidget {
  final AdBanner ad;
  final VoidCallback onTap;

  const _WebAdCard({required this.ad, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: ad.imageUrl.isEmpty
                  ? Image.asset('assets/ads_default_image.png', fit: BoxFit.cover)
                  : Image.network(
                      ad.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
                      ),
                    ),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC000000)],
                    stops: [0.4, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'AD',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ad.highlight,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    ad.subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
