import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  String uid;
  String email;
  String? displayName;
  String? photoURL;
  // This allows the field to hold a 'Timestamp' when read from Firestore,
  // or a 'FieldValue' when being prepared for a write operation.
  final dynamic createdAt;
  List<String> createdProductIds;
  List<String> savedProductIds;
  List<BikeData> bikeData;
  String? username;
  String? phoneNumber;
  String? address;
  String? area;
  String? city;
  String? pinCode;
  String? stateName;
  bool isSubscribed;
  bool registrationComplete;

  UserData({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.createdAt, // This now correctly accepts FieldValue or Timestamp
    List<String>? createdProductIds,
    List<String>? savedProductIds,
    List<BikeData>? bikeData,
    this.username,
    this.phoneNumber,
    this.address,
    this.area,
    this.city,
    this.pinCode,
    this.stateName,
    this.isSubscribed = false,
    this.registrationComplete = false,
  })  : createdProductIds = createdProductIds ?? [],
        savedProductIds = savedProductIds ?? [],
        bikeData = bikeData ?? [];

  /// Converts the UserData instance to a Map for writing to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName ?? username,
      if (photoURL != null) 'photoURL': photoURL,
      // This logic remains correct. If createdAt is null (new user),
      // it uses the server timestamp.
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'createdProductIds': createdProductIds,
      'savedProductIds': savedProductIds,
      'bikeData': bikeData.map((b) => b.toMap()).toList(),
      if (username != null) 'username': username,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (address != null) 'address': address,
      if (area != null) 'area': area,
      if (city != null) 'city': city,
      if (pinCode != null) 'pinCode': pinCode,
      if (stateName != null) 'stateName': stateName,
      'isSubscribed': isSubscribed,
      'registrationComplete': registrationComplete,
    };
  }

  /// Factory constructor to create a UserData instance from a Firestore document.
  factory UserData.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    final bikeDataListRaw = data['bikeData'] as List<dynamic>?;
    final bikeDataList = bikeDataListRaw != null
        ? bikeDataListRaw
            .map((b) => BikeData.fromMap(b as Map<String, dynamic>))
            .toList()
        : <BikeData>[];

    return UserData(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      // FIX 2: No cast is needed now, as the value is already dynamic.
      createdAt: data['createdAt'],
      createdProductIds: List<String>.from(data['createdProductIds'] ?? []),
      savedProductIds: List<String>.from(data['savedProductIds'] ?? []),
      bikeData: bikeDataList,
      username: data['username'],
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      area: data['area'],
      city: data['city'],
      pinCode: data['pinCode'],
      stateName: data['stateName'],
      isSubscribed: data['isSubscribed'] ?? false,
      registrationComplete: data['registrationComplete'] ?? false,
    );
  }
}

class BikeData {
  final String brand;
  final String model;
  final String monthYear;

  BikeData({
    required this.brand,
    required this.model,
    required this.monthYear,
  });

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'model': model,
      'monthYear': monthYear,
    };
  }

  factory BikeData.fromMap(Map<String, dynamic> map) {
    return BikeData(
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      monthYear: map['monthYear'] ?? '',
    );
  }
}
