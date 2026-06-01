import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../widgets/app_network_image.dart';

class CarouselWidget extends StatefulWidget {
  const CarouselWidget({super.key});

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          items: imageSliders,
          options: CarouselOptions(
            height: 400,
            initialPage: 0,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
            scrollDirection: Axis.horizontal,
          ),
        ),
        Positioned(
          bottom: 20.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(imgList.length, (index) {
              bool isActive = index == _current;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 16 : 12,
                height: 4,
                decoration: BoxDecoration(
                  color: isActive ? Colors.green : Colors.white70,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.8),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

final List<String> imgList = [
  'https://images.unsplash.com/photo-1622185135505-2d795003994a?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  'https://images.unsplash.com/photo-1611429532458-f8bf8f6121fe?q=80&w=3079&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  'https://images.unsplash.com/photo-1622185135825-d34b40aa03ef?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  'https://images.unsplash.com/photo-1643111441058-24775743af1c?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  'https://images.unsplash.com/photo-1638003299152-dd1e3bf81fa5?q=80&w=2242&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  'https://images.unsplash.com/photo-1558981033-0f0309284409?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'
];

final List<Widget> imageSliders = imgList
    .map((item) => Container(
          margin: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.zero,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                AppNetworkImage(
                  imageUrl: item,
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black54, // <-- darker bottom
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ))
    .toList();
