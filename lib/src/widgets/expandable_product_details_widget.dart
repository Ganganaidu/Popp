import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/product.dart';
import '../utils/product_utils.dart';

class ExpandableProductDetails extends StatefulWidget {
  final Map<String, dynamic> productJson;

  /// When false, City / Area / State rows are suppressed because the highlights
  /// row above already shows the location card.
  final bool showLocationDetails;

  const ExpandableProductDetails({
    super.key,
    required this.productJson,
    this.showLocationDetails = true,
  });

  @override
  State<ExpandableProductDetails> createState() =>
      _ExpandableProductDetailsState();
}

class _ExpandableProductDetailsState extends State<ExpandableProductDetails>
    with SingleTickerProviderStateMixin {
  bool isExpanded = true;

  static const int _collapseThreshold = 5;

  @override
  Widget build(BuildContext context) {
    final product =
        Product.fromJson(widget.productJson, widget.productJson["id"]);
    final theme = Theme.of(context).textTheme;

    final expandableRows = <Widget>[
      // if (product.kmDriven?.isNotEmpty ?? false)
      //   detailRow("KM Driven", product.kmDriven!, theme),
      if (product.registrationDate != null)
        detailRow("Registration Date",
            _formatDate(product.registrationDate, true), theme),
      if (product.productAging?.isNotEmpty ?? false)
        detailRow("Product Aging", product.productAging!, theme),
      if (product.productSize?.isNotEmpty ?? false)
        detailRow("Product Size", product.productSize!, theme),
      if (product.productCondition?.isNotEmpty ?? false)
        detailRow("Product Condition", product.productCondition!, theme),
      if (product.insuranceAvailable != null)
        detailRow(
            "Insurance Available", product.insuranceAvailable!, theme),
      if (product.insuranceValidTill != null)
        detailRow("Insurance valid till",
            _formatDate(product.insuranceValidTill, false), theme),
      if (product.warrantyLimit?.isNotEmpty ?? false) ...[
        detailRow("Warranty Available", "Yes", theme),
        detailRow("Remaining Warranty", product.warrantyLimit!, theme),
      ],
      if (product.warrantyValidTill != null)
        detailRow("Warranty Valid Till",
            _formatDate(product.warrantyValidTill, true), theme),
      if (product.isBillAvailable != null &&
          product.isBillAvailable == true)
        detailRow("Bill Available",
            product.isBillAvailable == true ? 'Yes' : 'No', theme),
      if (product.billDate != null)
        detailRow(
            "Purchase Date", _formatDate(product.billDate, true), theme),
      if (product.invoiceAvailable != null)
        detailRow("Invoice Available", product.invoiceAvailable!, theme),
      if (product.category.contains(ProductUtils.premiumBikes) &&
          product.nocAvailable != null)
        detailRow("NOC Available", product.nocAvailable!, theme),
      if (product.batteryCondition != null)
        detailRow("Battery Condition", product.batteryCondition!, theme),
      if (product.tyreCondition != null)
        detailRow("Tyre Condition", product.tyreCondition!, theme),
      // if (product.additionalDetails.isNotEmpty)
      //   detailRow(
      //       "Additional Details", product.additionalDetails, theme),
    ];

    final showToggle = expandableRows.length > _collapseThreshold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Always Visible Important Fields
        // detailRow("Features", product.additionalDetails, theme),
        if (product.isProductBikeSpecific == true) ...[
          if (product.bikeBrandName?.isNotEmpty ?? false)
            detailRow("Bike Brand", product.bikeBrandName!, theme),
          if (product.bikeModelName?.isNotEmpty ?? false)
            detailRow("Bike Model", product.bikeModelName!, theme),
          if (product.bikeMfgDate != null)
            detailRow(
                "Bike MFG Date", _formatDate(product.bikeMfgDate, true), theme),
        ],
        if (product.firstOwner != null)
          detailRow("Current Ownership Number", product.firstOwner!, theme),
        if (widget.showLocationDetails) ...[
          if (product.city.isNotEmpty) detailRow("City", product.city, theme),
          if (product.area.isNotEmpty) detailRow("Area", product.area, theme),
          if (product.state.isNotEmpty)
            detailRow("State", product.state, theme),
        ],

        const SizedBox(height: 8),

        // Expandable Section — only collapsible when there's enough content
        // to be worth hiding; otherwise just show everything flat.
        if (showToggle)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            child: ConstrainedBox(
              constraints: isExpanded
                  ? const BoxConstraints()
                  : const BoxConstraints(maxHeight: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: expandableRows,
              ),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: expandableRows,
          ),

        if (showToggle) ...[
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
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                isExpanded ? "Show Less" : "Show More",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget detailRow(String title, String value, TextTheme theme) {
    final isRegistrationPlace =
        title.toLowerCase().contains('registration place');
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14)),
          Expanded(
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
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  )
                : Text(
                    value.isEmpty ? "-" : value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date, bool selectOnlyMonthYear) {
    if (date == null) return "-";
    final String displayFormat =
        selectOnlyMonthYear ? 'MMMM yyyy' : 'd MMM yyyy';
    return DateFormat(displayFormat).format(date);
  }
}
