import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:poppflutter/src/utils/build_extensions.dart';
import 'package:poppflutter/src/widgets/loading_overlay.dart';

import '../../firebase/firebase_save_prodcuts_api.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../widgets/custom_dropdown_form_field.dart';
import '../../widgets/image_picker_selection.dart';
import '../../widgets/month_year_picker.dart';
import '../models/bike_form_data.dart';

class SellerBikeDetailsForm extends StatefulWidget {
  final TextEditingController sellerNameController;
  final TextEditingController sellerContactController;
  final TextEditingController modelNameController;
  final TextEditingController cityController;
  final String? selectedBrand;
  final String selectedCountryCode;
  final String? selectedState;
  final Function(String) onCountryCodeChanged;
  final Function(String?) onBrandChanged;
  final Function(String?) onStateChanged;
  final TextEditingController? kmDrivenController;
  final TextEditingController? priceController;
  final TextEditingController? additionalDetailsController;
  final String? insuranceType;
  final Function(String?)? onInvoiceChanged;
  final Function(String?)? onNocChanged;
  final Function(String?)? onInsuranceChanged;
  final Function(String?)? onInsuranceTypeChanged;

  const SellerBikeDetailsForm(
      {super.key,
      required this.sellerNameController,
      required this.sellerContactController,
      required this.modelNameController,
      required this.cityController,
      required this.onStateChanged,
      required this.selectedBrand,
      required this.selectedCountryCode,
      required this.onCountryCodeChanged,
      required this.onBrandChanged,
      this.kmDrivenController,
      this.priceController,
      this.additionalDetailsController,
      this.insuranceType,
      this.onInvoiceChanged,
      this.onNocChanged,
      this.onInsuranceChanged,
      this.onInsuranceTypeChanged,
      this.selectedState});

  @override
  State<SellerBikeDetailsForm> createState() => SellerBikeDetailsFormState();
}

class SellerBikeDetailsFormState extends State<SellerBikeDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseProductsService _productsService = FirebaseProductsService();

  DateTime? _selectedManufactureDate;
  DateTime? _selectedRegistrationDate;
  String? _areYouFirstOwner;
  String? _invoiceAvailable;
  String? _nocAvailable;
  String? _insuranceAvailable;
  bool _isLoading = false;

  final List<File> _images = [];

