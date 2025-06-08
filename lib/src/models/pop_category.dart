import 'package:popp/src/models/product.dart';

class PopCategory {
  final String categoryId;
  final String name;
  List<String>? subcategories;
  List<Product>? products;

  PopCategory(
      {required this.categoryId,
      required this.name,
      this.subcategories,
      this.products});
}

final List<PopCategory> catList = [
  PopCategory(
    categoryId: "cat_001",
    name: "Premium Bikes",
    subcategories: [],
  ),
  PopCategory(
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
  PopCategory(
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
  PopCategory(
    categoryId: "cat_004",
    name: "Lights & Mounts",
    subcategories: [
      "Aux Lights",
      "Clamps & Mounts",
      "Wiring Harness",
      "Phone Mounts",
    ],
  ),
  PopCategory(
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
  PopCategory(
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
  PopCategory(
    categoryId: "cat_007",
    name: "Other Products",
    subcategories: [],
  ),
];

/// Returns all category names from catList
List<String> getAllPopCategoryNames() {
  return catList.map((cat) => cat.name).toList();
}

/// Returns all unique subcategory names from catList
List<String> getAllPopSubCategoryNames() {
  final subCats = <String>{};
  for (final cat in catList) {
    if (cat.subcategories != null) {
      subCats.addAll(cat.subcategories!);
    }
  }
  return subCats.toList();
}
