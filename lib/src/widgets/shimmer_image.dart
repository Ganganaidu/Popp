import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'app_network_image.dart';

class ShimmerImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ShimmerImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return AppNetworkImage(
      imageUrl: imageUrl,
      width: width ?? double.infinity,
      height: height,
      fit: fit,
      placeholder: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          color: Colors.grey.shade300,
        ),
      ),
      errorWidget: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        color: Colors.grey.shade200,
        child: Icon(
          Icons.two_wheeler,
          color: Colors.grey.shade400,
          size: 40,
        ),
      ),
    );
  }
}
