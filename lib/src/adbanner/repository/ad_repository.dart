import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/ad_banner.dart';

class AdRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AdBanner>> fetchAds() async {
    final snapshot = await _firestore.collection('ads').get();
    return snapshot.docs.map((doc) => AdBanner.fromJson(doc.data())).toList();
  }
}
