import 'package:flutter/material.dart';
import 'package:poppflutter/src/services/bikes/seller_bike_details_form.dart';

class SellYourBike extends StatefulWidget {
  const SellYourBike({super.key});

  @override
  State<SellYourBike> createState() => _SellYourBikeState();
}

class _SellYourBikeState extends State<SellYourBike>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<SellerBikeDetailsFormState> _sellerFormKey =
      GlobalKey<SellerBikeDetailsFormState>();

  final ScrollController _scrollController = ScrollController();
  late final ValueNotifier<bool> _isCollapsedNotifier;

  final TextEditingController sellerNameController = TextEditingController();
  final TextEditingController sellerContactController = TextEditingController();
  final TextEditingController modelNameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  String selectedCountryCode = "+91";
  String? selectedBrand;
  String? selectedState;

  final double _bannerHeight = 40.0;

  @override
  void initState() {
    super.initState();
    _isCollapsedNotifier = ValueNotifier(false);

    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      if (offset > 50 && !_isCollapsedNotifier.value) {
        _isCollapsedNotifier.value = true;
      } else if (offset <= 50 && _isCollapsedNotifier.value) {
        _isCollapsedNotifier.value = false;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _isCollapsedNotifier.dispose();
    super.dispose();
  }

  Widget _buildAnimatedBanner() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isCollapsedNotifier,
      builder: (context, isCollapsed, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isCollapsed ? 0 : _bannerHeight,
          width: double.infinity,
          color: Colors.red[400],
          alignment: Alignment.center,
          child: isCollapsed
              ? null
              : const Text(
                  "Strictly Only 35+ HP/NM Powered Bikes",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sell Your Bike')),
      body: Column(
        children: [
          _buildAnimatedBanner(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SellerBikeDetailsForm(
                  key: _sellerFormKey,
                  sellerNameController: sellerNameController,
                  sellerContactController: sellerContactController,
                  modelNameController: modelNameController,
                  cityController: cityController,
                  selectedBrand: selectedBrand,
                  selectedState: selectedState,
                  selectedCountryCode: selectedCountryCode,
                  onCountryCodeChanged: (val) =>
                      setState(() => selectedCountryCode = val),
                  onBrandChanged: (val) => setState(() => selectedBrand = val),
                  onStateChanged: (val) => setState(() => selectedState = val),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              _sellerFormKey.currentState?.submitForm();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text("Submit"),
          ),
        ),
      ),
    );
  }
}
