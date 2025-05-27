class UserData {
  String? uid;
  final String username;
  final String email;
  final String? phoneNumber;
  String password;
  final String address;
  final String state;
  final String city;
  final String pinCode;
  String? photoURL;
  String? provider;
  String? displayName;
  final List<BikeData>? bikes;
  final bool? receiveNotifications;

  UserData({
    this.uid,
    required this.username,
    required this.email,
    this.phoneNumber,
    required this.password,
    required this.address,
    required this.state,
    required this.city,
    required this.pinCode,
    this.bikes,
    this.photoURL,
    this.displayName,
    this.provider,
    this.receiveNotifications,
  });

  UserData copyWith({
    List<BikeData>? bikes,
  }) {
    return UserData(
      username: username,
      email: email,
      password: password,
      address: address,
      state: state,
      city: city,
      pinCode: pinCode,
      bikes: bikes ?? this.bikes,
      receiveNotifications: receiveNotifications,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'address': address,
      'state': state,
      'city': city,
      'pinCode': pinCode,
      'receiveNotifications': receiveNotifications,
      'bikes_subscribed': bikes?.map((bike) => bike.toMap()).toList(),
    };
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
