import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:popp/src/utils/app_utils.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:popp/src/widgets/app_dialogs.dart';
import 'package:popp/src/widgets/loading_overlay.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../api/api_url.dart';
import '../../products/repository/product_repository.dart';
import '../../api/firebase/remote_config_service.dart';
import '../../gallery/pic_image_gallery.dart';
import '../../models/pop_category.dart';
import '../../models/product.dart';
import '../../navigation/app_routes.dart';
import '../../search/autocomplete_search_field.dart';
import '../../utils/app_loger.dart';
import '../../utils/product_content_data.dart';
import '../../widgets/bottom_sheet_selector_field.dart';
import '../../widgets/image_picker_selection.dart';
import '../../widgets/month_year_picker.dart';
import '../../widgets/segmented_selector_field.dart';
import '../../widgets/stepped_form_scaffold.dart';

class SellYourBike extends StatefulWidget {
  final Map<String, dynamic>? existingData;

  const SellYourBike({super.key, this.existingData});

  @override
  State<SellYourBike> createState() => _SellYourBikeState();
}

class _SellYourBikeState extends State<SellYourBike> {
  final ProductRepository _firebaseService = ProductRepository();
  final SteppedFormController _stepController = SteppedFormController();

  // One form key per wizard step so each validates independently.
  final List<GlobalKey<FormState>> _stepKeys =
      List.generate(5, (_) => GlobalKey<FormState>());

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
  String? _nocAvailable = "Yes";
  String? _batteryCondition;
  String? _tyreCondition;
  DateTime? _selectedManufactureDate;
  DateTime? _selectedRegistrationDate;
  bool _isLoading = false;
  String? _insuranceAvailable;
  DateTime? _insuranceValidityTill;
  bool _termsAccepted = false;
  bool _enableGallery = false;

  final List<File> _images = [];
  var productId = const Uuid().v4();

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

    final brand = (data['brandName'] as String? ?? '');
    if (bikeBrands.contains(brand)) {
      selectedBrand = brand;
      final model = (data['modelName'] as String? ?? '');
      final models = bikeBrandModels[brand] ?? [];
      if (models.contains(model)) {
        selectedModel = model;
      } else if (model.isNotEmpty) {
        selectedModel = 'Others';
        modelController.text = model;
      }
    } else if (brand.isNotEmpty) {
      selectedBrand = 'Others';
      brandController.text = brand;
      modelController.text = data['modelName'] ?? '';
    }

    _selectedManufactureDate = _toDateTime(data['mfgDate']);
    _selectedRegistrationDate = _toDateTime(data['registrationDate']);
    _insuranceValidityTill = _toDateTime(data['insuranceValidTill']);

    selectedState = data['state'] as String?;
    addressController.text = data['address'] ?? '';
    areaController.text = data['area'] ?? '';
    cityController.text = data['city'] ?? '';
    pinCodeController.text = data['pinCode'] ?? '';
    kmDrivenController.text = data['kmDriven'] ?? '';
    priceController.text = data['expectedPrice'] ?? '';
    _areYouFirstOwner = data['firstOwner'] as String?;
    _invoiceAvailable = data['invoiceAvailable'] as String?;
    _nocAvailable = data['nocAvailable'] as String?;
    _insuranceAvailable = data['insuranceAvailable'] as String?;
    _batteryCondition = data['batteryCondition'] as String?;
    _tyreCondition = data['tyreCondition'] as String?;
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

