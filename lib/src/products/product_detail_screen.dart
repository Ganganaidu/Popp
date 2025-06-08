import 'package:flutter/material.dart';
import 'package:popp/src/models/product.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/expandable_product_details_widget.dart';
import '../widgets/expandable_text_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedImageIndex = 0;
  bool isFavorite = false;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedImageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _callSeller() async {
    final Uri url =
        Uri(scheme: 'tel', path: widget.product.sellerContactNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
      widget.product.isFavorite = isFavorite;
    });
  }

  Widget _buildImage(String url, {bool useHero = false}) {
    final imageWidget = Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 400,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            color: Colors.white,
            width: double.infinity,
            height: 400,
          ),
        );
      },
    );

    return useHero
        ? Hero(
            tag: widget.product.imageUrl ?? '',
            child: imageWidget,
          )
        : imageWidget;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
        appBar: AppBar(title: Text(widget.product.getTitle())),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Main Image Carousel
              Stack(
                children: [
                  SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.product.thumbImageUrls?.length,
                      onPageChanged: (index) {
                        setState(() {
                          selectedImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final url = widget.product.thumbImageUrls?[index] ?? '';
                        return _buildImage(
                          url,
                          useHero: index == 0,
                        );
                      },
                    ),
                  ),

                  // 🔹 Fav Icon
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: _toggleFavorite,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),

                  // 🔹 Bottom Dashes Indicator (overlay on image)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            widget.product.thumbImageUrls?.length ?? 0,
                            (index) {
                          bool isActive = index == selectedImageIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 20 : 12,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.white54 : Colors.black26,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  // 🔹 Thumbnail Indicator
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${selectedImageIndex + 1} / ${widget.product.thumbImageUrls?.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 🔹 Thumbnails
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.product.thumbImageUrls?.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    final url = widget.product.thumbImageUrls?[index] ?? '';
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImageIndex = index;
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: selectedImageIndex == index
                                  ? Colors.blue
                                  : Colors.transparent,
                              width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            url,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // 🔹 Title and Price
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.getTitle(),
                      style: theme.titleLarge?.copyWith(
                          color: Colors.blue[700], fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.product.expectedPrice,
                      style: theme.titleLarge?.copyWith(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      "Product Description",
                      style: theme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ExpandableText(
                      description: widget.product.additionalDetails,
                    ),

                    const SizedBox(height: 24),
                    Text(
                      "Product Details",
                      style: theme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ExpandableProductDetails(
                      product: widget.product,
                    ),

                    // 🔹 Seller Contact Card
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.person,
                                  color: Colors.white, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.product.sellerName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(widget.product.sellerContactNumber,
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text(widget.product.registrationPlace ?? "",
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _callSeller,
                              icon: const Icon(Icons.call),
                              label: const Text("Call"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
