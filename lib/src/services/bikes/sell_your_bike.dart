import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:popp/src/widgets/app_dialogs.dart';
import 'package:popp/src/widgets/loading_overlay.dart';
import 'package:popp/src/widgets/title_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../api/api_url.dart';
import '../../api/firebase/firebase_api_service.dart';
import '../../models/pop_category.dart';
import '../../models/product.dart';
import '../../navigation/nav_router.dart';
import '../../search/autocomplete_search_field.dart';
import '../../utils/app_loger.dart';
import '../../utils/product_content_data.dart';
import '../../widgets/custom_dropdown_form_field.dart';
import '../../widgets/image_picker_selection.dart';
import '../../widgets/month_year_picker.dart';

class SellYourBike extends StatefulWidget {
  const SellYourBike({super.key});

  @override
  State<SellYourBike> createState() => _SellYourBikeState();
}

class _SellYourBikeState extends State<SellYourBike>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final FirebaseApiService _firebaseService = FirebaseApiService();

  final ScrollController _scrollController = ScrollController();
  late final ValueNotifier<bool> _isCollapsedNotifier;

  final TextEditingController sellerNameController = TextEditingController();
  final TextEditingController sellerContactController = TextEditingController();

  // New controllers for manual brand/model entry
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController kmDrivenController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController additionalDetailsController =
      TextEditingController();

  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  // FocusNodes for manual entry fields
  final FocusNode brandFocusNode = FocusNode();
  final FocusNode modelFocusNode = FocusNode();

  String selectedCountryCode = "+91";
  String? selectedBrand;
  String? sellerCategory;
  String? selectedModel; // To hold the selected model from dropdown
  String? selectedState;
  String? _areYouFirstOwner;
  String? _invoiceAvailable;
  String? _nocAvailable;
  String? _batteryCondition;
  String? _tyreCondition;
  DateTime? _selectedManufactureDate;
  DateTime? _selectedRegistrationDate;
  bool _isLoading = false;
  String? _insuranceAvailable;
  DateTime? _insuranceValidityTill;
  bool _termsAccepted = false;

  final double _bannerHeight = 40.0;
  final List<File> _images = [];
  var productId = const Uuid().v4();

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
    sellerNameController.dispose();
    sellerContactController.dispose();
    brandController.dispose();
    modelController.dispose();
    cityController.dispose();
    areaController.dispose();
    addressController.dispose();
    pinCodeController.dispose();
    kmDrivenController.dispose();
    priceController.dispose();
    additionalDetailsController.dispose();
    brandFocusNode.dispose();
    modelFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLoading(bool isLoading) async {
    if (mounted) {
      setState(() {
        _isLoading = isLoading;
      });
    }
  }

  void _openTermsLink() async {
    AppLogger.w("Terms link clicked");
    final uri = Uri.parse(ApiUrl.customersTermsLink);
    final launched = await launchUrl(uri);
    if (launched) {
      setState(() => _termsAccepted = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Could not open Terms & Conditions link.")),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String countryCode = Localizations.localeOf(context).countryCode ?? "IN";

      if (!_termsAccepted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept the Terms & Conditions')),
        );
        return;
      }

      // Updated logic to determine final brand and model names
      String finalBrand;
      String finalModel;

      if (selectedBrand == 'Others') {
        finalBrand = brandController.text;
        finalModel = modelController.text;
      } else {
        finalBrand = selectedBrand ?? '';
        if (selectedModel == 'Others') {
          finalModel = modelController.text;
        } else {
          finalModel = selectedModel ?? '';
        }
      }

      Product newProduct = Product(
        id: productId,
        isApproved: false,
        isSold: false,
        countryCode: countryCode,
        userId: FirebaseAuth.instance.currentUser?.uid,
        categoryId: catList[0].categoryId,
        category: catList[0].name,
        subCategory: catList[0].name,
        sellerCategory: sellerCategory ?? "Individual",
        sellerName: sellerNameController.text,
        sellerContactNumber:
            '$selectedCountryCode ${sellerContactController.text}',
        brandName: finalBrand,
        modelName: finalModel,
        state: selectedState ?? "",
        city: cityController.text,
        area: areaController.text,
        address: addressController.text,
        pinCode: pinCodeController.text,
        kmDriven: kmDrivenController.text,
        expectedPrice: priceController.text,
        price: priceController.text,
        additionalDetails: additionalDetailsController.text,
        firstOwner: _areYouFirstOwner,
        invoiceAvailable: _invoiceAvailable,
        nocAvailable: _nocAvailable,
        insuranceAvailable: _insuranceAvailable,
        insuranceValidTill: _insuranceValidityTill,
        registrationDate: _selectedRegistrationDate,
        registrationPlace: "",
        mfgDate: _selectedManufactureDate,
        createdAt: FieldValue.serverTimestamp(),
        batteryCondition: _batteryCondition,
        tyreCondition: _tyreCondition,
        searchKeywords: [
          sellerNameController.text,
          finalModel,
          addressController.text,
          kmDrivenController.text,
          priceController.text,
          catList[0].name,
          finalBrand,
          selectedState ?? "",
          _batteryCondition ?? "",
          additionalDetailsController.text,
          ...sellerNameController.text.toLowerCase().split(' '),
          ...finalModel.toLowerCase().split(' '),
          ...addressController.text.toLowerCase().split(' '),
          ...catList[0].name.toLowerCase().split(' '),
          ...finalBrand.toLowerCase().split(' '),
          ...selectedState?.toLowerCase().split(' ') ?? [],
          ...additionalDetailsController.text.toLowerCase().split(' '),
          ...kmDrivenController.text.toLowerCase().split(' '),
          ..._batteryCondition?.toLowerCase().split(' ') ?? [],
          if (_batteryCondition != null && _batteryCondition!.isNotEmpty)
            'batterycondition${_batteryCondition!.toLowerCase()}',
          ..."bikes".toLowerCase().split(' '),
          ...priceController.text.toLowerCase().split(' '),
        ],
      );

      bool success = await _firebaseService.submitProductForm(
        context: context,
        product: newProduct,
        images: _images,
        onLoading: _handleLoading,
      );

      if (success) {
        _formKey.currentState?.reset();
        sellerNameController.clear();
        sellerContactController.clear();
        brandController.clear();
        modelController.clear();
        cityController.clear();
        areaController.clear();
        addressController.clear();
        pinCodeController.clear();
        kmDrivenController.clear();
        priceController.clear();
        additionalDetailsController.clear();
        setState(() {
          _images.clear();
          selectedBrand = null;
          selectedModel = null;
          selectedState = null;
          _areYouFirstOwner = null;
          _invoiceAvailable = null;
          _nocAvailable = null;
          _batteryCondition = null;
          _tyreCondition = null;
          _insuranceValidityTill = null;
          _selectedManufactureDate = null;
          _selectedRegistrationDate = null;
          _termsAccepted = false;
        });
        if (!mounted) return;
        AppDialogs.showProductSuccessDialog(context, () {
          onMyListingScreenTap(context, true);
        }, () {
          Navigator.pushReplacementNamed(context, '/home');
        });
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
    // --- Dynamic variables for brand/model logic ---
    final bool isBrandOthers = selectedBrand == 'Others';
    final bool isModelOthers = selectedModel == 'Others';

    final modelsForBrand =
        isBrandOthers ? <String>[] : (bikeBrandModels[selectedBrand] ?? []);

    final brandListWithOthers = [...bikeBrands, 'Others'];
    final modelListWithOthers =
        modelsForBrand.isNotEmpty ? [...modelsForBrand, 'Others'] : <String>[];

    return Scaffold(
      appBar: AppBar(title: const TitleText('Sell Your Bike')),
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
                      // ... (Seller Name and Contact fields remain the same)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: CustomDropdownFormField<String>(
                          value: sellerCategory,
                          label: "Seller Category",
                          hint: "Choose Category",
                          items: sellerCategories
                              .map((b) =>
                                  DropdownMenuItem(value: b, child: Text(b)))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              sellerCategory = val;
                            });
                          },
                          validator: (val) => val == null ? "Required" : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          controller: sellerNameController,
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
                      // --- DYNAMIC BRAND & MODEL FIELDS ---
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: CustomDropdownFormField<String>(
                          value: selectedBrand,
                          label: "Brand Name",
                          hint: "Choose brand",
                          items: brandListWithOthers
                              .map((b) =>
                                  DropdownMenuItem(value: b, child: Text(b)))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedBrand = val;
                              // Reset model state when brand changes
                              selectedModel = null;
                              modelController.clear();
                              if (val != 'Others') {
                                brandController.clear();
                              } else {
                                brandFocusNode.requestFocus();
                              }
                            });
                          },
                          validator: (val) => val == null ? "Required" : null,
                        ),
                      ),
                      if (isBrandOthers)
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: TextFormField(
                            controller: brandController,
                            focusNode: brandFocusNode,
                            decoration: context.inputDecoration(
                                "Enter Brand Name", "e.g., Custom Bikes"),
                            validator: (val) =>
                                val!.isEmpty ? "Required" : null,
                          ),
                        ),
                      if (!isBrandOthers)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: CustomDropdownFormField<String>(
                            value: selectedModel,
                            label: "Model Name",
                            hint: selectedBrand != null
                                ? "Choose model"
                                : "Select a brand first",
                            items: modelListWithOthers
                                .map((m) =>
                                    DropdownMenuItem(value: m, child: Text(m)))
                                .toList(),
                            onChanged: selectedBrand != null
                                ? (val) {
                                    setState(() {
                                      selectedModel = val;
                                      if (val != 'Others') {
                                        modelController.clear();
                                      } else {
                                        modelFocusNode.requestFocus();
                                      }
                                    });
                                  }
                                : null,
                            validator: (val) => val == null ? "Required" : null,
                          ),
                        ),
                      if (isModelOthers && !isBrandOthers)
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: TextFormField(
                            controller: modelController,
                            focusNode: modelFocusNode,
                            decoration: context.inputDecoration(
                                "Enter Model Name", "e.g., Cafe Racer"),
                            validator: (val) =>
                                val!.isEmpty ? "Required" : null,
                          ),
                        ),
                      if (isBrandOthers)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            controller: modelController,
                            decoration: context.inputDecoration(
                                "Model Name", "e.g., Custom Bobber"),
                            validator: (val) =>
                                val!.isEmpty ? "Required" : null,
                          ),
                        ),
                      // ... (Rest of the form fields)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: MonthYearPicker(
                          enable: true,
                          label: "Manufacture Date",
                          hint: "Select month and year",
                          selectOnlyMonthYear: true,
                          selectedDate: _selectedManufactureDate,
                          onDateSelected: (date) =>
                              setState(() => _selectedManufactureDate = date),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: MonthYearPicker(
                          enable: true,
                          label: "Registration Date",
                          hint: "Select month and year",
                          selectOnlyMonthYear: true,
                          selectedDate: _selectedRegistrationDate,
                          onDateSelected: (date) =>
                              setState(() => _selectedRegistrationDate = date),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: CustomDropdownFormField<String>(
                          value: selectedState,
                          label: "State",
                          hint: "Select your state",
                          items: stateNames
                              .map((state) => DropdownMenuItem(
                                  value: state, child: Text(state)))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => selectedState = val),
                          validator: (val) => val == null ? "Required" : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AutocompleteSearchField(
                        label: "Address",
                        hint: "Enter address or locality",
                        controller: addressController,
                        icon: null,
                        lat: stateCoordinates[selectedState]?['lat'] ?? 0.0,
                        lon: stateCoordinates[selectedState]?['lon'] ?? 0.0,
                        onPlaceSelected: (suggestion) {
                          // Update all location controllers when a place is selected
                          setState(() {
                            addressController.text = suggestion.text;
                            cityController.text = suggestion.municipality ?? '';
                            pinCodeController.text =
                                suggestion.postalCode ?? '';
                          });
                        },
                        validator: (val) => val!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          controller: areaController,
                          decoration: context.inputDecoration(
                              "Area", "Enter Area name"),
                          validator: (val) => val!.isEmpty ? "Required" : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          controller: cityController,
                          decoration: context.inputDecoration(
                              "City", "Enter city name"),
                          validator: (val) => val!.isEmpty ? "Required" : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          controller: pinCodeController,
                          decoration: context.inputDecoration(
                              "Pin Code", "Enter Pin code"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          controller: kmDrivenController,
                          decoration: context.inputDecoration(
                              "KM Driven", "Enter kilometers driven"),
                          validator: (val) => val!.isEmpty ? "Required" : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: priceController,
                          decoration: context.inputDecoration(
                              "Expected Price", "Enter expected price"),
                          validator: (val) => val!.isEmpty ? "Required" : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: CustomDropdownFormField(
                          label: 'Current Ownership number?',
                          hint: "Tap to select",
                          value: _areYouFirstOwner,
                          items: firstOwnerNumber
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
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: CustomDropdownFormField(
                          label: 'Invoice available?',
                          hint: "Tap to select",
                          value: _invoiceAvailable,
                          items: yesNo
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
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: CustomDropdownFormField<String>(
                          label: 'Insurance available?',
                          hint: 'Select insurance availability',
                          value: _insuranceAvailable,
                          items: yesNo
                              .map((state) => DropdownMenuItem(
                                  value: state, child: Text(state)))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _insuranceAvailable = val;
                              if (val != 'Yes') _insuranceValidityTill = null;
                            });
                          },
                          validator: (val) => val == null
                              ? 'Please select insurance availability'
                              : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: MonthYearPicker(
                          enable: _insuranceAvailable == 'Yes',
                          label: "Insurance validity till",
                          hint: "Select month and year",
                          selectedDate: _insuranceValidityTill,
                          onDateSelected: (date) =>
                              setState(() => _insuranceValidityTill = date),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: CustomDropdownFormField<String>(
                          label: 'Battery condition',
                          hint: 'Select battery condition',
                          value: _batteryCondition,
                          items: goodBadList
                              .map((state) => DropdownMenuItem(
                                  value: state, child: Text(state)))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _batteryCondition = val),
                          validator: (val) => val == null
                              ? 'Please select battery condition'
                              : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: CustomDropdownFormField<String>(
                          label: 'Tyre condition',
                          hint: 'Select tyre condition',
                          value: _tyreCondition,
                          items: tyreConditionList
                              .map((state) => DropdownMenuItem(
                                  value: state, child: Text(state)))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _tyreCondition = val),
                          validator: (val) => val == null
                              ? 'Please select tyre condition'
                              : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          controller: additionalDetailsController,
                          decoration: context.inputDecoration(
                              "Additional Details", "Any extra info..."),
                          maxLines: 3,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: ImagePickerSection(
                          images: _images,
                          onImagesChanged: (images) => setState(() {
                            _images.clear();
                            _images.addAll(images);
                          }),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _termsAccepted,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _termsAccepted = newValue ?? false;
                                });
                              },
                              activeColor: Colors.green,
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    const TextSpan(
                                        text: 'I have read and agree to the '),
                                    TextSpan(
                                      text: 'Terms & Conditions',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = _openTermsLink,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
