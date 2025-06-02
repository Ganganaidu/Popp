import 'package:flutter/material.dart';
import 'package:poppflutter/src/adbanner/model/ad_banner.dart';
import 'package:poppflutter/src/adbanner/repository/ad_carousel_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';


class AdCarouselWidget extends StatefulWidget {
  const AdCarouselWidget({super.key});

  @override
  State<AdCarouselWidget> createState() => _AdCarouselWidgetState();
}

class _AdCarouselWidgetState extends State<AdCarouselWidget> {
  int _current = 0;

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
            height: 400,
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

        if (viewModel.error != null) {
          return SizedBox(height: 400, child: Center(child: Text(viewModel.error!)));
        }

        if (viewModel.ads.isEmpty) {
          return const SizedBox(height: 400, child: Center(child: Text("No ads available.")));
        }

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CarouselSlider(
              items: viewModel.ads.map(buildAdSlide).toList(),
              options: CarouselOptions(
                height: 400,
                viewportFraction: 1.0,
                autoPlay: true,
                onPageChanged: (index, reason) => setState(() => _current = index),
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

  Widget buildAdSlide(AdBanner ad) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          ad.imageUrl,
          fit: BoxFit.cover,
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(120, 0, 0, 0), // top transparent shadow
                Colors.black54 // bottom dark gradient
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(ad.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
              Text(ad.highlight, style: const TextStyle(color: Colors.orange, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(ad.subtitle, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: ad.points.map((point) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.orange, size: 18),
                    const SizedBox(width: 4),
                    Text(point, style: const TextStyle(color: Colors.white)),
                  ],
                )).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => launchUrl(Uri.parse(ad.buttonLink)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text(ad.buttonText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
