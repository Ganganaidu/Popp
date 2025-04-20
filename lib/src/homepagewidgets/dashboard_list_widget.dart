import 'package:flutter/material.dart';
import 'package:poppflutter/src/utils/build_extensions.dart';
import 'package:poppflutter/src/models/product.dart';

import 'model/home_category_model.dart';

// https://medium.com/flutter-community/handling-network-calls-like-a-pro-in-flutter-31bd30c86be1

class DashboardListViewWidget extends StatelessWidget {
  const DashboardListViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: catList.length - 1,
      itemBuilder: (context, index) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(catList[index].title,
                    style: context.bodyMedium?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    )),
              ),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productList.length,
                  itemBuilder: (context, innerIndex) {
                    return Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        // Use a Column for vertical arrangement
                        children: [
                          Flexible(
                              flex: 1,
                              child: Padding(
                                  // Add padding to the second TextView
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  // Adjust padding values as needed
                                  child: productList[innerIndex]
                                          .isProductInStock
                                      ? ElevatedButton(
                                          onPressed: () {
                                            // Button action
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25.0),
                                            ),
                                          ),
                                          child: Text('Sale',
                                              style: context.bodyMedium
                                                  ?.copyWith(
                                                      color: Colors.white)),
                                        )
                                      : OutlinedButton(
                                          onPressed: () {
                                            // Button action
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                color: Colors.red),
                                            // Red border color
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  25.0), // Round borders with radius 25
                                            ),
                                          ),
                                          child: Text(
                                            'Out of stock',
                                            style: context.bodyMedium
                                                ?.copyWith(color: Colors.red),
                                          ),
                                        ))),
                          Flexible(
                              flex: 3,
                              child: Padding(
                                // Add padding to the second TextView
                                padding: const EdgeInsets.only(bottom: 8.0),
                                // Adjust padding values as needed
                                child: Image.network(
                                  productList[innerIndex].imageUrl,
                                  // Replace with your image URL
                                  width: 100,
                                  height: 130,
                                  fit: BoxFit.cover,
                                ),
                              )),
                          Flexible(
                              flex: 1,
                              child: Padding(
                                  // Add padding to the second TextView
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  // Adjust padding values as needed
                                  child: SizedBox(
                                    width: 150,
                                    child: Text(
                                        style: context.bodyMedium,
                                        productList[innerIndex].title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center),
                                  ))),
                          Flexible(
                              flex: 1,
                              child: Padding(
                                // Add padding to the second TextView
                                padding: const EdgeInsets.only(bottom: 8.0),
                                // Adjust padding values as needed
                                child: Text(
                                  productList[innerIndex].priceRange,
                                  style: context.titleSmall,
                                ),
                              )),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
