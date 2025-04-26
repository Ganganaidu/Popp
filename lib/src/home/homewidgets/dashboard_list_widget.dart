import 'package:flutter/material.dart';
import 'package:poppflutter/src/utils/build_extensions.dart';
import 'package:poppflutter/src/models/product.dart';
import '../../bikes/vehicle_details_widget_page.dart';
import '../../models/home_category_model.dart';

// https://medium.com/flutter-community/handling-network-calls-like-a-pro-in-flutter-31bd30c86be1

class DashboardListViewWidget extends StatefulWidget {
  final BuildContext context; // Receive the context here
  const DashboardListViewWidget({super.key, required this.context});

  @override
  State<DashboardListViewWidget> createState() => _DashboardListViewWidget();
}

class _DashboardListViewWidget extends State<DashboardListViewWidget> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: catList.length - 1,
      itemBuilder: (context, index) {
        return Container(
          decoration: const BoxDecoration(color: Colors.white),
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
                height: 230,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productList.length,
                  itemBuilder: (context, innerIndex) {
                    return GestureDetector(
                      onTap: () {
                        // Navigate to vehicle details page here
                        Navigator.of(widget.context).pushNamed('/vehicleDetails');
                        //builder: (context) => VehicleDetailsWidgetPage(product: productList[innerIndex]),
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Column(
                          // Use a Column for vertical arrangement
                          children: [
                            Flexible(
                                flex: 3, // flex is weight of the view
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
                                flex: 2,
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
