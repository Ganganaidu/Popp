import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:poppflutter/src/utils/build_extensions.dart';
import 'package:poppflutter/src/widgets/loading_overlay.dart';
import 'package:uuid/uuid.dart';

import '../../firebase/firebase_save_prodcuts_api.dart';
import '../../gallery/pic_image_gallery.dart';
import '../../models/category.dart';
import '../../widgets/custom_dropdown_field.dart';
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
  State<SellerBikeDetailsForm> createState() => _SellerBikeDetailsFormState();
}

class _SellerBikeDetailsFormState extends State<SellerBikeDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedManufactureDate;
  String? _areYouFirstOwner;
  String? _invoiceAvailable;
  String? _nocAvailable;
  String? _insuranceAvailable;
  final List<File> _images = [];
  var productId = const Uuid().v4();
  bool _isLoading = false;

  void _submitForm() async {
    var userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login before and try again')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show progress indicator
      });

      final uploadedImageUrls = uploadMultipleImages(_images, productId);
      final formData = {
        'userId': userId,
        'productId': productId,
        'categoryId': catList[0].categoryId,
        'categoryName': catList[0].name,
        'sellerName': widget.sellerNameController.text,
        'contactNumber':
            '${widget.selectedCountryCode} ${widget.sellerContactController.text}',
        'brand': widget.selectedBrand,
        'modelName': widget.modelNameController.text,
        'state': widget.selectedState,
        'city': widget.cityController.text,
        'kmDriven': widget.kmDrivenController?.text,
        'price': widget.priceController?.text,
        'expectedPrice': widget.priceController?.text,
        'additionalDetails': widget.additionalDetailsController?.text,
        'firstOwner': _areYouFirstOwner,
        'invoiceAvailable': _invoiceAvailable,
        'nocAvailable': _nocAvailable,
        'insuranceAvailable': _insuranceAvailable,
        'insuranceType': widget.insuranceType,
        'imageUrls': uploadedImageUrls,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final success = await saveCategoryProducts(
          categoryId: catList[0].categoryId,
          categoryName: catList[0].name,
          products: formData);

      // Crucial check: Ensure the widget is still mounted before using context
      if (!mounted) return;

      if (success) {
        setState(() {
          _isLoading = false; // Hide progress indicator
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bike listed successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to list bike.')),
        );
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
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: widget.modelNameController,
                  decoration: context.inputDecoration(
                      "Model Name", "e.g. TRIUMPH Tiger 1200"),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: MonthYearPicker(
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
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: MonthYearPicker(
                  label: "Registration Date",
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
                child: CustomDropdownField(
                  label: 'Are you the first owner?',
                  labelDesc: "Tap to select",
                  value: _areYouFirstOwner,
                  options: yesNoNA,
                  onChanged: (val) => setState(() => _areYouFirstOwner = val),
                  validator: (val) =>
                      val == null ? 'Please select ownership status' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CustomDropdownField(
                  label: 'Invoice available?',
                  labelDesc: "Tap to select",
                  value: _invoiceAvailable,
                  options: yesNoNA,
                  onChanged: (val) => setState(() => _invoiceAvailable = val),
                  validator: (val) =>
                      val == null ? 'Please select Invoice availability' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CustomDropdownField(
                  label: 'NOC available?',
                  labelDesc: "Tap to select",
                  value: _nocAvailable,
                  options: yesNoNA,
                  onChanged: (val) => setState(() => _nocAvailable = val),
                  validator: (val) =>
                      val == null ? 'Please select NOC status' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: widget.kmDrivenController,
                  decoration: context.inputDecoration(
                      "KM Driven", "Enter kilometers driven"),
                  validator: (val) => val!.isEmpty ? "Required" : null,
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text("Submit Listing"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
