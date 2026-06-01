import 'package:flutter/material.dart';
import 'app_network_image.dart';

class PageImageView extends StatelessWidget {
  final Color color;

  const PageImageView({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const AppNetworkImage(
                  fit: BoxFit.fitWidth,
                  height: 200,
                  imageUrl:
                      "https://images.pexels.com/photos/2899097/pexels-photo-2899097.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"),
            )
          ],
        ),
      ),
    );
  }
}
