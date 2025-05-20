import 'package:flutter/cupertino.dart';

import '../models/product.dart';
import '../navigation/nav_helper.dart';
import '../products/product_details_screen.dart';


// Define routes for each tab
final Map<String, WidgetBuilder> routes = {
  '/productDetails': (context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    return ProductDetailScreen(product: product);
  },
};

// call this from Dashboard_list_widget
void onProductTap(BuildContext context, Product product) {
  NavHelper().updateAppBarTitle?.call(product.getTitle());
  Navigator.of(context).pushNamed(
    '/productDetails',
    arguments: product,
  );
}
