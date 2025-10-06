import 'package:flutter/cupertino.dart';
import 'package:popp/src/utils/product_utils.dart';

import '../navigation/nav_router.dart';
import '../utils/app_constants.dart';

class DeepLinkConfig {
  final bool requiresAuth;
  final String loginMessage;
  final Function(BuildContext)? action;

  DeepLinkConfig({
    this.requiresAuth = true,
    this.loginMessage = '',
    this.action,
  });
}

final deepLinkConfigs = {
  findMechanic: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: '',
    action: (context) =>
        onServiceListingTap(context, ProductUtils.findMechanic, null, false),
  ),
  findBikeRentals: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'Find Bike Rentals',
    action: (context) =>
        onServiceListingTap(context, ProductUtils.bikeRentals, null, false),
  ),
  listYourServices: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'List your service',
    action: (context) => onListYourServiceTap(context),
  ),
  premiumBikeInspection: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'Premium Bike Inspection',
    action: (context) =>
        onServiceListingTap(context, Constants.premiumInspection, null, false),
  ),
  findTrackTraining: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'Find Track Day or Training Day',
    action: (context) => onServiceListingTap(
        context,
        [ProductUtils.trackDay, ProductUtils.trainingDay].join(','),
        null,
        false),
  ),
  sellAccessory: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'Sell your accessory',
    action: (context) => onSellYourAccessoriesTap(context),
  ),
  sellYourBike: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'Sell your bike',
    action: (context) => onSelleYourBikeTap(context),
  ),
  tyreShop: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'Tyre shops',
    action: (context) =>
        onServiceListingTap(context, ProductUtils.tyreShop, null, false),
  ),
  accessoryStore: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'Accessory store',
    action: (context) =>
        onServiceListingTap(context, ProductUtils.accessoryStore, null, false),
  ),
  aboutUs: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'About Us',
    action: (context) => onAboutUsTap(context),
  )
};

const String sellYourBike = 'sellBike';
const String sellAccessory = 'sellAccessory';
const String findTrackTraining = 'findTrackTraining';
const String premiumBikeInspection = 'premiumBikeInspection';
const String listYourServices = 'listYourServices';
const String findBikeRentals = 'findBikeRentals';
const String findMechanic = 'findMechanic';
const String tyreShop = 'tyreShop';
const String accessoryStore = 'accessoryStore';
const aboutUs = 'aboutUs';
