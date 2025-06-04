import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../models/product.dart';
import '../navigation/nav_router.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final double width;

  const ProductCard({super.key, required this.product, required this.width});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                onProductTap(context, product);
              },
              child: Hero(
                tag: product.id ?? UniqueKey().toString(),
                child: SizedBox(
                  height: width,
                  width: width,
                  child: product.imageUrl?.isNotEmpty == true
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: width,
                                width: width,
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.broken_image, size: width * 0.5),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported,
                              size: width * 0.5),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.getTitle(),
            style: theme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(product.expectedPrice,
              style: theme.titleMedium?.copyWith(
                  color: Colors.orange[700], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