  @override
  void dispose() {
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

  Future<void> _submitForm() async {
    // Per-step validation is handled by SteppedFormScaffold before this runs.
    if (!_termsAccepted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms & Conditions')),
      );
      return;
    }

    String finalBrand;
    String finalModel;
    if (selectedBrand == 'Others') {
      finalBrand = brandController.text;
      finalModel = modelController.text;
    } else {
      finalBrand = selectedBrand ?? '';
      finalModel = selectedModel == 'Others' ? modelController.text : (selectedModel ?? '');
    }

    final List<String> keywords = [
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

      final bool wasApproved = widget.existingData!['isApproved'] == true;
      final Map<String, dynamic> contentFields = {
        'sellerCategory': sellerCategory ?? "Individual",
        'sellerName': sellerNameController.text,
        'sellerContactNumber': '$selectedCountryCode ${sellerContactController.text}',
        'brandName': finalBrand,
        'modelName': finalModel,
        'state': selectedState ?? "",
        'city': cityController.text,
        'area': areaController.text,
        'address': addressController.text,
        'pinCode': pinCodeController.text,
        'kmDriven': kmDrivenController.text,
        'expectedPrice': priceController.text,
        'price': priceController.text,
        'firstOwner': _areYouFirstOwner,
        'invoiceAvailable': _invoiceAvailable,
        'nocAvailable': _nocAvailable,
        'insuranceAvailable': _insuranceAvailable,
        'insuranceValidTill': _insuranceValidityTill,
        'registrationDate': _selectedRegistrationDate,
        'registrationPlace': "",
        'mfgDate': _selectedManufactureDate,
        'batteryCondition': _batteryCondition,
        'tyreCondition': _tyreCondition,
        'additionalDetails': additionalDetailsController.text,
        'imageUrl': imageUrls.isNotEmpty ? imageUrls.first : null,
        'thumbImageUrls': imageUrls,
        'searchKeywords': keywords,
      };

      final Map<String, dynamic> updateData;
      if (wasApproved) {
        // Approved product: store changes as pending update, keep live listing unchanged
        updateData = {
          'pendingUpdate': contentFields,
          'hasPendingUpdate': true,
          'status': 'pending_update',
          'pendingUpdateAt': FieldValue.serverTimestamp(),
        };
      } else {
        // Not yet approved: update main fields and reset to pending review
        updateData = {
          ...contentFields,
          'status': 'pending',
          'isApproved': false,
          'adminFeedback': FieldValue.delete(),
        };
      }

      await _handleLoading(true);
      final bool success = await _firebaseService.updateProduct(existingId, updateData);
      await _handleLoading(false);

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(wasApproved
                ? 'Update submitted for review. Your listing remains live.'
                : 'Listing updated! It is under review.'),
          ),
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
      categoryId: catList[0].categoryId,
      category: catList[0].name,
      subCategory: catList[0].name,
      sellerCategory: sellerCategory ?? "Individual",
      sellerName: sellerNameController.text,
      sellerContactNumber: '$selectedCountryCode ${sellerContactController.text}',
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
      searchKeywords: keywords,
    );

    bool success = await _firebaseService.submitProductForm(
      context: context,
      product: newProduct,
      images: _images,
      onLoading: _handleLoading,
    );

