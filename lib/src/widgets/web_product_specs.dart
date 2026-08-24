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
    final cs = Theme.of(context).colorScheme;

    // List of all specs to display
    final specs = <Widget>[
        if (product.isProductBikeSpecific == true) ...[
          if (product.bikeBrandName?.isNotEmpty ?? false)
            _buildSpecRow("Bike Brand", product.bikeBrandName!, theme, cs),
          if (product.bikeModelName?.isNotEmpty ?? false)
            _buildSpecRow("Bike Model", product.bikeModelName!, theme, cs),
          if (product.bikeMfgDate != null)
            _buildSpecRow("Bike MFG Date",
                _formatDate(product.bikeMfgDate, true), theme, cs),
        ],
        if (product.mfgDate != null)
          _buildSpecRow("Manufacturing Date", _formatDate(product.mfgDate, true), theme, cs),
        if (product.city.isNotEmpty) _buildSpecRow("City", product.city, theme, cs),
        if (product.area.isNotEmpty) _buildSpecRow("Area", product.area, theme, cs),
        if (product.state.isNotEmpty) _buildSpecRow("State", product.state, theme, cs),
        if (product.kmDriven?.isNotEmpty ?? false)
          _buildSpecRow("KM Driven", product.kmDriven!, theme, cs),
        if (product.registrationDate != null)
          _buildSpecRow("Registration Date", _formatDate(product.registrationDate, true), theme, cs),
        if (product.firstOwner != null)
          _buildSpecRow("Current Ownership Number", product.firstOwner!, theme, cs),
        if (product.productAging?.isNotEmpty ?? false)
          _buildSpecRow("Product Aging", product.productAging!, theme, cs),
        if (product.productSize?.isNotEmpty ?? false)
          _buildSpecRow("Product Size", product.productSize!, theme, cs),
        if (product.productCondition?.isNotEmpty ?? false)
          _buildSpecRow("Product Condition", product.productCondition!, theme, cs),
        if (product.insuranceAvailable != null)
          _buildSpecRow("Insurance Available", product.insuranceAvailable!, theme, cs),
        if (product.insuranceValidTill != null)
          _buildSpecRow("Insurance valid till", _formatDate(product.insuranceValidTill, false), theme, cs),
        if (product.invoiceAvailable != null)
          _buildSpecRow("Invoice Available", product.invoiceAvailable!, theme, cs),
        if (product.category.contains(ProductUtils.premiumBikes) &&
            product.nocAvailable != null)
          _buildSpecRow("NOC Available", product.nocAvailable!, theme, cs),
        if (product.batteryCondition != null)
          _buildSpecRow("Battery Condition", product.batteryCondition!, theme, cs),
        if (product.tyreCondition != null)
          _buildSpecRow("Tyre Condition", product.tyreCondition!, theme, cs),
        if (product.additionalDetails.isNotEmpty)
          _buildSpecRow("Additional Details", product.additionalDetails, theme, cs),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: specs,
    );
  }

  Widget _buildSpecRow(String title, String value, TextTheme theme, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$title:",
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurface.withOpacity(0.6),
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
