import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  String uid; // Required by create rule
  String email; // Standard, good to have
  String? displayName;
  String? photoURL;
  // Required by create rule (use FieldValue.serverTimestamp())
  FieldValue createdAt;
  List<String> createdProductIds; // Required by create rule
  List<String> savedProductIds;   // Required by create rule
  List<BikeData>? bikeData; // List of bike data>
  // Add other fields from your sign-up form
  String? username;
  String? phoneNumber;
  String? address;
  String? city;
  String? pinCode;
  String? stateName; // Assuming from your earlier UI context

  UserData({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.createdAt,
    List<String>? createdProductIds, // Allow null for default empty list
    List<String>? savedProductIds,   // Allow null for default empty list
    List<BikeData>? bikeData,   // Allow null for default empty list
    this.username,
    this.phoneNumber,
    this.address,
    this.city,
    this.pinCode,
    this.stateName,
  })  : createdProductIds = createdProductIds ?? [], // Default to empty list
        savedProductIds = savedProductIds ?? [];   // Default to empty list

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName ?? username,
      if (photoURL != null) 'photoURL': photoURL,
      'createdAt': createdAt, // This will be FieldValue.serverTimestamp()
      'createdProductIds': createdProductIds,
      'savedProductIds': savedProductIds,
      'bikeData': bikeData,
      if (username != null) 'username': username,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (pinCode != null) 'pinCode': pinCode,
      if (stateName != null) 'stateName': stateName,
    };
  }

  // Optional: Add a fromJson factory if you fetch this data
  factory UserData.fromFireStore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserData(
      uid: doc.id, // Or data['uid'] if you store it redundantly
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      createdAt: data['createdAt'], // This will be a Timestamp when read
      createdProductIds: List<String>.from(data['createdProductIds'] ?? []),
      savedProductIds: List<String>.from(data['savedProductIds'] ?? []),
      username: data['username'],
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      city: data['city'],
      pinCode: data['pinCode'],
      stateName: data['stateName']
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
}
