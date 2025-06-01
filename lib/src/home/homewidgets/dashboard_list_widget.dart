import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poppflutter/src/models/product.dart';
import 'package:poppflutter/src/models/Category.dart';
import '../../navigation/nav_router.dart';
import '../../utils/app_loger.dart';


class DashboardListViewWidget extends StatefulWidget {
  const DashboardListViewWidget({super.key});

  @override
  State<DashboardListViewWidget> createState() =>
      _DashboardListViewWidgetState();
}

class _DashboardListViewWidgetState extends State<DashboardListViewWidget> {
  late Future<List<Category>> _categoriesWithProductsFuture;

  @override
  void initState() {
    super.initState();
    _categoriesWithProductsFuture = _fetchProductsAndGroupCategories();
  }

  Future<List<Category>> _fetchProductsAndGroupCategories() async {
    try {
      QuerySnapshot productSnapshot =
          await FirebaseFirestore.instance.collection('products').get();

      if (productSnapshot.docs.isEmpty) {
        return []; // No products found
      }

      List<Product> allProducts = productSnapshot.docs.map((doc) {
        return Product.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Group products by categoryId
      Map<String, List<Product>> productsByCategory = {};
      Map<String, String> categoryIdToNameMap = {}; // To store category names

      for (var product in allProducts) {
        if (!productsByCategory.containsKey(product.categoryId)) {
          productsByCategory[product.categoryId] = [];
          categoryIdToNameMap[product.categoryId] =
              product.categoryName; // Store category name
        }
        productsByCategory[product.categoryId]!.add(product);
      }

      // Convert the grouped map into a list of DisplayCategory objects
      List<Category> displayCategories = [];
      productsByCategory.forEach((categoryId, productList) {
        displayCategories.add(Category(
          categoryId: categoryId,
          name: categoryIdToNameMap[categoryId] ?? 'Unknown Category',
          // Fallback name
          products: productList,
        ));
      });

      // Optional: Sort categories by name or some other criteria
      displayCategories.sort((a, b) => a.name.compareTo(b.name));

      return displayCategories;
    } catch (e) {
      // Handle errors appropriately in a real app (e.g., show an error message)
      AppLogger.e("Error fetching products: $e");
      throw Exception(
          "Failed to load products"); // Re-throw to be caught by FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: _categoriesWithProductsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Loader
        }

        if (snapshot.hasError) {
          return Center(
              child: Text("Error: ${snapshot.error}")); // Error message
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text("No products found.")); // No data message
        }

        final categories = snapshot.data!;

        return ListView.builder(
          // Changed from Column to ListView for better performance with many categories
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategorySection(
              categoryName: category.name, // Pass name directly
              products: category.products ?? [],
            );
          },
        );
      },
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String categoryName; // Changed from Category object to just name
  final List<Product> products;

  const _CategorySection({
    required this.categoryName,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    // Make sure this is appropriate for your content
    final itemWidth = screenWidth * 0.4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryName,
            style: theme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: itemWidth + 100,
            // Adjust height based on your item card content
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return SizedBox(
                  width: itemWidth,
                  child: Column(
                    // Usually better for text alignment
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => onProductTap(context, product),
                          child: Hero(
                            // Ensure a unique tag
                            tag: product.id ??
                                product.userId ??
                                UniqueKey().toString(),
                            child: SizedBox(
                              height: itemWidth,
                              width: itemWidth,
                              child: product.imageUrl != null &&
                                      product.imageUrl!.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl!,
                                      fit: BoxFit.cover,
                                      // Optional: Add loadingBuilder and errorBuilder for Image.network
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(Icons.broken_image,
                                            size: itemWidth * 0.5);
                                      },
                                    )
                                  : Container(
                                      // Placeholder if no image
                                      height: itemWidth,
                                      width: itemWidth,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.image_not_supported,
                                          size: itemWidth * 0.5),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.getTitle(), // Using your getTitle method
                        textAlign: TextAlign.start,
                        style: theme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.expectedPrice,
                        // Assuming this is formatted as a String (e.g., "$100.00")
                        textAlign: TextAlign.start,
                        style: theme.titleMedium?.copyWith(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
