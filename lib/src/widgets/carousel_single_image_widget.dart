import 'package:flutter/material.dart';
import 'app_network_image.dart';

class CarouselSingleImageWidget extends StatefulWidget {
  final List<String> imageUrls;

  const CarouselSingleImageWidget({super.key, required this.imageUrls});

  @override
  State<CarouselSingleImageWidget> createState() =>
      _CarouselSingleImageWidgetState();
}

class _CarouselSingleImageWidgetState extends State<CarouselSingleImageWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          itemCount: widget.imageUrls.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return AppNetworkImage(
              imageUrl: widget.imageUrls[index],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            );
          },
        ),
        // Optional: Add small page indicator dots
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imageUrls.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: _currentIndex == index ? 8 : 6,
                height: _currentIndex == index ? 8 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
