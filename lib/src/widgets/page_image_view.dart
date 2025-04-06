import 'package:flutter/material.dart';

class PageImageView extends StatelessWidget {
  final Color color;

  const PageImageView({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                  fit: BoxFit.fitWidth,
                  height: 200,
                  "https://images.pexels.com/photos/2899097/pexels-photo-2899097.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"),
            )
          ],
        ),
      ),
    );
  }
}