// Function to manage loading state (passed to submitProductForm)
  Future<void> _handleLoading(bool isLoading) async {
    // Using async here just to match the signature, though not strictly necessary
    // if the setState call is synchronous.
    if (mounted) {
      // Check if the widget is still in the tree
      setState(() {
        _isLoading = isLoading;
      });
    }
  }

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      Product newProduct = Product(
        categoryId: catList[0].categoryId,
        categoryName: catList[0].name,
        subCategoryName: '',
        sellerName: widget.sellerNameController.text,
        sellerContactNumber:
            '${widget.selectedCountryCode} ${widget.sellerContactController.text}',
        brandName: widget.selectedBrand ?? "",
        modelName: widget.modelNameController.text,
        state: widget.selectedState ?? "",
        city: widget.cityController.text,
        kmDriven: widget.kmDrivenController?.text ?? "",
        expectedPrice: widget.priceController?.text ?? "",
        additionalDetails: widget.additionalDetailsController?.text ?? "",
        firstOwner: _areYouFirstOwner,
        invoiceAvailable: _invoiceAvailable,
        nocAvailable: _nocAvailable,
        insuranceAvailable: _insuranceAvailable,
        insuranceType: widget.insuranceType ?? "",
        registrationDate: _selectedRegistrationDate,
        registrationPlace: "",
        mfgDate: _selectedManufactureDate,
        createdAt: FieldValue
            .serverTimestamp(), // Default for a new product, or based on user input
      );
      // Call the service method
      bool success = await _productsService.submitProductForm(
        context: context,
        product: newProduct,
        images: _images,
        onLoading: _handleLoading, // Pass the loading handler
      );
      if (success) {
        _formKey.currentState?.reset();
        widget.sellerNameController.clear();
        widget.sellerContactController.clear();
        widget.modelNameController.clear();
        widget.cityController.clear();
        widget.kmDrivenController?.clear();
        widget.priceController?.clear();
        widget.additionalDetailsController?.clear();
        setState(() {
          _images.clear();
        });
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: TextFormField(
                  controller: widget.sellerNameController,
                  decoration: context.inputDecoration(
                      "Seller Name", "Enter your full name"),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    DropdownButton<String>(
                      value: widget.selectedCountryCode,
                      items: countryCodes
                          .map((code) =>
                              DropdownMenuItem(value: code, child: Text(code)))
                          .toList(),
                      onChanged: (val) => widget.onCountryCodeChanged(val!),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: widget.sellerContactController,
                        decoration: context.inputDecoration(
                            "Contact Number", "Enter phone number"),
                        validator: (val) => val!.isEmpty ? "Required" : null,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: DropdownButtonFormField<String>(
                  value: widget.selectedBrand,
                  decoration:
                      context.inputDecoration("Brand Name", "Choose brand"),
                  items: bikeBrands
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: widget.onBrandChanged,
                  validator: (val) => val == null ? "Required" : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: TextFormField(
                  controller: widget.modelNameController,
                  decoration: context.inputDecoration(
                      "Model Name", "e.g. TRIUMPH Tiger 1200"),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: MonthYearPicker(
                  enable: true,
                  label: "Manufacture Date",
                  hint: "Select month and year",
                  selectedDate: _selectedManufactureDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedManufactureDate = date;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: MonthYearPicker(
                  enable: true,
                  label: "Registration Date",
                  hint: "Select month and year",
                  selectedDate: _selectedRegistrationDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedRegistrationDate = date;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: DropdownButtonFormField<String>(
                  value: widget.selectedState,
                  decoration:
                      context.inputDecoration("State", "Select your state"),
                  items: stateNames
                      .map((state) =>
                          DropdownMenuItem(value: state, child: Text(state)))
                      .toList(),
                  onChanged: widget.onStateChanged,
                  validator: (val) => val == null ? "Required" : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: TextFormField(
                  controller: widget.cityController,
                  decoration:
                      context.inputDecoration("City", "Enter city name"),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: CustomDropdownFormField(
                  label: 'Are you the first owner?',
                  hint: "Tap to select",
                  value: _areYouFirstOwner,
                  items: yesNoNA
                      .map((state) =>
                          DropdownMenuItem(value: state, child: Text(state)))
                      .toList(),
                  onChanged: (val) => setState(() => _areYouFirstOwner = val),
                  validator: (val) =>
                      val == null ? 'Please select ownership status' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: CustomDropdownFormField(
                  label: 'Invoice available?',
                  hint: "Tap to select",
                  value: _invoiceAvailable,
                  items: yesNoNA
                      .map((state) =>
                          DropdownMenuItem(value: state, child: Text(state)))
                      .toList(),
                  onChanged: (val) => setState(() => _invoiceAvailable = val),
                  validator: (val) =>
                      val == null ? 'Please select Invoice availability' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: CustomDropdownFormField(
                  label: 'NOC available?',
                  hint: "Tap to select",
                  value: _nocAvailable,
                  items: yesNoNA
                      .map((state) =>
                          DropdownMenuItem(value: state, child: Text(state)))
                      .toList(),
                  onChanged: (val) => setState(() => _nocAvailable = val),
                  validator: (val) =>
                      val == null ? 'Please select NOC status' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: TextFormField(
                  controller: widget.kmDrivenController,
                  decoration: context.inputDecoration(
                      "KM Driven", "Enter kilometers driven"),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: TextFormField(
                  controller: widget.priceController,
                  decoration: context.inputDecoration(
                      "Expected Price", "Enter expected price"),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: TextFormField(
                  controller: widget.additionalDetailsController,
                  decoration: context.inputDecoration(
                      "Additional Details", "Any extra info..."),
                  maxLines: 3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: ImagePickerSection(
                  images: _images,
                  onImagesChanged: (images) {
                    setState(() {
                      _images.clear();
                      _images.addAll(images);
                    });
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
