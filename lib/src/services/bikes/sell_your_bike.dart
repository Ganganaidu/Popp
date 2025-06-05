import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:poppflutter/src/utils/build_extensions.dart';
import 'package:poppflutter/src/widgets/loading_overlay.dart';

import '../../firebase/firebase_save_prodcuts_api.dart';
import '../../models/pop_category.dart';
import '../../models/product.dart';
import '../../widgets/custom_dropdown_form_field.dart';
import '../../widgets/image_picker_selection.dart';
import '../../widgets/month_year_picker.dart';
import '../models/bike_form_data.dart';

class SellYourBike extends StatefulWidget {
  const SellYourBike({super.key});

  @override
  State<SellYourBike> createState() => _SellYourBikeState();
}

class _SellYourBikeState extends State<SellYourBike>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final FirebaseProductsService _productsService = FirebaseProductsService();

  final ScrollController _scrollController = ScrollController();
  late final ValueNotifier<bool> _isCollapsedNotifier;

  final TextEditingController sellerNameController = TextEditingController();
  final TextEditingController sellerContactController = TextEditingController();
  final TextEditingController modelNameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController kmDrivenController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController additionalDetailsController =
      TextEditingController();

  String selectedCountryCode = "+91";
  String? selectedBrand;
  String? selectedState;
  String? _areYouFirstOwner;
  String? _invoiceAvailable;
  String? _nocAvailable;
  String? _insuranceAvailable;
  String? _insuranceType;
  DateTime? _selectedManufactureDate;
  DateTime? _selectedRegistrationDate;
  bool _isLoading = false;

  final double _bannerHeight = 40.0;
  final List<File> _images = [];

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

  Future<void> _handleLoading(bool isLoading) async {
    if (mounted) {
      setState(() {
        _isLoading = isLoading;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      Product newProduct = Product(
        categoryId: catList[0].categoryId,
        categoryName: catList[0].name,
        subCategoryName: catList[0].name,
        sellerName: sellerNameController.text,
        sellerContactNumber:
            '$selectedCountryCode ${sellerContactController.text}',
        brandName: selectedBrand ?? "",
        modelName: modelNameController.text,
        state: selectedState ?? "",
        city: cityController.text,
        kmDriven: kmDrivenController.text,
        expectedPrice: priceController.text,
        additionalDetails: additionalDetailsController.text,
        firstOwner: _areYouFirstOwner,
        invoiceAvailable: _invoiceAvailable,
        nocAvailable: _nocAvailable,
        insuranceAvailable: _insuranceAvailable,
        insuranceType: _insuranceType ?? "",
        registrationDate: _selectedRegistrationDate,
        registrationPlace: "",
        mfgDate: _selectedManufactureDate,
        createdAt: FieldValue.serverTimestamp(),
      );

      bool success = await _productsService.submitProductForm(
        context: context,
        product: newProduct,
        images: _images,
        onLoading: _handleLoading,
      );

      if (success) {
        _formKey.currentState?.reset();
        sellerNameController.clear();
        sellerContactController.clear();
        modelNameController.clear();
        cityController.clear();
        kmDrivenController.clear();
        priceController.clear();
        additionalDetailsController.clear();
        setState(() {
          _images.clear();
          selectedBrand = null;
          selectedState = null;
          _areYouFirstOwner = null;
          _invoiceAvailable = null;
          _nocAvailable = null;
          _insuranceAvailable = null;
          _insuranceType = null;
          _selectedManufactureDate = null;
          _selectedRegistrationDate = null;
        });
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
    }
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
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            _buildAnimatedBanner(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: sellerNameController,
                          decoration: context.inputDecoration(
                              "Seller Name", "Enter your full name"),
                          validator: (val) => val!.isEmpty ? "Required" : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            DropdownButton<String>(
                              value: selectedCountryCode,
                              items: countryCodes
                                  .map((code) => DropdownMenuItem(
                                      value: code, child: Text(code)))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => selectedCountryCode = val!),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: sellerContactController,
                                decoration: context.inputDecoration(
                                    "Contact Number", "Enter phone number"),
                                validator: (val) =>
                                    val!.isEmpty ? "Required" : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: selectedBrand,
                          decoration: context.inputDecoration(
                              "Brand Name", "Choose brand"),
                          items: bikeBrands
                              .map((b) =>
                                  DropdownMenuItem(value: b, child: Text(b)))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => selectedBrand = val),
                          validator: (val) => val == null ? "Required" : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: modelNameController,
                          decoration: context.inputDecoration(
                              "Model Name", "e.g. TRIUMPH Tiger 1200"),
                          validator: (val) => val!.isEmpty ? "Required" : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: MonthYearPicker(
                          enable: true,
                          label: "Manufacture Date",
                          hint: "Select month and year",
                          selectedDate: _selectedManufactureDate,
                          onDateSelected: (date) =>
                              setState(() => _selectedManufactureDate = date),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: MonthYearPicker(
                          enable: true,
                          label: "Registration Date",
                          hint: "Select month and year",
                          selectedDate: _selectedRegistrationDate,
                          onDateSelected: (date) =>
                              setState(() => _selectedRegistrationDate = date),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: selectedState,
                          decoration: context.inputDecoration(
                              "State", "Select your state"),
                          items: stateNames
                              .map((state) => DropdownMenuItem(
                                  value: state, child: Text(state)))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => selectedState = val),
                          validator: (val) => val == null ? "Required" : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: cityController,
                          decoration: context.inputDecoration(
                              "City", "Enter city name"),
                          validator: (val) => val!.isEmpty ? "Required" : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomDropdownFormField(
                          label: 'Are you the first owner?',
                          hint: "Tap to select",
                          value: _areYouFirstOwner,
                          items: yesNoNA
                              .map((state) => DropdownMenuItem(
                                  value: state, child: Text(state)))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _areYouFirstOwner = val),
                          validator: (val) => val == null
                              ? 'Please select ownership status'
                              : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomDropdownFormField(
                          label: 'Invoice available?',
                          hint: "Tap to select",
                          value: _invoiceAvailable,
                          items: yesNoNA
                              .map((state) => DropdownMenuItem(
                                  value: state, child: Text(state)))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _invoiceAvailable = val),
                          validator: (val) => val == null
                              ? 'Please select Invoice availability'
                              : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomDropdownFormField(
                          label: 'NOC available?',
                          hint: "Tap to select",
                          value: _nocAvailable,
                          items: yesNoNA
                              .map((state) => DropdownMenuItem(
                                  value: state, child: Text(state)))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _nocAvailable = val),
                          validator: (val) =>
                              val == null ? 'Please select NOC status' : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: kmDrivenController,
                          decoration: context.inputDecoration(
                              "KM Driven", "Enter kilometers driven"),
                          validator: (val) => val!.isEmpty ? "Required" : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: priceController,
                          decoration: context.inputDecoration(
                              "Expected Price", "Enter expected price"),
                          validator: (val) => val!.isEmpty ? "Required" : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: additionalDetailsController,
                          decoration: context.inputDecoration(
                              "Additional Details", "Any extra info..."),
                          maxLines: 3,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ImagePickerSection(
                          images: _images,
                          onImagesChanged: (images) => setState(() {
                            _images.clear();
                            _images.addAll(images);
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isLoading ? Colors.grey : Theme.of(context).primaryColor,
                disabledBackgroundColor: Colors.grey,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isLoading
                    ? const Row(
                        key: ValueKey('loading'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text("Submitting...",
                              style: TextStyle(color: Colors.white)),
                        ],
                      )
                    : const Text(
                        "Submit",
                        key: ValueKey('submit'),
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
