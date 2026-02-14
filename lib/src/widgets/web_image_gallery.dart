import 'package:flutter/material.dart';
import 'package:popp/src/api/api_url.dart';
import 'package:popp/src/widgets/full_screen_image_screen.dart';
import 'package:shimmer/shimmer.dart';

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
                height: 500, // Fixed height for main image area
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    currentImageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                       if (loadingProgress == null) return child;
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.grey[300]),
                        );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey));
                    },
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
                          child: Image.network(
                            widget.imageUrls[index],
                            fit: BoxFit.cover,
                             errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 20, color: Colors.grey),
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
