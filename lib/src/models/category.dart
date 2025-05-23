class Category {
  final String categoryId;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<String> subcategories;

  Category(
      {required this.categoryId,
      required this.name,
      this.description,
      this.imageUrl,
      required this.subcategories});
}

final List<Category> catList = [
  Category(
    categoryId: "cat_001",
    name: "Premium Bikes",
    subcategories: [],
  ),
  Category(
    categoryId: "cat_002",
    name: "Protection Gear",
    subcategories: [
      "Helmets",
      "Riding Gloves",
      "Riding Jackets",
      "Riding Pants",
      "Riding Boots",
      "Other Protectors",
    ],
  ),
  Category(
    categoryId: "cat_003",
    name: "Luggage & Accessories",
    subcategories: [
      "Hard Top Cases",
      "Hard Side Cases & Accessories",
      "Saddle Bags",
      "Soft Luggage",
      "Saddle Stays & Accessories",
      "Top Racks & Accessories",
      "Tank Bags & Rings",
      "Tail Bags",
      "BackPacks",
      "Other Luggage accessories",
    ],
  ),
  Category(
    categoryId: "cat_004",
    name: "Lights & Mounts",
    subcategories: [
      "Aux Lights",
      "Clamps & Mounts",
      "Wiring Harness",
      "Phone Mounts",
    ],
  ),
  Category(
    categoryId: "cat_005",
    name: "Electronic Accessories",
    subcategories: [
      "Communication/Intercom Devices",
      "Charging Accessories",
      "Dash cams",
      "Autoplay Devices",
      "TPMS",
      "Other Electronic Accessories",
    ],
  ),
  Category(
    categoryId: "cat_006",
    name: "Universal Bike Accessories",
    subcategories: [
      "Exhaust Systems",
      "Crash Guards",
      "Radiator Guards",
      "Windscreens & Extenders",
      "Side Stand Extenders",
      "Filters, Oil & Lubricants",
      "Other Bike Accessories",
    ],
  ),
  Category(
    categoryId: "cat_007",
    name: "Other Products",
    subcategories: [],
  ),
];
