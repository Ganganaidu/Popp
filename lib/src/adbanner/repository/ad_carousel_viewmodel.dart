import 'package:flutter/material.dart';

import '../model/ad_banner.dart';
import 'ad_repository.dart';

class AdCarouselViewModel extends ChangeNotifier {
  final AdRepository _repository;

  List<AdBanner> ads = [];
  bool isLoading = false;
  String? error;

  AdCarouselViewModel(this._repository);

  Future<void> loadAds() async {
    isLoading = true;
    notifyListeners();

    try {
      ads = await _repository.fetchAds();
      error = null;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
