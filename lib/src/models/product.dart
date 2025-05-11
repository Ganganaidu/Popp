import 'package:poppflutter/src/models/pop_user.dart';

class Product {
  final PopUser user;
  final String productId;
  final String categoryId;
  final String brandName;
  final String modelName;
  final String price;
  final String imageUrl;
  final List<String> thumbImageUrls;
  final String description;
  final String features;
  final DateTime? mfgDate;
  final bool invoiceAvailable;
  final DateTime? registrationDate;
  final String registrationPlace; // City & State
  final String city;
  final String state;
  final bool nocAvailable; // If other states
  final bool insuranceAvailable;
  final String insuranceType;
  final String insuranceValidity; // Can be changed to DateTime if needed
  final bool pucAvailable;
  final String batteryCondition;
  final String tyreCondition;
  final double expectedPrice;
  final bool isPriceNegotiable;
  final int currentOwnershipNo;
  final DateTime? purchaseDate;
  final String sellerName;
  final String sellerContactNumber;
  bool isFavorite;

  Product(
      {required this.user,
      required this.productId,
      required this.categoryId,
      required this.brandName,
      required this.price,
      required this.modelName,
      required this.description,
      required this.features,
      this.mfgDate,
      required this.invoiceAvailable,
      this.registrationDate,
      required this.registrationPlace,
      required this.city,
      required this.state,
      required this.nocAvailable,
      required this.insuranceAvailable,
      required this.insuranceType,
      required this.insuranceValidity,
      required this.pucAvailable,
      required this.batteryCondition,
      required this.tyreCondition,
      required this.expectedPrice,
      required this.isPriceNegotiable,
      required this.currentOwnershipNo,
      this.purchaseDate,
      required this.sellerName,
      required this.imageUrl,
      required this.thumbImageUrls,
      required this.sellerContactNumber,
      required this.isFavorite});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      user: json['userId'],
      productId: json['productId'],
      categoryId: json['categoryId'],
      brandName: json['brandName'],
      price: json['price'],
      modelName: json['modelName'],
      description: json['description'],
      features: json['features'],
      mfgDate: json['mfgDate'] != null ? DateTime.parse(json['mfgDate']) : null,
      invoiceAvailable: json['invoiceAvailable'],
      registrationDate: json['registrationDate'] != null
          ? DateTime.parse(json['registrationDate'])
          : null,
      registrationPlace: json['registrationPlace'],
      city: json['city'],
      state: json['state'],
      nocAvailable: json['nocAvailable'],
      insuranceAvailable: json['insuranceAvailable'],
      insuranceType: json['insuranceType'],
      insuranceValidity: json['insuranceValidity'],
      pucAvailable: json['pucAvailable'],
      batteryCondition: json['batteryCondition'],
      tyreCondition: json['tyreCondition'],
      expectedPrice: (json['expectedPrice'] as num).toDouble(),
      isPriceNegotiable: json['isPriceNegotiable'],
      currentOwnershipNo: json['currentOwnershipNo'],
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'])
          : null,
      sellerName: json['sellerName'],
      imageUrl: json['imageUrl'],
      thumbImageUrls: json['thumbImageUrls'],
      sellerContactNumber: json['sellerContactNumber'],
      isFavorite: json['isFavorite'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'categoryId': categoryId,
      'brandName': brandName,
      'modelName': modelName,
      'price': price,
      'description': description,
      'features': features,
      'mfgDate': mfgDate?.toIso8601String(),
      'invoiceAvailable': invoiceAvailable,
      'registrationDate': registrationDate?.toIso8601String(),
      'registrationPlace': registrationPlace,
      'nocAvailable': nocAvailable,
      'insuranceAvailable': insuranceAvailable,
      'insuranceType': insuranceType,
      'insuranceValidity': insuranceValidity,
      'pucAvailable': pucAvailable,
      'batteryCondition': batteryCondition,
      'tyreCondition': tyreCondition,
      'expectedPrice': expectedPrice,
      'isPriceNegotiable': isPriceNegotiable,
      'currentOwnershipNo': currentOwnershipNo,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'sellerName': sellerName,
      'sellerContactNumber': sellerContactNumber,
      'imageUrl': imageUrl,
      'thumbImageUrls': thumbImageUrls,
      'isFavorite': isFavorite,
    };
  }

  String getTitle() {
    return "$brandName $modelName - $city";
  }
}

