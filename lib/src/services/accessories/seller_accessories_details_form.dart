import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:poppflutter/src/utils/app_loger.dart';
import 'package:poppflutter/src/utils/build_extensions.dart';
import 'package:poppflutter/src/widgets/category_selector.dart';
import 'package:poppflutter/src/widgets/loading_overlay.dart';
import 'package:uuid/uuid.dart';

import '../../firebase/firebase_save_prodcuts_api.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../widgets/custom_dropdown_form_field.dart';
import '../../widgets/image_picker_selection.dart';
import '../../widgets/month_year_picker.dart';
import '../models/bike_form_data.dart';

class SellerAccessoriesDetailsForm extends StatefulWidget {
  final TextEditingController sellerNameController;
  final TextEditingController sellerContactController;
  final TextEditingController modelNameController;
  final TextEditingController cityController;
  final String selectedCountryCode;
  final String? selectedState;
  final Function(String) onCountryCodeChanged;
  final Function(String?) onStateChanged;
  final TextEditingController? priceController;
  final TextEditingController? additionalDetailsController;

  const SellerAccessoriesDetailsForm(
      {super.key,
      required this.sellerNameController,
      required this.sellerContactController,
      required this.modelNameController,
      required this.cityController,
      required this.onStateChanged,
      required this.selectedCountryCode,
      required this.onCountryCodeChanged,
      this.priceController,
      this.additionalDetailsController,
      this.selectedState});

  @override
  State<SellerAccessoriesDetailsForm> createState() =>
      SellerAccessoriesDetailsFormState();
}

class SellerAccessoriesDetailsFormState
    extends State<SellerAccessoriesDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseProductsService _productsService = FirebaseProductsService();

  DateTime? _selectedManufactureDate;
  DateTime? _selectedBillDate;
  String? _productCondition;
  Category? selectedCategory;
  String? selectedSubcategory;
  String? selectedBrand;
  Function(String?)? onBrandChanged;
  bool isBikeSpecific = false;
  bool isBillAvailable = false;
  bool isWarrantyAvailable = false;
  TextEditingController? productSizeController;
  TextEditingController? productAgingController;
  TextEditingController? warrantyLeftController;

  final List<File> _images = [];
  var productId = const Uuid().v4();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    productAgingController = TextEditingController();
    productSizeController = TextEditingController();
    warrantyLeftController = TextEditingController();
  }

  @override
  void dispose() {
    productAgingController?.dispose();
    productSizeController?.dispose();
    // Dispose other controllers created in this state
    super.dispose();
  }

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
        id: productId,
        categoryId: selectedCategory?.categoryId ?? "",
        categoryName: selectedCategory?.name ?? "",
        subCategoryName: selectedSubcategory,
        sellerName: widget.sellerNameController.text,
        sellerContactNumber:
            '${widget.selectedCountryCode} ${widget.sellerContactController.text}',
        brandName: selectedBrand ?? "",
        modelName: widget.modelNameController.text,
        state: widget.selectedState ?? "",
        city: widget.cityController.text,
        expectedPrice: widget.priceController?.text ?? "",
        additionalDetails: widget.additionalDetailsController?.text ?? "",
        billDate: _selectedBillDate,
        registrationPlace: "",
        mfgDate: _selectedManufactureDate,
        // Default for a new product, or based on user input
        createdAt: FieldValue.serverTimestamp(),
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
        const SnackBar(content: Text('Please fill all required fields.')),
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
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: widget.sellerNameController,
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
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CategorySelector(
                  onCategoryChanged: (cat) => selectedCategory = cat,
                  onSubcategoryChanged: (sub) => selectedSubcategory = sub,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SwitchListTile(
                  title: const Text("Is your product bike specific?"),
                  value: isBikeSpecific,
                  activeColor: Colors.orange,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey[400],
                  onChanged: (val) {
                    setState(() {
                      isBikeSpecific = val;
                      if (!val) {
                        selectedBrand = null;
                        onBrandChanged = null;
                        widget.modelNameController.clear();
                        _selectedManufactureDate = null;
                      } else {
                        // Re-assign your default or active handler when it becomes bike-specific again
                        onBrandChanged = (newValue) {
                          setState(() {
                            selectedBrand = newValue;
                          });
                        };
                      }
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CustomDropdownFormField<String>(
                  enabled: isBikeSpecific,
                  value: selectedBrand,
                  label: "Bike Brand Name",
                  hint: "Choose brand",
                  items: bikeBrands
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: onBrandChanged,
                  // This should now work
                  validator: (val) => isBikeSpecific && val == null
                      ? "Required"
                      : null, // Adjust validator
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  enabled: isBikeSpecific,
                  controller: widget.modelNameController,
                  decoration: context.inputDecoration(
                      "Bike Model Name", "e.g. TRIUMPH Tiger 1200",
                      enable: isBikeSpecific),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: MonthYearPicker(
                  enable: isBikeSpecific,
                  label: "Bike Manufacture Date",
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
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CustomDropdownFormField<String>(
                  label: "State",
                  hint: "Select your state",
                  value: widget.selectedState,
                  items: stateNames
                      .map((state) =>
                          DropdownMenuItem(value: state, child: Text(state)))
                      .toList(),
                  onChanged: widget.onStateChanged,
                  validator: (val) => val == null ? "Required" : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: widget.cityController,
                  decoration:
                      context.inputDecoration("City", "Enter city name"),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: productSizeController,
                  decoration:
                      context.inputDecoration("Product size", "If applicable"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CustomDropdownFormField(
                  label: 'Product condition',
                  hint: "Tap to select",
                  value: _productCondition,
                  items: productConditionList
                      .map((state) =>
                          DropdownMenuItem(value: state, child: Text(state)))
                      .toList(),
                  onChanged: (val) => setState(() => _productCondition = val),
                  validator: (val) =>
                      val == null ? 'Please select Product condition' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SwitchListTile(
                  title: const Text("Bill available?"),
                  activeColor: Colors.orange,
                  value: isBillAvailable,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey[400],
                  onChanged: (val) {
                    setState(() {
                      isBillAvailable = val;
                      if (!val) {
                      } else {}
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: MonthYearPicker(
                  enable: isBillAvailable,
                  label: "Bill Date",
                  hint: "Select month and year",
                  selectedDate: _selectedBillDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedBillDate = date;
                      final Map<String, int> age =
                          calculateAge(_selectedBillDate);
                      // Assuming productAgingController is initialized
                      productAgingController?.text =
                          "${age['years']} years and ${age['months']} months";
                      AppLogger.d(
                          "productAgingController updated to: ${productAgingController?.text}"); // Debug
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  readOnly: true,
                  enabled: isBillAvailable,
                  controller: productAgingController,
                  decoration: context.inputDecoration(
                      "Product aging", "Product age so far "),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SwitchListTile(
                  title: const Text("Warranty available?"),
                  activeColor: Colors.orange,
                  value: isWarrantyAvailable,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey[400],
                  onChanged: (val) {
                    setState(() {
                      isWarrantyAvailable = val;
                      if (!val) {
                      } else {}
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  enabled: isWarrantyAvailable,
                  controller: warrantyLeftController,
                  decoration: context.inputDecoration(
                      "Warranty limit", "How many months/years warranty left?"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: widget.priceController,
                  decoration: context.inputDecoration(
                      "Expected Price", "Enter expected price"),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: widget.additionalDetailsController,
                  decoration: context.inputDecoration(
                      "Additional Details", "Any extra info..."),
                  maxLines: 3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
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
