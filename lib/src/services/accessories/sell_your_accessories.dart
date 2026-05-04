import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:popp/src/utils/app_utils.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:popp/src/widgets/category_selector.dart';
import 'package:popp/src/widgets/loading_overlay.dart';
import 'package:popp/src/toolbar/common_app_bar.dart';
import 'package:popp/src/widgets/title_text.dart';
import 'package:popp/src/widgets/web_constrained_box.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../api/api_url.dart';
import '../../api/firebase/firebase_api_service.dart';
import '../../api/firebase/remote_config_service.dart';
import '../../gallery/pic_image_gallery.dart';
import '../../models/pop_category.dart';
import '../../models/product.dart';
import '../../navigation/nav_router.dart';
import '../../search/autocomplete_search_field.dart';
import '../../utils/product_content_data.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/custom_dropdown_form_field.dart';
import '../../widgets/image_picker_selection.dart';
import '../../widgets/month_year_picker.dart';

class SellYourAccessories extends StatefulWidget {
  final Map<String, dynamic>? existingData;

  const SellYourAccessories({super.key, this.existingData});

  @override
  State<SellYourAccessories> createState() => _SellYourAccessoriesState();
}

class _SellYourAccessoriesState extends State<SellYourAccessories> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseApiService _firebaseApiService = FirebaseApiService();

  final TextEditingController sellerNameController = TextEditingController();
  final TextEditingController accessoriesNameController =
      TextEditingController();
  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController sellerContactController = TextEditingController();
  final TextEditingController modelNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController additionalDetailsController =
      TextEditingController();
  final TextEditingController productSizeController = TextEditingController();
  final TextEditingController warrantyLeftController = TextEditingController();

  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  String selectedCountryCode = "+91";
  String? selectedState;
  String? sellerCategory;
  DateTime? _selectedManufactureDate;
  DateTime? _selectedBillDate;
  String? _productCondition;
  PopCategory? selectedCategory;
  String? selectedSubcategory;
  String? selectedBikeBrand;
  Function(String?)? onBrandChanged;
  bool isBikeSpecific = false;
  bool isBillAvailable = false;
  bool isWarrantyAvailable = true;
  bool _termsAccepted = false;
  bool _enableGallery = false;
  int _productAgingMonths = 0;
  int _productAgingYears = 0;

  void _clearBikeSpecificFields() {
    selectedBikeBrand = null;
    modelNameController.clear();
    _selectedManufactureDate = null;
  }

  void _clearBillFields() {
    _selectedBillDate = null;
    _productAgingMonths = 0;
    _productAgingYears = 0;
  }

  void _clearWarrantyFields() {
    warrantyLeftController.clear();
  }

  final List<File> _images = [];
  var productId = const Uuid().v4();
  bool _isLoading = false;

  bool get _isEditing => widget.existingData != null;

  DateTime? _toDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    try { return v.toDate(); } catch (_) { return null; }
  }

  void _initFromExistingData(Map<String, dynamic> data) {
    sellerCategory = data['sellerCategory'] as String?;
    sellerNameController.text = data['sellerName'] ?? '';

    final contact = (data['sellerContactNumber'] as String? ?? '');
    final spaceIdx = contact.indexOf(' ');
    if (spaceIdx > 0) {
      selectedCountryCode = contact.substring(0, spaceIdx);
      sellerContactController.text = contact.substring(spaceIdx + 1);
    } else {
      sellerContactController.text = contact;
    }

    final categoryName = data['category'] as String? ?? '';
    final matches = catList.where((c) => c.name == categoryName);
    selectedCategory = matches.isNotEmpty ? matches.first : null;
    selectedSubcategory = data['subCategory'] as String?;

    accessoriesNameController.text = data['modelName'] ?? '';
    brandNameController.text = data['brandName'] ?? '';

    isBikeSpecific = data['isProductBikeSpecific'] == true;
    selectedBikeBrand = data['bikeBrandName'] as String?;
    modelNameController.text = data['bikeModelName'] ?? '';
    _selectedManufactureDate = _toDateTime(data['bikeMfgDate']);

    selectedState = data['state'] as String?;
    addressController.text = data['address'] ?? '';
    areaController.text = data['area'] ?? '';
    cityController.text = data['city'] ?? '';
    pinCodeController.text = data['pinCode'] ?? '';
    productSizeController.text = data['productSize'] ?? '';
    _productCondition = data['productCondition'] as String?;

    _selectedBillDate = _toDateTime(data['billDate']);
    isBillAvailable = _selectedBillDate != null;

    // Parse productAging string e.g. "3 months 2 years"
    final agingStr = data['productAging'] as String? ?? '';
    final mMatch = RegExp(r'(\d+)\s*month').firstMatch(agingStr);
    final yMatch = RegExp(r'(\d+)\s*year').firstMatch(agingStr);
    _productAgingMonths = int.tryParse(mMatch?.group(1) ?? '0') ?? 0;
    _productAgingYears = int.tryParse(yMatch?.group(1) ?? '0') ?? 0;

    warrantyLeftController.text = data['warrantyLimit'] ?? '';
    isWarrantyAvailable = warrantyLeftController.text.isNotEmpty;

    priceController.text = data['expectedPrice'] ?? '';
    additionalDetailsController.text = data['additionalDetails'] ?? '';
    _termsAccepted = true;
  }

  @override
  void initState() {
    super.initState();
    _loadConfig();
    if (widget.existingData != null) {
      _initFromExistingData(widget.existingData!);
    }
  }

  void _loadConfig() async {
    final configService = await RemoteConfigService.getInstance();
    setState(() {
      _enableGallery = configService.enableGallery;
    });
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

  void submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    if (!_termsAccepted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms & Conditions')),
      );
      return;
    }

    final List<String> keywords = [
      selectedCategory?.name ?? "",
      selectedSubcategory ?? "",
      accessoriesNameController.text,
      brandNameController.text,
      selectedBikeBrand ?? "",
      modelNameController.text,
      _selectedManufactureDate != null ? _selectedManufactureDate!.year.toString() : "",
      selectedState ?? "",
      addressController.text,
      productSizeController.text,
      _productCondition ?? "",
      '$_productAgingMonths months $_productAgingYears years',
      warrantyLeftController.text,
      priceController.text,
      additionalDetailsController.text,
      ...selectedCategory?.name.toLowerCase().split(' ') ?? [],
      ...selectedSubcategory?.toLowerCase().split(' ') ?? [],
      ...accessoriesNameController.text.toLowerCase().split(' '),
      ...brandNameController.text.toLowerCase().split(' '),
      ...selectedBikeBrand?.toLowerCase().split(' ') ?? [],
      ...modelNameController.text.toLowerCase().split(' '),
      ...addressController.text.toLowerCase().split(' '),
      ...productSizeController.text.toLowerCase().split(' '),
      ..._productCondition?.toLowerCase().split(' ') ?? [],
      ...'$_productAgingMonths months $_productAgingYears years'.split(' '),
      ...warrantyLeftController.text.toLowerCase().split(' '),
      ...priceController.text.toLowerCase().split(' '),
      ...'accessories'.toLowerCase().split(' '),
      ...additionalDetailsController.text.toLowerCase().split(' '),
    ];

    if (_isEditing) {
      final String existingId = widget.existingData!['id'];
      final existingImageUrls =
          (widget.existingData!['thumbImageUrls'] as List? ?? []).cast<String>();

      List<String> imageUrls = existingImageUrls;
      if (_images.isNotEmpty) {
        await _handleLoading(true);
        imageUrls = await uploadMultipleImages(_images);
        if (imageUrls.isEmpty) {
          await _handleLoading(false);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image upload failed. Please try again.')),
          );
          return;
        }
      }

      final Map<String, dynamic> updateData = {
        'sellerCategory': sellerCategory ?? "Individual",
        'sellerName': sellerNameController.text,
        'sellerContactNumber': '$selectedCountryCode ${sellerContactController.text}',
        'categoryId': selectedCategory?.categoryId ?? "",
        'category': selectedCategory?.name ?? "",
        'subCategory': selectedSubcategory,
        'modelName': accessoriesNameController.text,
        'brandName': brandNameController.text,
        'isProductBikeSpecific': isBikeSpecific,
        'bikeBrandName': selectedBikeBrand ?? "",
        'bikeModelName': modelNameController.text,
        'bikeMfgDate': _selectedManufactureDate,
        'state': selectedState ?? "",
        'city': cityController.text,
        'area': areaController.text,
        'address': addressController.text,
        'pinCode': pinCodeController.text,
        'productSize': productSizeController.text,
        'productCondition': _productCondition,
        'billDate': _selectedBillDate,
        'productAging': '$_productAgingMonths months $_productAgingYears years',
        'warrantyLimit': warrantyLeftController.text,
        'expectedPrice': priceController.text,
        'price': priceController.text,
        'additionalDetails': additionalDetailsController.text,
        'imageUrl': imageUrls.isNotEmpty ? imageUrls.first : null,
        'thumbImageUrls': imageUrls,
        'status': 'pending',
        'isApproved': false,
        'adminFeedback': FieldValue.delete(),
        'searchKeywords': keywords,
      };

      await _handleLoading(true);
      final bool success = await _firebaseApiService.updateProduct(existingId, updateData);
      await _handleLoading(false);

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing updated! It is under review.')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update failed. Please try again.')),
        );
      }
      return;
    }

    // Create mode
    String countryCode = Localizations.localeOf(context).countryCode ?? "IN";
    Product newProduct = Product(
        id: productId,
        isApproved: false,
        isSold: false,
        countryCode: countryCode,
        userId: FirebaseAuth.instance.currentUser?.uid,
        categoryId: selectedCategory?.categoryId ?? "",
        category: selectedCategory?.name ?? "",
        sellerContactNumber:
            '$selectedCountryCode ${sellerContactController.text}',
        sellerName: sellerNameController.text,
        sellerCategory: sellerCategory ?? "Individual",
        subCategory: selectedSubcategory,
        modelName: accessoriesNameController.text,
        isProductBikeSpecific: isBikeSpecific,
        brandName: brandNameController.text,
        bikeBrandName: selectedBikeBrand ?? "",
        bikeModelName: modelNameController.text,
        bikeMfgDate: _selectedManufactureDate,
        state: selectedState ?? "",
        city: cityController.text,
        area: areaController.text,
        address: addressController.text,
        pinCode: pinCodeController.text,
        productSize: productSizeController.text,
        productCondition: _productCondition,
        billDate: _selectedBillDate,
        productAging: '$_productAgingMonths months $_productAgingYears years',
        warrantyLimit: warrantyLeftController.text,
        expectedPrice: priceController.text,
        price: priceController.text,
        additionalDetails: additionalDetailsController.text,
        createdAt: FieldValue.serverTimestamp(),
        searchKeywords: keywords,
      );

      AppLogger.d("Product data to be submitted: ${newProduct.toJson()}");

      bool success = await _firebaseApiService.submitProductForm(
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
        areaController.clear();
        addressController.clear();
        pinCodeController.clear();
        priceController.clear();
        additionalDetailsController.clear();
        setState(() {
          _productAgingMonths = 0;
          _productAgingYears = 0;
        });
        productSizeController.clear();
        warrantyLeftController.clear();

        setState(() {
          _images.clear();
          _termsAccepted = false;
        });
        if (mounted) {
          AppDialogs.showProductSuccessDialog(context, () {
            onMyListingScreenTap(context, true);
          }, () {
            Navigator.pushReplacementNamed(context, '/home');
          });
        }
      }
  }

  @override
  void dispose() {
    sellerNameController.dispose();
    sellerContactController.dispose();
    cityController.dispose();
    areaController.dispose();
    addressController.dispose();
    pinCodeController.dispose();
    priceController.dispose();
    additionalDetailsController.dispose();
    accessoriesNameController.dispose();
    brandNameController.dispose();
    modelNameController.dispose();
    productSizeController.dispose();
    warrantyLeftController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        titleWidget: TitleText(_isEditing ? 'Edit Your Accessories' : 'Sell Your Accessories'),
      ),
      body: WebConstrainedBox(
        child: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  buildPaddedField(CustomDropdownFormField<String>(
                    enabled: true,
                    value: sellerCategory,
                    label: "Seller Category",
                    hint: "Choose Category",
                    items: sellerCategories
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (val) => setState(() => sellerCategory = val),
                    validator: (val) =>
                        isBikeSpecific && val == null ? "Required" : null,
                  )),
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
                          validator: (val) => val!.isEmpty ? "Required" : null,
                        ),
                      ),
                    ],
                  )),
                  buildPaddedField(CategorySelector(
                    initialCategory: selectedCategory,
                    initialSubcategory: selectedSubcategory,
                    onCategoryChanged: (cat) => setState(() => selectedCategory = cat),
                    onSubcategoryChanged: (sub) => setState(() => selectedSubcategory = sub),
                  )),
                  buildPaddedField(TextFormField(
                    controller: accessoriesNameController,
                    decoration: context.inputDecoration(
                        "Accessories Name", "Enter your Accessories name"),
                    validator: (val) => val!.isEmpty ? "Required" : null,
                  )),
                  buildPaddedField(TextFormField(
                    controller: brandNameController,
                    decoration: context.inputDecoration(
                        "Brand Name", "Enter your Brand name"),
                    validator: (val) => val!.isEmpty ? "Required" : null,
                  )),
                  buildPaddedField(SwitchListTile(
                    title: const Text("Is your product bike specific?"),
                    value: isBikeSpecific,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.withOpacity(0.5),
                    onChanged: (val) {
                      setState(() {
                        isBikeSpecific = val;
                        if (!val) _clearBikeSpecificFields();
                      });
                    },
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
                    selectOnlyMonthYear: true,
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
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      controller: addressController,
                      decoration: context.inputDecoration(
                          "Address", "Enter address or locality"),
                      maxLines: 1,
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AutocompleteSearchField(
                    label: "Area",
                    hint: "Enter Area name",
                    controller: areaController,
                    icon: null,
                    lat: stateCoordinates[selectedState]?['lat'] ?? 0.0,
                    lon: stateCoordinates[selectedState]?['lon'] ?? 0.0,
                    onPlaceSelected: (suggestion) {
                      // Update all location controllers when a place is selected
                      setState(() {
                        areaController.text = suggestion.text;
                        cityController.text = suggestion.municipality ?? '';
                        pinCodeController.text = suggestion.postalCode ?? '';
                      });
                    },
                    validator: (val) => val!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      controller: cityController,
                      decoration:
                          context.inputDecoration("City", "Enter city name"),
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: pinCodeController,
                      decoration:
                          context.inputDecoration("Pin Code", "Enter Pin code"),
                    ),
                  ),
                  buildPaddedField(TextFormField(
                    controller: productSizeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: context.inputDecoration(
                        "Product size", "If applicable"),
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
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.withOpacity(0.5),
                    value: isBillAvailable,
                    onChanged: (val) {
                      setState(() {
                        isBillAvailable = val;
                        if (!val) _clearBillFields();
                      });
                    },
                  )),
                  buildPaddedField(MonthYearPicker(
                    enable: isBillAvailable,
                    label: "Bill Date",
                    hint: "Select month and year",
                    selectedDate: _selectedBillDate,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedBillDate = date;
                        final age = AppUtils.calculateAge(_selectedBillDate);
                        _productAgingYears = age['years'] ?? 0;
                        _productAgingMonths = age['months'] ?? 0;
                      });
                    },
                  )),
                  buildPaddedField(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "Product Aging",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAgingPicker(
                              "Months",
                              _productAgingMonths,
                              0,
                              11,
                              (val) => setState(() => _productAgingMonths = val),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildAgingPicker(
                              "Years",
                              _productAgingYears,
                              0,
                              50,
                              (val) => setState(() => _productAgingYears = val),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
                  buildPaddedField(SwitchListTile(
                    title: const Text("Warranty available?"),
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.withOpacity(0.5),
                    value: isWarrantyAvailable,
                    onChanged: (val) {
                      setState(() {
                        isWarrantyAvailable = val;
                        if (!val) _clearWarrantyFields();
                      });
                    },
                  )),
                  buildPaddedField(TextFormField(
                    enabled: isWarrantyAvailable,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: warrantyLeftController,
                    decoration: context.inputDecoration("Remaining Warranty Period",
                        "How many months/years warranty left?"),
                  )),
                  buildPaddedField(TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                    allowGallery: _enableGallery,
                    allowMultipleImages: _enableGallery,
                    onImagesChanged: (images) => setState(() {
                      _images.clear();
                      _images.addAll(images);
                    }),
                  )),
                  buildPaddedField(
                    Row(
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
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WebConstrainedBox(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: submitForm,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  child: Text(_isEditing ? "Update" : "Submit"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgingPicker(
      String label, int value, int min, int max, ValueChanged<int> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed:
                    value > min ? () => onChanged(value - 1) : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                '$value',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed:
                    value < max ? () => onChanged(value + 1) : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
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