List<Product> productList = [
  Product(
      user: PopUser(displayName: "displayName", uid: "uid"),
      productId: 'P001',
      categoryId: 'C001',
      price: "123,000",
      brandName: 'Honda',
      modelName: 'Activa 6G',
      imageUrl:
          "https://images.unsplash.com/photo-1622185135505-2d795003994a?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      thumbImageUrls: [
        'https://images.unsplash.com/photo-1611429532458-f8bf8f6121fe?q=80&w=3079&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1622185135825-d34b40aa03ef?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1643111441058-24775743af1c?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1638003299152-dd1e3bf81fa5?q=80&w=2242&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1558981033-0f0309284409?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'
      ],
      description:
          'For sale: A meticulously maintained Honda Activa 6G. This scooter has been owned and cared for by a single individual. Its in excellent condition and ready for its next rider. Enjoy the renowned reliability of the Activa series. Perfect for daily commutes or leisurely rides.',
      features: 'Fuel-efficient, comfortable ride, good condition.',
      mfgDate: DateTime(2021, 5, 10),
      invoiceAvailable: true,
      registrationDate: DateTime(2021, 6, 15),
      registrationPlace: 'Bangalore, Karnataka',
      city: 'Bangalore',
      state: 'Karnataka',
      nocAvailable: false,
      insuranceAvailable: true,
      insuranceType: 'Comprehensive',
      insuranceValidity: '2024-06-15',
      pucAvailable: true,
      batteryCondition: 'Good',
      tyreCondition: 'Good',
      expectedPrice: 70000.00,
      isPriceNegotiable: true,
      currentOwnershipNo: 1,
      purchaseDate: DateTime(2021, 6, 15),
      sellerName: 'John Doe',
      sellerContactNumber: '9876543210',
      isFavorite: true),
  Product(
      user: PopUser(displayName: "displayName", uid: "uid"),
      productId: 'P002',
      categoryId: 'C001',
      price: "123,000",
      brandName: 'Hero',
      modelName: 'Splendor Plus',
      imageUrl:
          "https://images.unsplash.com/photo-1622185135505-2d795003994a?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      thumbImageUrls: [
        'https://images.unsplash.com/photo-1622185135825-d34b40aa03ef?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1622185135505-2d795003994a?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1611429532458-f8bf8f6121fe?q=80&w=3079&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1643111441058-24775743af1c?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      description:
          'Honda Activa 6G available from its original owner. This scooter has been well-maintained throughout its life. It boasts a clean history with no multiple owners. Expect a smooth ride and dependable performance. A great opportunity to own a trusted Activa model.',
      features: 'High mileage, low maintenance, sturdy build.',
      mfgDate: DateTime(2018, 11, 20),
      invoiceAvailable: false,
      registrationDate: DateTime(2019, 1, 5),
      registrationPlace: 'Mumbai, Maharashtra',
      city: 'Mumbai',
      state: 'Maharashtra',
      nocAvailable: true,
      insuranceAvailable: true,
      insuranceType: 'Third-party',
      insuranceValidity: '2023-12-31',
      pucAvailable: true,
      batteryCondition: 'Average',
      tyreCondition: 'Average',
      expectedPrice: 45000.00,
      isPriceNegotiable: true,
      currentOwnershipNo: 2,
      purchaseDate: DateTime(2020, 3, 10),
      sellerName: 'Jane Smith',
      sellerContactNumber: '8765432109',
      isFavorite: false),
  Product(
      user: PopUser(displayName: "displayName", uid: "uid"),
      productId: 'P003',
      price: "123,000",
      categoryId: 'C002',
      brandName: 'Maruti Suzuki',
      modelName: 'Swift Dzire',
      imageUrl:
          "https://images.unsplash.com/photo-1622185135505-2d795003994a?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      thumbImageUrls: [
        'https://images.unsplash.com/photo-1643111441058-24775743af1c?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1622185135505-2d795003994a?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1611429532458-f8bf8f6121fe?q=80&w=3079&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1622185135825-d34b40aa03ef?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      description:
          'Up for grabs: A pristine Honda Activa 6G. This single-owner scooter is in top-notch condition. Regular maintenance has ensured its longevity. Its ready to hit the road with its new owner. Dont miss out on this well-cared-for Activa.',
      features: 'Fuel-efficient, comfortable ride, good condition.',
      mfgDate: DateTime(2020, 5, 10),
      invoiceAvailable: true,
      registrationDate: DateTime(2020, 6, 15),
      city: 'Mumbai',
      state: 'Maharashtra',
      registrationPlace: 'Delhi',
      nocAvailable: false,
      insuranceAvailable: true,
      insuranceType: 'Comprehensive',
      insuranceValidity: '2024-06-15',
      pucAvailable: true,
      batteryCondition: 'Good',
      tyreCondition: 'Good',
      expectedPrice: 700000.00,
      isPriceNegotiable: true,
      currentOwnershipNo: 1,
      purchaseDate: DateTime(2020, 6, 15),
      sellerName: 'Alex',
      sellerContactNumber: '9876543210',
      isFavorite: false)
];

// Helmet
// https://images.unsplash.com/photo-1627530980937-b8721b91506a?q=80&w=3165&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D
// https://images.unsplash.com/photo-1586423702505-b13505519074?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D
// https://images.unsplash.com/photo-1575396565848-e8031f12ce2a?q=80&w=3125&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D
// https://images.unsplash.com/photo-1623038868323-7d39ec58eefe?q=80&w=2000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D
