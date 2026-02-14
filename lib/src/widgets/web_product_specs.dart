import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/product.dart';
import '../utils/product_utils.dart';

class WebProductSpecs extends StatelessWidget {
  final Map<String, dynamic> productJson;

  const WebProductSpecs({super.key, required this.productJson});

  @override
  Widget build(BuildContext context) {
    final product = Product.fromJson(productJson, productJson["id"]);
    final theme = Theme.of(context).textTheme;

    // List of all specs to display
    final specs = <Widget>[
        if (product.mfgDate != null)
          _buildSpecRow("Manufacturing Date", _formatDate(product.mfgDate, true), theme),
        if (product.registrationPlace?.isNotEmpty ?? false)
          _buildSpecRow("Registration Place", product.registrationPlace!, theme),
        if (product.city.isNotEmpty) _buildSpecRow("City", product.city, theme),
        if (product.area.isNotEmpty) _buildSpecRow("Area", product.area, theme),
        if (product.state.isNotEmpty) _buildSpecRow("State", product.state, theme),
        if (product.kmDriven?.isNotEmpty ?? false)
          _buildSpecRow("KM Driven", product.kmDriven!, theme),
        if (product.registrationDate != null)
          _buildSpecRow("Registration Date", _formatDate(product.registrationDate, true), theme),
        if (product.registrationDate != null)
          _buildSpecRow("Bill Date", _formatDate(product.billDate, false), theme),
        if (product.firstOwner != null)
          _buildSpecRow("Current Ownership Number", product.firstOwner!, theme),
        if (product.productAging?.isNotEmpty ?? false)
          _buildSpecRow("Product Aging", product.productAging!, theme),
        if (product.productSize?.isNotEmpty ?? false)
          _buildSpecRow("Product Size", product.productSize!, theme),
        if (product.productCondition?.isNotEmpty ?? false)
          _buildSpecRow("Product Condition", product.productCondition!, theme),
        if (product.insuranceAvailable != null)
          _buildSpecRow("Insurance Available", product.insuranceAvailable != null ? "Yes" : "No", theme),
        if (product.insuranceValidTill != null)
          _buildSpecRow("Insurance valid till", _formatDate(product.insuranceValidTill, false), theme),
        _buildSpecRow("Warranty Available", product.warrantyLimit != null ? "Yes" : "No", theme),
        if (product.warrantyLimit?.isNotEmpty ?? false)
          _buildSpecRow("Warranty Limit", product.warrantyLimit!, theme),
        _buildSpecRow("Invoice Available", product.invoiceAvailable != null ? "Yes" : "No", theme),
        if (product.category.contains(ProductUtils.premiumBikes))
          _buildSpecRow("NOC Available", product.nocAvailable != null ? "Yes" : "No", theme),
        if (product.batteryCondition != null)
          _buildSpecRow("Battery Condition", product.batteryCondition!, theme),
        if (product.tyreCondition != null)
          _buildSpecRow("Tyre Condition", product.tyreCondition!, theme),
        if (product.additionalDetails.isNotEmpty)
          _buildSpecRow("Additional Details", product.additionalDetails, theme),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: specs,
    );
  }

  Widget _buildSpecRow(String title, String value, TextTheme theme) {
     final isRegistrationPlace = title.toLowerCase().contains('registration place');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey, // Label color
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: isRegistrationPlace && value.isNotEmpty
                ? GestureDetector(
                    onTap: () async {
                      final encoded = Uri.encodeComponent(value);
                      final url = 'https://www.google.com/maps/search/?api=1&query=$encoded';
                      await launchUrlString(url, mode: LaunchMode.externalApplication);
                    },
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold, // Value bold as per design
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date, bool selectOnlyMonthYear) {
    if (date == null) return "-";
    final String displayFormat = selectOnlyMonthYear ? 'MMMM yyyy' : 'MMMM dd yyyy';
    return DateFormat(displayFormat).format(date);
  }
}
