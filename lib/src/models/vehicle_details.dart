class VehicleDetails {
  final String brandName;
  final String modelName;
  final String description;
  final String features;
  final DateTime? mfgDate;
  final bool invoiceAvailable;
  final DateTime? registrationDate;
  final String registrationPlace; // City & State
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

  VehicleDetails({
    required this.brandName,
    required this.modelName,
    required this.description,
    required this.features,
    this.mfgDate,
    required this.invoiceAvailable,
    this.registrationDate,
    required this.registrationPlace,
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
    required this.sellerContactNumber,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) {
    return VehicleDetails(
      brandName: json['brandName'],
      modelName: json['modelName'],
      description: json['description'],
      features: json['features'],
      mfgDate: json['mfgDate'] != null ? DateTime.parse(json['mfgDate']) : null,
      invoiceAvailable: json['invoiceAvailable'],
      registrationDate: json['registrationDate'] != null
          ? DateTime.parse(json['registrationDate'])
          : null,
      registrationPlace: json['registrationPlace'],
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
      sellerContactNumber: json['sellerContactNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brandName': brandName,
      'modelName': modelName,
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
    };
  }
}
