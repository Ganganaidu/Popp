import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerImage extends StatefulWidget {
  final String imageUrl;

  const ShimmerImage({super.key, required this.imageUrl});

  @override
  State<ShimmerImage> createState() => _ShimmerImageState();
}

class _ShimmerImageState extends State<ShimmerImage> {
  bool _isLoaded = false;

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.two_wheeler,
        color: Colors.grey.shade400,
        size: 40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (!_isLoaded)
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              color: Colors.grey.shade300,
            ),
          ),
        Image.network(
          widget.imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) {
              if (!_isLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _isLoaded = true);
                });
              }
              return child;
            } else {
              return const SizedBox.shrink();
            }
          },
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        ),
      ],
    );
  }
}
