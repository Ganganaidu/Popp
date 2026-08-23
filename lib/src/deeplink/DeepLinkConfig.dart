import 'package:flutter/cupertino.dart';
import 'package:popp/src/utils/product_utils.dart';

import '../navigation/app_routes.dart';

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
        context.pushServiceListing(ProductUtils.findMechanic),
  ),
  findBikeRentals: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'Find Bike Rentals',
    action: (context) =>
        context.pushServiceListing(ProductUtils.bikeRentals),
  ),
  listYourServices: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'List your service',
    action: (context) => context.pushListServiceCategory(),
  ),
  premiumBikeInspection: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'Premium Bike Inspection',
    action: (context) =>
        context.pushServiceListing(ProductUtils.premiumInspection),
  ),
  findTrackTraining: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'Find Track Day or Training Day',
    action: (context) => context.pushServiceListing(
        [ProductUtils.trackDay, ProductUtils.trainingDay].join(',')),
  ),
  sellAccessory: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'Sell your accessory',
    action: (context) => context.pushSellAccessories(),
  ),
  sellYourBike: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'Sell your bike',
    action: (context) => context.pushSellBike(),
  ),
  tyreShop: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'Tyre shops',
    action: (context) => context.pushServiceListing(ProductUtils.tyreShop),
  ),
  accessoryStore: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'Accessory store',
    action: (context) =>
        context.pushServiceListing(ProductUtils.accessoryStore),
  ),
  aboutUs: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'About Us',
    action: (context) => context.pushAboutUs(),
  ),
  towingService: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'Towing service',
    action: (context) =>
        context.pushServiceListing(ProductUtils.towingService),
  ),
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
const String towingService = 'towingService';
const aboutUs = 'aboutUs';
