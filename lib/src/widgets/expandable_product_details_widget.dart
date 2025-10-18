import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/product.dart';

class ExpandableProductDetails extends StatefulWidget {
  final Map<String, dynamic> productJson;

  const ExpandableProductDetails({super.key, required this.productJson});

  @override
  State<ExpandableProductDetails> createState() =>
      _ExpandableProductDetailsState();
}

class _ExpandableProductDetailsState extends State<ExpandableProductDetails>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final product =
        Product.fromJson(widget.productJson, widget.productJson["id"]);
    final theme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Always Visible Important Fields
        // detailRow("Features", product.additionalDetails, theme),
        if (product.mfgDate != null)
          detailRow(
              "Manufacturing Date", _formatDate(product.mfgDate, true), theme),
        if (product.registrationPlace?.isNotEmpty ?? false)
          detailRow("Registration Place", product.registrationPlace!, theme),
        if (product.city.isNotEmpty) detailRow("City", product.city, theme),
        if (product.area.isNotEmpty) detailRow("Area", product.area, theme),
        if (product.state.isNotEmpty)
          detailRow("State", product.state, theme)
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
                if (product.kmDriven?.isNotEmpty ?? false)
                  detailRow("KM Driven", product.kmDriven!, theme),
                if (product.registrationDate != null)
                  detailRow("Registration Date",
                      _formatDate(product.registrationDate, true), theme),
                if (product.registrationDate != null)
                  detailRow(
                      "Bill Date", _formatDate(product.billDate, false), theme),
                if (product.firstOwner != null)
                  detailRow(
                      "Current Ownership Number", product.firstOwner!, theme),
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
                      _formatDate(product.insuranceValidTill, false), theme),
                detailRow("Warranty Available",
                    product.warrantyLimit != null ? "Yes" : "No", theme),
                if (product.warrantyLimit?.isNotEmpty ?? false)
                  detailRow("Warranty Limit", product.warrantyLimit!, theme),
                detailRow("Invoice Available",
                    product.invoiceAvailable != null ? "Yes" : "No", theme),
                detailRow("NOC Available",
                    product.nocAvailable != null ? "Yes" : "No", theme),
                if (product.batteryCondition != null)
                  detailRow(
                      "Battery Condition", product.batteryCondition!, theme),
                if (product.tyreCondition != null)
                  detailRow("Tyre Condition", product.tyreCondition!, theme),
                if (product.additionalDetails.isNotEmpty)
                  detailRow(
                      "Additional Details", product.additionalDetails, theme),
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

  String _formatDate(DateTime? date, bool selectOnlyMonthYear) {
    if (date == null) return "-";
    final String displayFormat =
        selectOnlyMonthYear ? 'MMMM yyyy' : 'MMMM dd yyyy';
    return DateFormat(displayFormat).format(date);
  }
}

//  const TextStyle(fontWeight: FontWeight.w600)
