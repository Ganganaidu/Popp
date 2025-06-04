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

class SellYourAccessories extends StatefulWidget {
  const SellYourAccessories({super.key});

  @override
  State<SellYourAccessories> createState() => _SellYourAccessoriesState();
}

class _SellYourAccessoriesState extends State<SellYourAccessories> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseProductsService _productsService = FirebaseProductsService();

  final TextEditingController sellerNameController = TextEditingController();
  final TextEditingController accessoriesNameController = TextEditingController();
  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController sellerContactController = TextEditingController();
  final TextEditingController modelNameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController additionalDetailsController =
      TextEditingController();
  final TextEditingController productSizeController = TextEditingController();
  final TextEditingController productAgingController = TextEditingController();
  final TextEditingController warrantyLeftController = TextEditingController();

  String selectedCountryCode = "+91";
  String? selectedState;

  DateTime? _selectedManufactureDate;
  DateTime? _selectedBillDate;
  String? _productCondition;
  Category? selectedCategory;
  String? selectedSubcategory;
  String? selectedBikeBrand;
  Function(String?)? onBrandChanged;
  bool isBikeSpecific = false;
  bool isBillAvailable = false;
  bool isWarrantyAvailable = false;

  final List<File> _images = [];
  var productId = const Uuid().v4();
  bool _isLoading = false;

  Future<void> _handleLoading(bool isLoading) async {
    if (mounted) {
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
        sellerContactNumber:
        '$selectedCountryCode ${sellerContactController.text}',
        sellerName: sellerNameController.text,
        subCategoryName: selectedSubcategory,
        modelName: accessoriesNameController.text,
        isProductBikeSpecific: isBikeSpecific,
        brandName: brandNameController.text,
        bikeBrandName: selectedBikeBrand ?? "",
        bikeModelName: modelNameController.text,
        bikeMfgDate: _selectedManufactureDate,
        state: selectedState ?? "",
        city: cityController.text,
        productSize: productSizeController.text,
        productCondition: _productCondition,
        billDate: _selectedBillDate,
        productAging: productAgingController.text,
        warrantyLimit: warrantyLeftController.text,
        expectedPrice: priceController.text,
        additionalDetails: additionalDetailsController.text,
        createdAt: FieldValue.serverTimestamp(),
      );

      AppLogger.d("Product data to be submitted: ${newProduct.toJson()}");

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
        priceController.clear();
        additionalDetailsController.clear();
        productAgingController.clear();
        productSizeController.clear();
        warrantyLeftController.clear();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Sell Your Accessories')),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                buildPaddedField(TextFormField(
                  controller: sellerNameController,
                  decoration: context.inputDecoration(
                      "Seller Name", "Enter your full name"),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                )),
                buildPaddedField(Row(
                  children: [
                    DropdownButton<String>(
                      value: selectedCountryCode,
                      items: countryCodes
                          .map((code) =>
                              DropdownMenuItem(value: code, child: Text(code)))
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
                        validator: (val) => val!.isEmpty ? "Required" : null,
                      ),
                    ),
                  ],
                )),
                buildPaddedField(CategorySelector(
                  onCategoryChanged: (cat) => selectedCategory = cat,
                  onSubcategoryChanged: (sub) => selectedSubcategory = sub,
                )),
                buildPaddedField(TextFormField(
                  controller: accessoriesNameController,
                  decoration: context.inputDecoration(
                      "Accessories Name", "Enter your Accessories name"),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                )),
                buildPaddedField(TextFormField(
                  controller: accessoriesNameController,
                  decoration: context.inputDecoration(
                      "Brand Name", "Enter your Brand name"),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                )),
                buildPaddedField(SwitchListTile(
                  title: const Text("Is your product bike specific?"),
                  value: isBikeSpecific,
                  activeColor: Colors.orange,
                  onChanged: (val) => setState(() => isBikeSpecific = val),
                )),
                buildPaddedField(CustomDropdownFormField<String>(
                  enabled: isBikeSpecific,
                  value: selectedBikeBrand,
                  label: "Bike Brand Name",
                  hint: "Choose brand",
                  items: bikeBrands
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedBikeBrand = val),
                  validator: (val) =>
                      isBikeSpecific && val == null ? "Required" : null,
                )),
                buildPaddedField(TextFormField(
                  enabled: isBikeSpecific,
                  controller: modelNameController,
                  decoration: context.inputDecoration(
                      "Bike Model Name", "e.g. TRIUMPH Tiger 1200"),
                  validator: (val) =>
                      isBikeSpecific && val == null ? "Required" : null,
                )),
                buildPaddedField(MonthYearPicker(
                  enable: isBikeSpecific,
                  label: "Bike Manufacture Date",
                  hint: "Select month and year",
                  selectedDate: _selectedManufactureDate,
                  onDateSelected: (date) =>
                      setState(() => _selectedManufactureDate = date),
                )),
                buildPaddedField(CustomDropdownFormField<String>(
                  label: "State",
                  hint: "Select your state",
                  value: selectedState,
                  items: stateNames
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedState = val),
                  validator: (val) => val == null ? "Required" : null,
                )),
                buildPaddedField(TextFormField(
                  controller: cityController,
                  decoration:
                      context.inputDecoration("City", "Enter city name"),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                )),
                buildPaddedField(TextFormField(
                  controller: productSizeController,
                  decoration:
                      context.inputDecoration("Product size", "If applicable"),
                )),
                buildPaddedField(CustomDropdownFormField<String>(
                  label: 'Product condition',
                  hint: "Tap to select",
                  value: _productCondition,
                  items: productConditionList
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _productCondition = val),
                  validator: (val) =>
                      val == null ? 'Please select Product condition' : null,
                )),
                buildPaddedField(SwitchListTile(
                  title: const Text("Bill available?"),
                  activeColor: Colors.orange,
                  value: isBillAvailable,
                  onChanged: (val) => setState(() => isBillAvailable = val),
                )),
                buildPaddedField(MonthYearPicker(
                  enable: isBillAvailable,
                  label: "Bill Date",
                  hint: "Select month and year",
                  selectedDate: _selectedBillDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedBillDate = date;
                      final age = calculateAge(_selectedBillDate);
                      productAgingController.text =
                          "${age['years']} years and ${age['months']} months";
                    });
                  },
                )),
                buildPaddedField(TextFormField(
                  readOnly: true,
                  enabled: isBillAvailable,
                  controller: productAgingController,
                  decoration: context.inputDecoration(
                      "Product aging", "Product age so far"),
                )),
                buildPaddedField(SwitchListTile(
                  title: const Text("Warranty available?"),
                  activeColor: Colors.orange,
                  value: isWarrantyAvailable,
                  onChanged: (val) => setState(() => isWarrantyAvailable = val),
                )),
                buildPaddedField(TextFormField(
                  enabled: isWarrantyAvailable,
                  controller: warrantyLeftController,
                  decoration: context.inputDecoration(
                      "Warranty limit", "How many months/years warranty left?"),
                )),
                buildPaddedField(TextFormField(
                  controller: priceController,
                  decoration: context.inputDecoration(
                      "Expected Price", "Enter expected price"),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                )),
                buildPaddedField(TextFormField(
                  controller: additionalDetailsController,
                  decoration: context.inputDecoration(
                      "Additional Details", "Any extra info..."),
                  maxLines: 3,
                )),
                buildPaddedField(ImagePickerSection(
                  images: _images,
                  onImagesChanged: (images) => setState(() {
                    _images.clear();
                    _images.addAll(images);
                  }),
                )),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: submitForm,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
            child: const Text("Submit"),
          ),
        ),
      ),
    );
  }

  Widget buildPaddedField(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}
