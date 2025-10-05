import 'package:flutter/cupertino.dart';

import '../navigation/nav_router.dart';
import '../utils/app_constants.dart';
import '../utils/product_content_data.dart';

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
        onServiceListingTap(context, serviceCategories[0], false),
  ),
  findBikeRentals: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'Find Bike Rentals',
    action: (context) =>
        onServiceListingTap(context, serviceCategories[1], false),
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
        onServiceListingTap(context, Constants.premiumInspection, false),
  ),
  findTrackTraining: DeepLinkConfig(
    requiresAuth: true,
    loginMessage: 'Find Track Day or Training Day',
    action: (context) => onServiceListingTap(
        context, [serviceCategories[2], serviceCategories[3]].join(','), false),
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
const aboutUs = 'aboutUs';