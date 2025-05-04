import 'package:flutter/material.dart';
import '../models/product.dart';

class ExpandableProductDetails extends StatefulWidget {
  final Product product;

  const ExpandableProductDetails({super.key, required this.product});

  @override
  State<ExpandableProductDetails> createState() =>
      _ExpandableProductDetailsState();
}

class _ExpandableProductDetailsState extends State<ExpandableProductDetails>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Always Visible Important Fields
        detailRow("Features", product.features, theme),
        detailRow("Manufacturing Date", _formatDate(product.mfgDate), theme),
        detailRow("Expected Price",
            "₹${product.expectedPrice.toStringAsFixed(2)}", theme),
        detailRow("Price Negotiable", product.isPriceNegotiable ? "Yes" : "No",
            theme),
        detailRow("Registration Place", product.registrationPlace, theme),

        const SizedBox(height: 8),

        // Expandable Section
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          child: ConstrainedBox(
            constraints: isExpanded
                ? const BoxConstraints()
                : const BoxConstraints(maxHeight: 0),
            child: Column(
              children: [
                detailRow("City", product.city, theme),
                detailRow("State", product.state, theme),
                detailRow("Invoice Available",
                    product.invoiceAvailable ? "Yes" : "No", theme),
                detailRow("Registration Date",
                    _formatDate(product.registrationDate), theme),
                detailRow("NOC Available", product.nocAvailable ? "Yes" : "No",
                    theme),
                detailRow("Insurance Available",
                    product.insuranceAvailable ? "Yes" : "No", theme),
                detailRow("Insurance Type", product.insuranceType, theme),
                detailRow(
                    "Insurance Validity", product.insuranceValidity, theme),
                detailRow("PUC Available", product.pucAvailable ? "Yes" : "No",
                    theme),
                detailRow("Battery Condition", product.batteryCondition, theme),
                detailRow("Tyre Condition", product.tyreCondition, theme),
                detailRow("Current Ownership No",
                    product.currentOwnershipNo.toString(), theme),
                detailRow(
                    "Purchase Date", _formatDate(product.purchaseDate), theme),
                detailRow("Seller Name", product.sellerName, theme),
                detailRow("Seller Contact", product.sellerContactNumber, theme),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Show More / Show Less Button
        Center(
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            icon: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.blue,
            ),
            label: Text(
              isExpanded ? "Show Less" : "Show More",
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  Widget detailRow(String title, String value, TextTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 3,
              child: Text("$title:",
                  style:
                      theme.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return "${date.day}/${date.month}/${date.year}";
  }
}

//  const TextStyle(fontWeight: FontWeight.w600)
