class Category {
  final String categoryId;
  final String name;
  final String? description;
  final String? imageUrl;

  Category({
    required this.categoryId,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory Category.fromFirestore(Map<String, dynamic> json) => Category(
        categoryId: json['categoryId'],
        name: json['name'],
        description: json['description'],
        imageUrl: json['imageUrl'],
      );
}

final List<Category> catList = [
  Category(categoryId: "cat_001", name: "Premium Bikes"),
  Category(categoryId: "cat_002", name: "Protection Gear"),
  Category(categoryId: "cat_003", name: "Luggage && Accessories"),
  Category(categoryId: "cat_004", name: "All Products"),
];
