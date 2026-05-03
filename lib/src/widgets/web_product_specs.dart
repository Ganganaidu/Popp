import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        if (product.isProductBikeSpecific == true) ...[
          if (product.bikeBrandName?.isNotEmpty ?? false)
            _buildSpecRow("Bike Brand", product.bikeBrandName!, theme),
          if (product.bikeModelName?.isNotEmpty ?? false)
            _buildSpecRow("Bike Model", product.bikeModelName!, theme),
          if (product.bikeMfgDate != null)
            _buildSpecRow("Bike MFG Date",
                _formatDate(product.bikeMfgDate, true), theme),
        ],
        if (product.mfgDate != null)
          _buildSpecRow("Manufacturing Date", _formatDate(product.mfgDate, true), theme),
        if (product.city.isNotEmpty) _buildSpecRow("City", product.city, theme),
        if (product.area.isNotEmpty) _buildSpecRow("Area", product.area, theme),
        if (product.state.isNotEmpty) _buildSpecRow("State", product.state, theme),
        if (product.kmDriven?.isNotEmpty ?? false)
          _buildSpecRow("KM Driven", product.kmDriven!, theme),
        if (product.registrationDate != null)
          _buildSpecRow("Registration Date", _formatDate(product.registrationDate, true), theme),
        if (product.firstOwner != null)
          _buildSpecRow("Current Ownership Number", product.firstOwner!, theme),
        if (product.productAging?.isNotEmpty ?? false)
          _buildSpecRow("Product Aging", product.productAging!, theme),
        if (product.productSize?.isNotEmpty ?? false)
          _buildSpecRow("Product Size", product.productSize!, theme),
        if (product.productCondition?.isNotEmpty ?? false)
          _buildSpecRow("Product Condition", product.productCondition!, theme),
        if (product.insuranceAvailable != null)
          _buildSpecRow("Insurance Available", product.insuranceAvailable!, theme),
        if (product.insuranceValidTill != null)
          _buildSpecRow("Insurance valid till", _formatDate(product.insuranceValidTill, false), theme),
        if (product.invoiceAvailable != null)
          _buildSpecRow("Invoice Available", product.invoiceAvailable!, theme),
        if (product.category.contains(ProductUtils.premiumBikes) &&
            product.nocAvailable != null)
          _buildSpecRow("NOC Available", product.nocAvailable!, theme),
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
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date, bool selectOnlyMonthYear) {
    if (date == null) return "-";
    final String displayFormat = selectOnlyMonthYear ? 'MMMM yyyy' : 'dd/MM/yyyy';
    return DateFormat(displayFormat).format(date);
  }
}
