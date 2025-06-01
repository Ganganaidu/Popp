import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id;
  final String? userId;
  final String categoryId;
  final String categoryName;
  final String? subCategoryName;
  final String brandName;
  final String modelName;
  final String expectedPrice;
  final String? imageUrl;
  final List<String>? thumbImageUrls;
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
  final String? insuranceType;
  final String sellerName;
  final String sellerContactNumber;
  final String? kmDriven;
  bool? isFavorite;
  DateTime? billDate;
  final FieldValue? createdAt; // For writing to Firestore
  final DateTime? createdAtDate; // For reading from Firestore

  Product({
    this.id,
    this.userId,
    required this.categoryId,
    required this.categoryName,
    this.subCategoryName, // Made nullable to match potential fromJson scenarios
    required this.brandName,
    required this.expectedPrice,
    required this.modelName,
    required this.additionalDetails,
    this.firstOwner,
    this.mfgDate,
    this.invoiceAvailable,
    this.registrationDate,
    required this.registrationPlace,
    required this.city,
    required this.state,
    this.nocAvailable,
    this.insuranceAvailable,
    this.insuranceType,
    required this.sellerName,
    this.imageUrl,
    this.thumbImageUrls,
    required this.sellerContactNumber,
    this.isFavorite,
    this.kmDriven,
    this.billDate,
    this.createdAt, // Used when creating/updating
    this.createdAtDate, // Used when reading
  });

  // Factory constructor to create a Product from a JSON map (e.g., from Firestore)
  factory Product.fromJson(Map<String, dynamic> json, String documentId) {
    return Product(
      id: documentId, // Use the document ID from Firestore
      userId: json['userId'] as String?,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      subCategoryName: json['subCategoryName'] as String?,
      brandName: json['brandName'] as String,
      modelName: json['modelName'] as String,
      expectedPrice: json['expectedPrice'] as String,
      imageUrl: json['imageUrl'] as String?,
      thumbImageUrls: (json['thumbImageUrls'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList(),
      additionalDetails: json['additionalDetails'] as String,
      mfgDate: (json['mfgDate'] as Timestamp?)?.toDate(),
      firstOwner: json['firstOwner'] as String?,
      invoiceAvailable: json['invoiceAvailable'] as String?,
      registrationDate: (json['registrationDate'] as Timestamp?)?.toDate(),
      registrationPlace: json['registrationPlace'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      nocAvailable: json['nocAvailable'] as String?,
      insuranceAvailable: json['insuranceAvailable'] as String?,
      insuranceType: json['insuranceType'] as String?,
      sellerName: json['sellerName'] as String,
      sellerContactNumber: json['sellerContactNumber'] as String,
      kmDriven: json['kmDriven'] as String?,
      isFavorite: json['isFavorite'] as bool?,
      billDate: (json['billDate'] as Timestamp?)?.toDate(),
      // `createdAt` is a FieldValue for writing, so we read it as DateTime
      createdAtDate: (json['createdAt'] as Timestamp?)?.toDate(),
      // We don't typically re-initialize `createdAt` (FieldValue) from json
    );
  }

  // Method to convert a Product instance to a JSON map (e.g., for Firestore)
  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      if (subCategoryName != null) 'subCategoryName': subCategoryName,
      'brandName': brandName,
      'modelName': modelName,
      'expectedPrice': expectedPrice,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (thumbImageUrls != null) 'thumbImageUrls': thumbImageUrls,
      'additionalDetails': additionalDetails,
      if (mfgDate != null) 'mfgDate': Timestamp.fromDate(mfgDate!),
      if (firstOwner != null) 'firstOwner': firstOwner,
      if (invoiceAvailable != null) 'invoiceAvailable': invoiceAvailable,
      if (registrationDate != null)
        'registrationDate': Timestamp.fromDate(registrationDate!),
      'registrationPlace': registrationPlace,
      'city': city,
      'state': state,
      if (nocAvailable != null) 'nocAvailable': nocAvailable,
      if (insuranceAvailable != null) 'insuranceAvailable': insuranceAvailable,
      if (insuranceType != null) 'insuranceType': insuranceType,
      'sellerName': sellerName,
      'sellerContactNumber': sellerContactNumber,
      if (kmDriven != null) 'kmDriven': kmDriven,
      if (isFavorite != null) 'isFavorite': isFavorite,
      if (billDate != null) 'billDate': Timestamp.fromDate(billDate!),
      // `createdAt` is usually FieldValue.serverTimestamp() when creating
      // If it's null and you're creating, Firestore handles it.
      // If you're updating and don't want to change it, don't include it.
      // If you want to force set a timestamp on update, include it.
      if (createdAt != null) 'createdAt': createdAt,
      // Do not include createdAtDate in toJson for writing back to Firestore
      // as it's derived from the Timestamp.
    };
  }

  String getTitle() {
    return "$brandName $modelName - $city";
  }

  Product copyWith({
    String? userId,
    String? id,
    String? categoryId,
    String? categoryName,
    String? subCategoryName,
    String? brandName,
    String? modelName,
    String? expectedPrice,
    String? imageUrl,
    List<String>? thumbImageUrls,
    String? additionalDetails,
    DateTime? mfgDate,
    String? firstOwner,
    String? invoiceAvailable,
    DateTime? registrationDate,
    String? registrationPlace,
    String? city,
    String? state,
    String? nocAvailable,
    String? insuranceAvailable,
    String? insuranceType,
    String? sellerName,
    String? sellerContactNumber,
    String? kmDriven,
    FieldValue? createdAt, // Keep for writing
    DateTime? createdAtDate, // Keep for reading/display
    bool? isFavorite,
    DateTime? billDate,
  }) {
    return Product(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      brandName: brandName ?? this.brandName,
      modelName: modelName ?? this.modelName,
      expectedPrice: expectedPrice ?? this.expectedPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbImageUrls: thumbImageUrls ?? this.thumbImageUrls,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      mfgDate: mfgDate ?? this.mfgDate,
      firstOwner: firstOwner ?? this.firstOwner,
      invoiceAvailable: invoiceAvailable ?? this.invoiceAvailable,
      registrationDate: registrationDate ?? this.registrationDate,
      registrationPlace: registrationPlace ?? this.registrationPlace,
      city: city ?? this.city,
      state: state ?? this.state,
      nocAvailable: nocAvailable ?? this.nocAvailable,
      insuranceAvailable: insuranceAvailable ?? this.insuranceAvailable,
      insuranceType: insuranceType ?? this.insuranceType,
      sellerName: sellerName ?? this.sellerName,
      sellerContactNumber: sellerContactNumber ?? this.sellerContactNumber,
      kmDriven: kmDriven ?? this.kmDriven,
      createdAt: createdAt ?? this.createdAt,
      createdAtDate: createdAtDate ?? this.createdAtDate,
      isFavorite: isFavorite ?? this.isFavorite,
      billDate: billDate ?? this.billDate,
    );
  }
}

List<Product> productList = [
  Product(
      userId: "uid",
      id: 'P001',
      categoryId: 'C001',
      subCategoryName: '',
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
      id: 'P002',
      categoryName: '',
      subCategoryName: '',
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
      id: 'P003',
      categoryName: '',
      subCategoryName: '',
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
