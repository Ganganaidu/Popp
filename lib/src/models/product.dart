import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String userId;
  final String productId;
  final String categoryId;
  final String categoryName;
  final String brandName;
  final String modelName;
  final String expectedPrice;
  final String imageUrl;
  final List<String> thumbImageUrls;
  final String additionalDetails;
  final DateTime? mfgDate;
  final String? firstOwner;
  final String? invoiceAvailable;
  final DateTime? registrationDate;
  final String registrationPlace; // City & State
  final String city;
  final String state;
  final String? nocAvailable; // If other states
  final String? insuranceAvailable;
  final String insuranceType;
  final String sellerName;
  final String sellerContactNumber;
  final String kmDriven;
  final FieldValue? createdAt;
  bool? isFavorite;

  Product(
      {required this.userId,
      required this.productId,
      required this.categoryId,
      required this.categoryName,
      required this.brandName,
      required this.expectedPrice,
      required this.modelName,
      required this.additionalDetails,
      required this.firstOwner,
      this.mfgDate,
      required this.invoiceAvailable,
      this.registrationDate,
      required this.registrationPlace,
      required this.city,
      required this.state,
      required this.nocAvailable,
      required this.insuranceAvailable,
      required this.insuranceType,
      required this.sellerName,
      required this.imageUrl,
      required this.thumbImageUrls,
      required this.sellerContactNumber,
      this.isFavorite,
      required this.kmDriven,
      this.createdAt});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      userId: json['userId'],
      productId: json['productId'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      additionalDetails: json['additionalDetails'],
      firstOwner: json['firstOwner'],
      kmDriven: json['kmDriven'],
      brandName: json['brandName'],
      modelName: json['modelName'],
      expectedPrice: json['expectedPrice'],
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
      sellerName: json['sellerName'],
      imageUrl: json['imageUrl'],
      thumbImageUrls: json['thumbImageUrls'],
      sellerContactNumber: json['sellerContactNumber'],
      isFavorite: json['isFavorite'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      userId: userId,
      'productId': productId,
      'categoryId': categoryId,
      'brandName': brandName,
      'modelName': modelName,
      'mfgDate': mfgDate?.toIso8601String(),
      'invoiceAvailable': invoiceAvailable,
      'registrationDate': registrationDate?.toIso8601String(),
      'registrationPlace': registrationPlace,
      'nocAvailable': nocAvailable,
      'insuranceAvailable': insuranceAvailable,
      'insuranceType': insuranceType,
      'expectedPrice': expectedPrice,
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
      userId: "uid",
      productId: 'P001',
      categoryId: 'C001',
      categoryName: '',
      expectedPrice: "123,000",
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
      additionalDetails: '',
      firstOwner: '',
      kmDriven: '',
      mfgDate: DateTime(2021, 5, 10),
      invoiceAvailable: "NO",
      registrationDate: DateTime(2021, 6, 15),
      registrationPlace: 'Bangalore, Karnataka',
      city: 'Bangalore',
      state: 'Karnataka',
      nocAvailable: "No",
      insuranceAvailable: "Yes",
      insuranceType: 'Comprehensive',
      sellerName: 'John Doe',
      sellerContactNumber: '9876543210',
      isFavorite: true),
  Product(
      userId: "userId",
      productId: 'P002',
      categoryName: '',
      categoryId: 'C001',
      brandName: 'Hero',
      expectedPrice: "120000",
      modelName: 'Splendor Plus',
      imageUrl:
          "https://images.unsplash.com/photo-1622185135505-2d795003994a?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      thumbImageUrls: [
        'https://images.unsplash.com/photo-1622185135825-d34b40aa03ef?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1622185135505-2d795003994a?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1611429532458-f8bf8f6121fe?q=80&w=3079&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1643111441058-24775743af1c?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      mfgDate: DateTime(2018, 11, 20),
      invoiceAvailable: 'Yes',
      registrationDate: DateTime(2019, 1, 5),
      registrationPlace: 'Mumbai, Maharashtra',
      city: 'Mumbai',
      state: 'Maharashtra',
      nocAvailable: 'Yes',
      insuranceAvailable: 'Yes',
      insuranceType: 'Third-party',
      sellerName: 'Jane Smith',
      sellerContactNumber: '8765432109',
      additionalDetails: '',
      firstOwner: '',
      kmDriven: '',
      isFavorite: false),
  Product(
      userId: "id",
      productId: 'P003',
      categoryName: '',
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
      mfgDate: DateTime(2020, 5, 10),
      invoiceAvailable: 'Yes',
      registrationDate: DateTime(2020, 6, 15),
      city: 'Mumbai',
      state: 'Maharashtra',
      registrationPlace: 'Delhi',
      nocAvailable: 'Yes',
      insuranceAvailable: 'Yes',
      insuranceType: 'Comprehensive',
      expectedPrice: '700000.00',
      sellerName: 'Alex',
      sellerContactNumber: '9876543210',
      additionalDetails: '',
      firstOwner: '',
      kmDriven: '',
      isFavorite: false)
];

// Helmet
// https://images.unsplash.com/photo-1627530980937-b8721b91506a?q=80&w=3165&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D
// https://images.unsplash.com/photo-1586423702505-b13505519074?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D
// https://images.unsplash.com/photo-1575396565848-e8031f12ce2a?q=80&w=3125&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D
// https://images.unsplash.com/photo-1623038868323-7d39ec58eefe?q=80&w=2000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D
