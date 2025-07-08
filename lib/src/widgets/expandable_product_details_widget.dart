import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
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
        // detailRow("Features", product.additionalDetails, theme),
        if (product.mfgDate != null)
          detailRow("Manufacturing Date", _formatDate(product.mfgDate), theme),
        if (product.registrationPlace?.isNotEmpty ?? false)
          detailRow("Registration Place", product.registrationPlace!, theme)
        else
          const SizedBox.shrink(),

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.city.isNotEmpty)
                  detailRow("City", product.city, theme),
                if (product.state.isNotEmpty)
                  detailRow("State", product.state, theme),
                if (product.kmDriven?.isNotEmpty ?? false)
                  detailRow("KM Driven", product.kmDriven!, theme),
                if (product.registrationDate != null)
                  detailRow("Registration Date",
                      _formatDate(product.registrationDate), theme),
                if (product.registrationDate != null)
                  detailRow("Bill Date", _formatDate(product.billDate), theme),
                if (product.productAging?.isNotEmpty ?? false)
                  detailRow("Product Aging", product.productAging!, theme),
                if (product.productSize?.isNotEmpty ?? false)
                  detailRow("Product Size", product.productSize!, theme),
                if (product.productCondition?.isNotEmpty ?? false)
                  detailRow(
                      "Product Condition", product.productCondition!, theme),
                if (product.insuranceAvailable != null)
                  detailRow("Insurance Available",
                      product.insuranceAvailable != null ? "Yes" : "No", theme),
                if (product.insuranceValidTill != null)
                  detailRow("Insurance valid till",
                      _formatDate(product.insuranceValidTill), theme),
                detailRow("Warranty Available",
                    product.warrantyLimit != null ? "Yes" : "No", theme),
                if (product.warrantyLimit?.isNotEmpty ?? false)
                  detailRow("Warranty Limit", product.warrantyLimit!, theme),
                detailRow("Invoice Available",
                    product.invoiceAvailable != null ? "Yes" : "No", theme),
                detailRow("NOC Available",
                    product.nocAvailable != null ? "Yes" : "No", theme),
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
    final isRegistrationPlace =
        title.toLowerCase().contains('registration place');
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
          Expanded(
            flex: 5,
            child: isRegistrationPlace && value.isNotEmpty
                ? GestureDetector(
                    onTap: () async {
                      final encoded = Uri.encodeComponent(value);
                      final url =
                          'https://www.google.com/maps/search/?api=1&query=$encoded';
                      await launchUrlString(url,
                          mode: LaunchMode.externalApplication);
                    },
                    child: Text(
                      value,
                      style: theme.bodyMedium?.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(value),
          ),
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
