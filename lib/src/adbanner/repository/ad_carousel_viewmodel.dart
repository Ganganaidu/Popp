import 'package:flutter/material.dart';

import '../model/ad_banner.dart';
import 'ad_repository.dart';

class AdCarouselViewModel extends ChangeNotifier {
  final AdRepository _repository;

  List<AdBanner> ads = [];
  bool isLoading = false;
  String? error;

  AdCarouselViewModel(this._repository);

  /// Load ads. If [isActive] is provided, only ads matching that flag will be returned.
  Future<void> loadAds([bool? isActive]) async {
    isLoading = true;
    notifyListeners();

    try {
      ads = await _repository.fetchAds(isActive);
      error = null;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  /// Toggle the isActive status for a given ad and refresh the list.
  Future<void> toggleAdStatus(AdBanner ad) async {
    if (ad.id == null) {
      error = 'Ad does not have an id';
      notifyListeners();
      return;
    }

    final newStatus = !ad.isActive;
    final hideBlackOverlay = (ad.title.isEmpty && ad.subtitle.isEmpty);
    isLoading = true;
    notifyListeners();

    try {
      await _repository.updateAdStatus(ad.id!, newStatus);
      // Update local copy to avoid refetching entire list immediately.
      final idx = ads.indexWhere((a) => a.id == ad.id);
      if (idx != -1) {
        ads[idx] = AdBanner(
          id: ad.id,
          imageUrl: ad.imageUrl,
          title: ad.title,
          highlight: ad.highlight,
          subtitle: ad.subtitle,
          points: ad.points,
          buttonText: ad.buttonText,
          buttonLink: ad.buttonLink,
          isActive: newStatus,
          hideOverlay: hideBlackOverlay,
        );
      }
      error = null;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