    if (success) {
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
        _nocAvailable = "Yes";
        _batteryCondition = null;
        _tyreCondition = null;
        _insuranceValidityTill = null;
        _selectedManufactureDate = null;
        _selectedRegistrationDate = null;
        _termsAccepted = false;
      });
      if (!mounted) return;
      AppDialogs.showProductSuccessDialog(context, () {
        context.pushMyListings(replace: true);
      }, () {
        context.goHome();
      });
    }
  }

  Widget _buildBanner() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withOpacity(0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: cs.primary),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
              child: Icon(Icons.verified_user_outlined, color: cs.primary, size: 20),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                child: Text(
                  "Strictly 250cc & above — powered bikes only",
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Premium summary card shown atop the Bike step once brand/model are known.
  Widget _buildBikeSummaryCard() {
    final brand = selectedBrand == 'Others'
        ? brandController.text
        : (selectedBrand ?? '');
    final model = (selectedBrand == 'Others' || selectedModel == 'Others')
        ? modelController.text
        : (selectedModel ?? '');

    if (brand.isEmpty && model.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Theme.of(context).colorScheme.primary.withOpacity(0.12), Colors.transparent],
        ),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              brand.isNotEmpty ? brand[0].toUpperCase() : '?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  model.isNotEmpty ? model : "Your bike",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(Widget child) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 10.0), child: child);

  String _ordinalLabel(String number) {
    final n = int.tryParse(number) ?? 1;
    final suffix = n == 1 ? 'st' : n == 2 ? 'nd' : n == 3 ? 'rd' : 'th';
    return '$n$suffix owner';
  }

  Widget _buildChip(String label) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outline),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: cs.onSurface.withOpacity(0.6),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildListingSnapshot(BuildContext context) {
    final brand = selectedBrand == 'Others'
        ? brandController.text
        : (selectedBrand ?? '');
    final model = (selectedBrand == 'Others' || selectedModel == 'Others')
        ? modelController.text
        : (selectedModel ?? '');

    final chips = <String>[];
    if (kmDrivenController.text.isNotEmpty) {
      chips.add('${kmDrivenController.text} km');
    }
    if (_areYouFirstOwner != null) {
      chips.add(_ordinalLabel(_areYouFirstOwner!));
    }
    if (_selectedManufactureDate != null) {
      chips.add(DateFormat('MMM yyyy').format(_selectedManufactureDate!));
    }
    if (cityController.text.isNotEmpty) {
      chips.add(cityController.text);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR LISTING',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      brand.isNotEmpty ? brand[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (brand.isNotEmpty)
                          Text(
                            brand.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        Text(
                          model.isNotEmpty ? model : 'Your bike',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _stepController.jumpTo(1),
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              if (chips.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: chips.map(_buildChip).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // --- Step 1: Seller details ---
  Widget _buildSellerStep(BuildContext context) {
    return Column(
      children: [
        _field(BottomSheetSelectorField<String>(
          value: sellerCategory,
          label: "Seller Category",
          hint: "Choose Category",
          prefixIcon: Icon(Icons.person_outline,
              size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38)),
          items: sellerCategories,
          labelBuilder: (item) => item,
          onChanged: (val) => setState(() => sellerCategory = val),
          validator: (val) => val == null ? "Required" : null,
        )),
        _field(TextFormField(
          controller: sellerNameController,
          decoration: context.inputDecoration(
              "Seller Name", "Enter your full name",
              icon: Icons.badge_outlined),
          validator: (val) => val!.isEmpty ? "Required" : null,
        )),
        _field(Row(
          children: [
            DropdownButton<String>(
              value: selectedCountryCode,
              items: countryCodes
                  .map((code) =>
                      DropdownMenuItem(value: code, child: Text(code)))
                  .toList(),
              onChanged: (val) => setState(() => selectedCountryCode = val!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: sellerContactController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: context.inputDecoration(
                    "Contact Number", "Enter phone number"),
                validator: (val) => AppUtils.phoneValidator(val,
                    countryCode: selectedCountryCode),
              ),
            ),
          ],
        )),
      ],
    );
  }

  // --- Step 2: Bike details ---
  Widget _buildBikeStep(BuildContext context) {
    final bool isBrandOthers = selectedBrand == 'Others';
    final bool isModelOthers = selectedModel == 'Others';

    final modelsForBrand =
        isBrandOthers ? <String>[] : (bikeBrandModels[selectedBrand] ?? []);

    final brandListWithOthers = [...bikeBrands, 'Others'];
    final modelListWithOthers =
        modelsForBrand.isNotEmpty ? [...modelsForBrand, 'Others'] : <String>[];

    return Column(
      children: [
        _buildBikeSummaryCard(),
        _field(BottomSheetSelectorField<String>(
          value: selectedBrand,
          label: "Brand Name",
          hint: "Choose brand",
          prefixIcon: Icon(Icons.two_wheeler,
              size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38)),
          items: brandListWithOthers,
          labelBuilder: (item) => item,
          onChanged: (val) {
            setState(() {
              selectedBrand = val;
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
        )),
        if (isBrandOthers)
          _field(TextFormField(
            controller: brandController,
            focusNode: brandFocusNode,
            decoration: context.inputDecoration(
                "Enter Brand Name", "e.g., Custom Bikes"),
            validator: (val) => val!.isEmpty ? "Required" : null,
          )),
        if (!isBrandOthers)
          _field(BottomSheetSelectorField<String>(
            value: selectedModel,
            label: "Model Name",
            hint: selectedBrand != null
                ? "Choose model"
                : "Select a brand first",
            enabled: selectedBrand != null,
            items: modelListWithOthers,
            labelBuilder: (item) => item,
            onChanged: (val) {
              setState(() {
                selectedModel = val;
                if (val != 'Others') {
                  modelController.clear();
                } else {
                  modelFocusNode.requestFocus();
                }
              });
            },
            validator: (val) => val == null ? "Required" : null,
          )),
        if (isModelOthers && !isBrandOthers)
          _field(TextFormField(
            controller: modelController,
            focusNode: modelFocusNode,
            decoration:
                context.inputDecoration("Enter Model Name", "e.g., Cafe Racer"),
            validator: (val) => val!.isEmpty ? "Required" : null,
          )),
        if (isBrandOthers)
          _field(TextFormField(
            controller: modelController,
            decoration:
                context.inputDecoration("Model Name", "e.g., Custom Bobber"),
            validator: (val) => val!.isEmpty ? "Required" : null,
          )),
        _field(MonthYearPicker(
          enable: true,
          label: "Manufacture Date",
          hint: "Select month and year",
          selectOnlyMonthYear: true,
          selectedDate: _selectedManufactureDate,
          onDateSelected: (date) =>
              setState(() => _selectedManufactureDate = date),
        )),
        _field(MonthYearPicker(
          enable: true,
          label: "Registration Date",
          hint: "Select month and year",
          selectOnlyMonthYear: true,
          selectedDate: _selectedRegistrationDate,
          onDateSelected: (date) =>
              setState(() => _selectedRegistrationDate = date),
        )),
        _field(TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
          controller: kmDrivenController,
          decoration: context.inputDecoration(
              "KM Driven", "Enter kilometers driven",
              icon: Icons.speed_outlined),
          validator: (val) => val!.isEmpty ? "Required" : null,
        )),
        _field(BottomSheetSelectorField<String>(
          label: 'Current Ownership number?',
          hint: "Tap to select",
          value: _areYouFirstOwner,
          prefixIcon: Icon(Icons.people_alt_outlined,
              size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38)),
          items: firstOwnerNumber,
          labelBuilder: (item) => item,
          onChanged: (val) => setState(() => _areYouFirstOwner = val),
          validator: (val) =>
              val == null ? 'Please select ownership status' : null,
        )),
      ],
    );
  }

  // --- Step 3: Documents & condition ---
  Widget _buildDocsStep(BuildContext context) {
    return Column(
      children: [
        _field(SegmentedSelectorField(
          label: 'Invoice available?',
          icon: Icons.description_outlined,
          options: yesNo,
          value: _invoiceAvailable,
          onChanged: (val) => setState(() => _invoiceAvailable = val),
          validator: (val) =>
              val == null ? 'Please select Invoice availability' : null,
        )),
        _field(SegmentedSelectorField(
          label: 'NOC available?',
          icon: Icons.assignment_turned_in_outlined,
          options: yesNoNA,
          value: _nocAvailable,
          onChanged: (val) => setState(() => _nocAvailable = val),
          validator: (val) => val == null ? 'Please select NOC status' : null,
        )),
        _field(SegmentedSelectorField(
          label: 'Insurance available?',
          icon: Icons.shield_outlined,
          options: yesNo,
          value: _insuranceAvailable,
          onChanged: (val) {
            setState(() {
              _insuranceAvailable = val;
              if (val != 'Yes') _insuranceValidityTill = null;
            });
          },
          validator: (val) =>
              val == null ? 'Please select insurance availability' : null,
        )),
        _field(MonthYearPicker(
          enable: _insuranceAvailable == 'Yes',
          label: "Insurance validity till",
          hint: "Select month and year",
          selectedDate: _insuranceValidityTill,
          onDateSelected: (date) =>
              setState(() => _insuranceValidityTill = date),
        )),
        _field(BottomSheetSelectorField<String>(
          label: 'Battery condition',
          hint: 'Select battery condition',
          value: _batteryCondition,
          prefixIcon: Icon(Icons.battery_charging_full_outlined,
              size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38)),
          items: goodBadList,
          labelBuilder: (item) => item,
          onChanged: (val) => setState(() => _batteryCondition = val),
          validator: (val) =>
              val == null ? 'Please select battery condition' : null,
        )),
        _field(BottomSheetSelectorField<String>(
          label: 'Tyre condition',
          hint: 'Select tyre condition',
          value: _tyreCondition,
          prefixIcon: Icon(Icons.album_outlined,
              size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38)),
          items: tyreConditionList,
          labelBuilder: (item) => item,
          onChanged: (val) => setState(() => _tyreCondition = val),
          validator: (val) =>
              val == null ? 'Please select tyre condition' : null,
        )),
      ],
    );
  }

  // --- Step 4: Location ---
  Widget _buildLocationStep(BuildContext context) {
    return Column(
      children: [
        _field(BottomSheetSelectorField<String>(
          value: selectedState,
          label: "State",
          hint: "Select your state",
          prefixIcon: Icon(Icons.map_outlined,
              size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38)),
          items: stateNames,
          labelBuilder: (item) => item,
          onChanged: (val) => setState(() => selectedState = val),
          validator: (val) => val == null ? "Required" : null,
        )),
        _field(TextFormField(
          maxLines: 1,
          controller: addressController,
          decoration: context.inputDecoration("Address", "Enter Address name",
              icon: Icons.home_outlined),
          validator: (val) => val!.isEmpty ? "Required" : null,
        )),
        _field(AutocompleteSearchField(
          label: "Area",
          hint: "Enter Area name",
          controller: areaController,
          icon: Icons.place_outlined,
          lat: stateCoordinates[selectedState]?['lat'] ?? 0.0,
          lon: stateCoordinates[selectedState]?['lon'] ?? 0.0,
          onPlaceSelected: (suggestion) {
            setState(() {
              areaController.text = suggestion.text;
              cityController.text = suggestion.municipality ?? '';
              pinCodeController.text = suggestion.postalCode ?? '';
            });
          },
          validator: (val) => val!.isEmpty ? "Required" : null,
        )),
        _field(TextFormField(
          controller: cityController,
          decoration: context.inputDecoration("City", "Enter city name",
              icon: Icons.location_city_outlined),
          validator: (val) => val!.isEmpty ? "Required" : null,
        )),
        _field(TextFormField(
          controller: pinCodeController,
          decoration: context.inputDecoration("Pin Code", "Enter Pin code",
              icon: Icons.pin_drop_outlined),
        )),
      ],
    );
  }

  // --- Step 5: Pricing, photos & review ---
  Widget _buildPricingStep(BuildContext context) {
    return Column(
      children: [
        _field(_buildListingSnapshot(context)),
        _field(TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
          controller: priceController,
          decoration: context.inputDecoration(
              "Expected Price", "Enter expected price",
              icon: Icons.currency_rupee),
          validator: (val) => val!.isEmpty ? "Required" : null,
        )),
        _field(TextFormField(
          controller: additionalDetailsController,
          decoration: context.inputDecoration(
              "Additional Details", "Any extra info...",
              icon: Icons.notes_outlined),
          maxLines: 3,
        )),
        _field(ImagePickerSection(
          images: _images,
          allowGallery: _enableGallery,
          allowMultipleImages: _enableGallery,
          onImagesChanged: (images) => setState(() {
            _images.clear();
            _images.addAll(images);
          }),
        )),
        _field(Row(
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
                    const TextSpan(text: 'I have read and agree to the '),
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = _openTermsLink,
                    ),
                  ],
                ),
              ),
            ),
          ],
        )),
      ],
    );
  }

  bool _hasFormData() {
    final textControllers = <TextEditingController>[
      sellerNameController,
      sellerContactController,
      brandController,
      modelController,
      kmDrivenController,
      priceController,
      additionalDetailsController,
      addressController,
      cityController,
      areaController,
      pinCodeController,
    ];
    for (final c in textControllers) {
      if (c.text.trim().isNotEmpty) return true;
    }
    if (_images.isNotEmpty) return true;
    if (selectedBrand != null) return true;
    if (sellerCategory != null) return true;
    if (selectedModel != null) return true;
    if (selectedState != null) return true;
    if (_areYouFirstOwner != null) return true;
    if (_invoiceAvailable != null) return true;
    if (_batteryCondition != null) return true;
    if (_tyreCondition != null) return true;
    if (_selectedManufactureDate != null) return true;
    if (_selectedRegistrationDate != null) return true;
    if (_insuranceAvailable != null) return true;
    if (_insuranceValidityTill != null) return true;
    if (_termsAccepted) return true;
    return false;
  }

  Future<bool> _confirmDiscardChanges() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
            'You have unsaved changes. If you go back now, your data will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _handleBackPressed() async {
    if (_hasFormData()) {
      final discard = await _confirmDiscardChanges();
      if (discard && mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasFormData(),
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_hasFormData()) {
          final discard = await _confirmDiscardChanges();
          if (discard && mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        } else {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        }
      },
      child: LoadingOverlay(
      isLoading: _isLoading,
      child: SteppedFormScaffold(
        appBarTitle: _isEditing ? 'Edit Your Bike' : 'Sell Your Bike',
        isLoading: _isLoading,
        allowStepJump: _isEditing,
        submitLabel: _isEditing ? "Update" : "Submit",
        onSubmit: _submitForm,
        controller: _stepController,
        banner: _buildBanner(),
        onBackPressed: _handleBackPressed,
        steps: [
          FormStep(
            title: "Seller details",
            subtitle: "Tell buyers who they're dealing with",
            formKey: _stepKeys[0],
            builder: _buildSellerStep,
          ),
          FormStep(
            title: "Bike details",
            subtitle: "The essentials about your bike",
            formKey: _stepKeys[1],
            builder: _buildBikeStep,
          ),
          FormStep(
            title: "Documents & condition",
            subtitle: "Paperwork and current condition",
            formKey: _stepKeys[2],
            builder: _buildDocsStep,
          ),
          FormStep(
            title: "Location",
            subtitle: "Where is the bike located?",
            formKey: _stepKeys[3],
            builder: _buildLocationStep,
          ),
          FormStep(
            title: "Pricing & photos",
            subtitle: "Set your price and add photos",
            formKey: _stepKeys[4],
            builder: _buildPricingStep,
          ),
        ],
      ),
      ),
    );
  }
}
