import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/month_year_picker.dart';
import '../../widgets/yes_no_radio_field.dart';
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
  final String? nocAvailable;
  final String? insuranceAvailable;
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
      this.nocAvailable,
      this.insuranceAvailable,
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
  String? _isFirstOwner;
  String? _isInvoiceAvailable;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final formData = {
        'sellerName': widget.sellerNameController.text,
        'contactNumber':
            '${widget.selectedCountryCode} ${widget.sellerContactController.text}',
        'brand': widget.selectedBrand,
        'modelName': widget.modelNameController.text,
        'city': widget.cityController.text,
        'kmDriven': widget.kmDrivenController?.text,
        'price': widget.priceController?.text,
        'additionalDetails': widget.additionalDetailsController?.text,
        'firstOwner': _isFirstOwner,
        'invoiceAvailable': _isInvoiceAvailable,
        'nocAvailable': widget.nocAvailable,
        'insuranceAvailable': widget.insuranceAvailable,
        'insuranceType': widget.insuranceType,
        'createdAt': FieldValue.serverTimestamp(),
      };

      try {
        await FirebaseFirestore.instance
            .collection('bike_listings')
            .add(formData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bike listed successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to list bike: \$e')),
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
    final List<String> countryCodes = ["+91", "+1", "+44"];
    final List<String> yesNoNA = ["YES", "NO", "N/A"];

    InputDecoration inputDecoration(String label, String hint) =>
        InputDecoration(
          labelStyle: const TextStyle(fontSize: 18),
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.5),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        );

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: widget.sellerNameController,
                decoration:
                    inputDecoration("Seller Name", "Enter your full name"),
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
                      decoration: inputDecoration(
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
                decoration: inputDecoration("Brand Name", "Choose brand"),
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
                decoration:
                    inputDecoration("Model Name", "e.g. TRIUMPH Tiger 1200"),
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
                decoration: inputDecoration("State", "Select your state"),
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
                decoration: inputDecoration("City", "Enter city name"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: YesNoRadioField(
                label: 'Are you the first owner?',
                value: _isFirstOwner,
                onChanged: (val) {
                  setState(() {
                    _isFirstOwner = val;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: YesNoRadioField(
                label: 'Invoice available ?',
                value: _isInvoiceAvailable,
                onChanged: (val) {
                  setState(() {
                    _isInvoiceAvailable = val;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: YesNoRadioField(
                label: 'NOC available ?',
                options: const ['YES', 'NO', 'N/A'],
                value: _isInvoiceAvailable,
                onChanged: (val) {
                  setState(() {
                    _isInvoiceAvailable = val;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: widget.kmDrivenController,
                decoration:
                    inputDecoration("KM Driven", "Enter kilometers driven"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: widget.priceController,
                decoration:
                    inputDecoration("Expected Price", "Enter expected price"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: widget.additionalDetailsController,
                decoration:
                    inputDecoration("Additional Details", "Any extra info..."),
                maxLines: 3,
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
    );
  }
}
