import 'package:flutter/material.dart';
import '../models/product.dart';

class ExpandableProductDetails extends StatefulWidget {
  final Product product;

  const ExpandableProductDetails({super.key, required this.product});

  @override
  State<ExpandableProductDetails> createState() => _ExpandableProductDetailsState();
}

class _ExpandableProductDetailsState extends State<ExpandableProductDetails> with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Always Visible Important Fields
        detailRow("Features", product.features),
        detailRow("Manufacturing Date", _formatDate(product.mfgDate)),
        detailRow("Expected Price", "₹${product.expectedPrice.toStringAsFixed(2)}"),
        detailRow("Price Negotiable", product.isPriceNegotiable ? "Yes" : "No"),
        detailRow("Registration Place", product.registrationPlace),

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
                detailRow("City", product.city),
                detailRow("State", product.state),
                detailRow("Invoice Available", product.invoiceAvailable ? "Yes" : "No"),
                detailRow("Registration Date", _formatDate(product.registrationDate)),
                detailRow("NOC Available", product.nocAvailable ? "Yes" : "No"),
                detailRow("Insurance Available", product.insuranceAvailable ? "Yes" : "No"),
                detailRow("Insurance Type", product.insuranceType),
                detailRow("Insurance Validity", product.insuranceValidity),
                detailRow("PUC Available", product.pucAvailable ? "Yes" : "No"),
                detailRow("Battery Condition", product.batteryCondition),
                detailRow("Tyre Condition", product.tyreCondition),
                detailRow("Current Ownership No", product.currentOwnershipNo.toString()),
                detailRow("Purchase Date", _formatDate(product.purchaseDate)),
                detailRow("Seller Name", product.sellerName),
                detailRow("Seller Contact", product.sellerContactNumber),
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

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Text("$title:", style: const TextStyle(fontWeight: FontWeight.w600))),
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

