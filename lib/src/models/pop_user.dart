class PopUser {
  final String displayName;
  final String uid;
  final String? photoURL;
  final String? provider;
  final String? email;

  PopUser({
    required this.displayName,
    required this.uid,
    this.email,
    this.photoURL,
    this.provider,
  });

  factory PopUser.fromFireStore(Map<String, dynamic> json) => PopUser(
        displayName: json['displayName'],
        uid: json['uid'],
        photoURL: json['photoURL'],
        provider: json['provider'],
        email: json['email'],
      );
}
