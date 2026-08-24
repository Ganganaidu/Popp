import 'package:flutter/material.dart';
import 'package:popp/src/api/api_url.dart';
import 'package:popp/src/widgets/full_screen_image_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'app_network_image.dart';

class WebImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final ValueNotifier<int> selectedIndexNotifier;

  const WebImageGallery({
    super.key,
    required this.imageUrls,
    required this.selectedIndexNotifier,
  });

  @override
  State<WebImageGallery> createState() => _WebImageGalleryState();
}

class _WebImageGalleryState extends State<WebImageGallery> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.selectedIndexNotifier,
      builder: (context, selectedIndex, _) {
        final cs = Theme.of(context).colorScheme;
        final currentImageUrl = widget.imageUrls.isNotEmpty
            ? widget.imageUrls[selectedIndex]
            : ApiUrl.defaultPlaceholderImage;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Image
            GestureDetector(
              onTap: () {
                if (widget.imageUrls.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => FullScreenImageScreen(
                        imageUrls: widget.imageUrls,
                        initialIndex: selectedIndex,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                height: 500,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.surfaceContainerHighest,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AppNetworkImage(
                    imageUrl: currentImageUrl,
                    fit: BoxFit.cover,
                    placeholder: Shimmer.fromColors(
                      baseColor: cs.surfaceContainerHighest,
                      highlightColor: cs.surface,
                      child: Container(color: cs.surfaceContainerHighest),
                    ),
                    errorWidget: Center(
                        child: Icon(Icons.broken_image,
                            size: 50, color: cs.onSurface.withOpacity(0.4))),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Thumbnails
             if (widget.imageUrls.length > 1)
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.imageUrls.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () {
                         widget.selectedIndexNotifier.value = index;
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? context.primaryColor : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10), // slightly less than container to account for border
                          child: AppNetworkImage(
                            imageUrl: widget.imageUrls[index],
                            fit: BoxFit.cover,
                            errorWidget: Icon(Icons.broken_image,
                                size: 20, color: cs.onSurface.withOpacity(0.4)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

extension on BuildContext {
  Color get primaryColor => Theme.of(this).primaryColor;
}
