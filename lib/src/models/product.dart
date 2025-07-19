import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id;
  final String? userId;
  final String categoryId;
  final String category;
  final String? subCategory;
  final String brandName;
  final String modelName;
  final String expectedPrice;
  final String price;
  final String? imageUrl;
  final List<String>? thumbImageUrls;
  final String additionalDetails;
  final DateTime? mfgDate;
  final String? firstOwner;
  final String? invoiceAvailable;
  final DateTime? registrationDate;
  String? registrationPlace; // City & State
  final String city;
  final String address; // City & State
  final String? pinCode; // City & State
  final String state;
  final String? nocAvailable; // If other states
  final String? insuranceAvailable;
  final DateTime? insuranceValidTill;
  final String sellerName;
  final String sellerContactNumber;
  final String? kmDriven;
  bool? isFavorite;
  DateTime? billDate;
  bool? isProductBikeSpecific;
  String? productSize;
  String? productCondition;
  String? productAging;
  String? warrantyLimit;
  String? bikeBrandName; // we choose this filed for accessories
  String? bikeModelName; // we choose this filed for accessories
  DateTime? bikeMfgDate; // we choose this filed for accessories
  final FieldValue? createdAt; // For writing to FireStore
  final DateTime? createdAtDate; // For reading from FireStore
  String? batteryCondition;
  String? tyreCondition;
  bool isApproved = false; // Default value for new products
  bool isSold = false;
  List<String>? searchKeywords;
  List<String>? favoritedBy;
  final String? countryCode;

  Product(
      {this.id,
      this.userId,
      required this.categoryId,
      required this.category,
      this.subCategory,
      required this.brandName,
      required this.expectedPrice,
      required this.price,
      required this.modelName,
      required this.additionalDetails,
      this.firstOwner,
      this.mfgDate,
      this.invoiceAvailable,
      this.registrationDate,
      this.registrationPlace,
      required this.city,
      required this.address,
      this.pinCode,
      required this.state,
      this.nocAvailable,
      this.insuranceAvailable,
      this.insuranceValidTill,
      required this.sellerName,
      this.imageUrl,
      this.thumbImageUrls,
      required this.sellerContactNumber,
      this.isFavorite,
      this.kmDriven,
      this.billDate,
      this.isProductBikeSpecific = false,
      this.createdAt, // Used when creating/updating
      this.createdAtDate, // Used when reading
      this.productSize,
      this.productCondition,
      this.productAging,
      this.warrantyLimit,
      this.bikeBrandName,
      this.bikeModelName,
      this.bikeMfgDate,
      this.batteryCondition,
      this.tyreCondition,
      required this.isApproved,
      required this.isSold,
      this.searchKeywords,
      required this.countryCode,
      this.favoritedBy});

  // Factory constructor to create a Product from a JSON map (e.g., from Firestore)
  factory Product.fromJson(Map<String, dynamic> json, String documentId) {
    return Product(
        id: documentId,
        userId: json['userId'] as String?,
        categoryId: json['categoryId'] as String? ?? '',
        category: json['category'] as String? ?? '',
        subCategory: json['subCategory'] as String?,
        brandName: json['brandName'] as String? ?? '',
        modelName: json['modelName'] as String? ?? '',
        expectedPrice: json['expectedPrice'] as String? ?? '',
        price: json['price'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
        thumbImageUrls: (json['thumbImageUrls'] as List<dynamic>?)
                ?.map((item) => item as String)
                .toList() ??
            [],
        additionalDetails: json['additionalDetails'] as String? ?? '',
        mfgDate: _parseDate(json['mfgDate']),
        firstOwner: json['firstOwner'] as String?,
        invoiceAvailable: json['invoiceAvailable'] as String?,
        registrationDate: _parseDate(json['registrationDate']),
        registrationPlace: json['registrationPlace'] as String? ?? '',
        city: json['city'] as String? ?? '',
        address: json['address'] as String? ?? '',
        pinCode: json['pinCode'] as String? ?? '',
        state: json['state'] as String? ?? '',
        nocAvailable: json['nocAvailable'] as String?,
        insuranceAvailable: json['insuranceAvailable'] as String?,
        insuranceValidTill: _parseDate(json['insuranceValidTill']),
        sellerName: json['sellerName'] as String? ?? '',
        sellerContactNumber: json['sellerContactNumber'] as String? ?? '',
        kmDriven: json['kmDriven'] as String?,
        isFavorite: json['isFavorite'] as bool?,
        isProductBikeSpecific: json['isProductBikeSpecific'] as bool?,
        isApproved: json['isApproved'] as bool? ?? false,
        isSold: json['isSold'] as bool? ?? false,
        // Explicitly cast to non-nullable
        billDate: _parseDate(json['billDate']),
        productSize: json['productSize'] as String?,
        productCondition: json['productCondition'] as String?,
        productAging: json['productAging'] as String?,
        warrantyLimit: json['warrantyLimit'] as String?,
        bikeBrandName: json['bikeBrandName'] as String?,
        bikeModelName: json['bikeModelName'] as String?,
        bikeMfgDate: (json['bikeMfgDate'] as Timestamp?)?.toDate(),
        batteryCondition: json['batteryCondition'] as String?,
        tyreCondition: json['tyreCondition'] as String?,
        searchKeywords: (json['searchKeywords'] as List<dynamic>?)
            ?.map((item) => item as String)
            .toList(),
        favoritedBy: (json['favoritedBy'] as List<dynamic>?)
            ?.map((item) => item as String)
            .toList(),
        // `createdAt` is a FieldValue for writing, so we read it as DateTime
        createdAtDate: (json['createdAt'] as Timestamp?)?.toDate(),
        countryCode: json['countryCode'] as String?
        // We don't typically re-initialize `createdAt` (FieldValue) from json
        );
  }

  // Method to convert a Product instance to a JSON map (e.g., for Firestore)
  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      'id': id,
      'isApproved': isApproved, // Assuming default value for new products
      'isSold': isSold, // Always include isSold in the JSON
      'categoryId': categoryId,
      'category': category,
      if (subCategory != null) 'subCategory': subCategory,
      'brandName': brandName,
      'modelName': modelName,
      'expectedPrice': expectedPrice,
      'price': price,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (thumbImageUrls != null) 'thumbImageUrls': thumbImageUrls,
      'additionalDetails': additionalDetails,
      if (mfgDate != null) 'mfgDate': Timestamp.fromDate(mfgDate!),
      if (firstOwner != null) 'firstOwner': firstOwner,
      if (invoiceAvailable != null) 'invoiceAvailable': invoiceAvailable,
      if (registrationDate != null)
        'registrationDate': Timestamp.fromDate(registrationDate!),
      'registrationPlace': "$city - $state",
      'city': city,
      'address': address,
      'pinCode': pinCode,
      'state': state,
      if (nocAvailable != null) 'nocAvailable': nocAvailable,
      if (insuranceAvailable != null) 'insuranceAvailable': insuranceAvailable,
      if (insuranceValidTill != null) 'insuranceValidTill': insuranceValidTill,
      'sellerName': sellerName,
      'sellerContactNumber': sellerContactNumber,
      if (kmDriven != null) 'kmDriven': kmDriven,
      if (isFavorite != null) 'isFavorite': isFavorite,
      if (isProductBikeSpecific != null)
        'isProductBikeSpecific': isProductBikeSpecific,
      if (billDate != null) 'billDate': Timestamp.fromDate(billDate!),
      // `createdAt` is usually FieldValue.serverTimestamp() when creating
      if (productSize != null) 'productSize': productSize,
      if (productCondition != null) 'productCondition': productCondition,
      if (productAging != null) 'productAging': productAging,
      if (warrantyLimit != null) 'warrantyLimit': warrantyLimit,
      if (bikeBrandName != null) 'bikeBrandName': bikeBrandName,
      if (bikeModelName != null) 'bikeModelName': bikeModelName,
      if (bikeMfgDate != null) 'bikeMfgDate': Timestamp.fromDate(bikeMfgDate!),
      if (batteryCondition != null) 'batteryCondition': batteryCondition,
      if (tyreCondition != null) 'tyreCondition': tyreCondition,
      if (searchKeywords != null) 'searchKeywords': searchKeywords,
      if (favoritedBy != null) 'favoritedBy': favoritedBy,
      'countryCode': countryCode,
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

  String getBrandAndModelName() {
    return "$brandName $modelName";
  }

  Product copyWith(
      {String? userId,
      String? id,
      String? categoryId,
      String? category,
      String? subCategory,
      String? brandName,
      String? modelName,
      String? expectedPrice,
      String? price,
      String? imageUrl,
      List<String>? thumbImageUrls,
      String? additionalDetails,
      DateTime? mfgDate,
      String? firstOwner,
      String? invoiceAvailable,
      DateTime? registrationDate,
      String? registrationPlace,
      String? city,
      String? address,
      String? pinCode,
      String? state,
      String? nocAvailable,
      String? insuranceAvailable,
      DateTime? insuranceValidTill,
      String? sellerName,
      String? sellerContactNumber,
      String? kmDriven,
      FieldValue? createdAt, // Keep for writing
      DateTime? createdAtDate, // Keep for reading/display
      bool? isFavorite,
      DateTime? billDate,
      String? productSize,
      String? productCondition,
      String? productAging,
      String? warrantyLimit,
      String? bikeBrandName,
      String? bikeModelName,
      DateTime? bikeMfgDate,
      String? engineNo,
      String? chassisNo,
      String? rcNumber,
      String? batteryCondition,
      String? tyreCondition,
      bool isApproved = false, // Default value for new products
      bool isSold = false, // Default value for new products
      List<String>? searchKeywords,
      List<String>? favoritedBy,
      String? countryCode}) {
    return Product(
        userId: userId ?? this.userId,
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        category: category ?? this.category,
        subCategory: subCategory ?? this.subCategory,
        brandName: brandName ?? this.brandName,
        modelName: modelName ?? this.modelName,
        expectedPrice: expectedPrice ?? this.expectedPrice,
        price: price ?? this.price,
        imageUrl: imageUrl ?? this.imageUrl,
        thumbImageUrls: thumbImageUrls ?? this.thumbImageUrls,
        additionalDetails: additionalDetails ?? this.additionalDetails,
        mfgDate: mfgDate ?? this.mfgDate,
        firstOwner: firstOwner ?? this.firstOwner,
        invoiceAvailable: invoiceAvailable ?? this.invoiceAvailable,
        registrationDate: registrationDate ?? this.registrationDate,
        registrationPlace: registrationPlace ?? this.registrationPlace,
        city: city ?? this.city,
        address: address ?? this.address,
        pinCode: pinCode ?? this.pinCode,
        state: state ?? this.state,
        nocAvailable: nocAvailable ?? this.nocAvailable,
        insuranceAvailable: insuranceAvailable ?? this.insuranceAvailable,
        insuranceValidTill: insuranceValidTill ?? this.insuranceValidTill,
        sellerName: sellerName ?? this.sellerName,
        sellerContactNumber: sellerContactNumber ?? this.sellerContactNumber,
        kmDriven: kmDriven ?? this.kmDriven,
        createdAt: createdAt ?? this.createdAt,
        createdAtDate: createdAtDate ?? this.createdAtDate,
        isFavorite: isFavorite ?? this.isFavorite,
        billDate: billDate ?? this.billDate,
        productSize: productSize ?? this.productSize,
        productCondition: productCondition ?? this.productCondition,
        productAging: productAging ?? this.productAging,
        warrantyLimit: warrantyLimit ?? this.warrantyLimit,
        bikeBrandName: bikeBrandName ?? this.bikeBrandName,
        bikeModelName: bikeModelName ?? this.bikeModelName,
        bikeMfgDate: bikeMfgDate ?? this.bikeMfgDate,
        batteryCondition: batteryCondition ?? this.batteryCondition,
        tyreCondition: tyreCondition ?? this.tyreCondition,
        isApproved: isApproved,
        isSold: isSold,
        searchKeywords: searchKeywords ?? this.searchKeywords,
        favoritedBy: favoritedBy ?? this.favoritedBy,
        countryCode: countryCode ?? this.countryCode);
  }
}

// Add this helper function at the bottom of the file (outside the class):
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  return null;
}
