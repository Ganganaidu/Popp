import 'package:flutter/material.dart';
import 'package:poppflutter/src/services/accessories/seller_accessories_details_form.dart';

class SellYourAccessories extends StatefulWidget {
  const SellYourAccessories({super.key});

  @override
  State<SellYourAccessories> createState() => _SellYourAccessoriesState();
}

class _SellYourAccessoriesState extends State<SellYourAccessories>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<SellerAccessoriesDetailsFormState> _sellerFormKey =
      GlobalKey<SellerAccessoriesDetailsFormState>();

  final TextEditingController sellerNameController = TextEditingController();
  final TextEditingController sellerContactController = TextEditingController();
  final TextEditingController modelNameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  String selectedCountryCode = "+91";
  String? selectedState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sell Your Accessories')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SellerAccessoriesDetailsForm(
                  key: _sellerFormKey,
                  sellerNameController: sellerNameController,
                  sellerContactController: sellerContactController,
                  modelNameController: modelNameController,
                  cityController: cityController,
                  selectedState: selectedState,
                  selectedCountryCode: selectedCountryCode,
                  onCountryCodeChanged: (val) =>
                      setState(() => selectedCountryCode = val),
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
