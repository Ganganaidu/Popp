import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white24),
              ),
            ),
          ),
      errorWidget: (context, url, error) => _buildErrorWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          color: Colors.grey[900],
          width: width,
          height: height,
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.white24, size: 40),
          ),
        );
  }
}
