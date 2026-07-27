import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:popp/src/utils/app_utils.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:popp/src/widgets/category_selector.dart';
import 'package:popp/src/widgets/loading_overlay.dart';
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
import '../../theme/bikerverse_colors.dart';
import '../../utils/product_content_data.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/bottom_sheet_selector_field.dart';
import '../../widgets/image_picker_selection.dart';
import '../../widgets/month_year_picker.dart';
import '../../widgets/segmented_selector_field.dart';
import '../../widgets/stepped_form_scaffold.dart';

class SellYourAccessories extends StatefulWidget {
  final Map<String, dynamic>? existingData;

  const SellYourAccessories({super.key, this.existingData});

  @override
  State<SellYourAccessories> createState() => _SellYourAccessoriesState();
}


class _SellYourAccessoriesState extends State<SellYourAccessories> {
  final FirebaseApiService _firebaseApiService = FirebaseApiService();
  final SteppedFormController _stepController = SteppedFormController();

  final List<GlobalKey<FormState>> _stepKeys =
      List.generate(5, (_) => GlobalKey<FormState>());

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

  String selectedCountryCode = '+91';
  String? selectedState;
  String? sellerCategory;
  DateTime? _selectedManufactureDate;
  DateTime? _selectedBillDate;
  DateTime? _selectedWarrantyTillDate;
  String? _productCondition;
  PopCategory? selectedCategory;
  String? selectedSubcategory;
  String? selectedBikeBrand;

  // Boolean fields kept as bools; SegmentedSelectorField maps to/from 'Yes'/'No'.
  bool isBikeSpecific = false;
  bool isBillAvailable = false;
  bool isWarrantyAvailable = false;

  bool _termsAccepted = false;
  bool _enableGallery = false;
  bool _isLoading = false;
  int _productAgingMonths = 0;
  int _productAgingYears = 0;

  final List<File> _images = [];
  var productId = const Uuid().v4();

  bool get _isEditing => widget.existingData != null;

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatMonthAndYear(int years, int months) {
    final yearLabel = years == 1 ? '1 year' : '$years years';
    final monthLabel = months == 1 ? '1 month' : '$months months';
    if (years > 0 && months > 0) return '$yearLabel $monthLabel';
    if (years > 0) return yearLabel;
    return monthLabel;
  }

  String _remainingWarrantyText(DateTime? tillDate) {
    if (tillDate == null) return '';
    final now = DateTime.now();
    int totalMonths =
        (tillDate.year - now.year) * 12 + (tillDate.month - now.month);
    if (totalMonths < 0) totalMonths = 0;
    return _formatMonthAndYear(totalMonths ~/ 12, totalMonths % 12);
  }

  bool _isPastMonth(DateTime date) {
    final now = DateTime.now();
    return DateTime(date.year, date.month)
        .isBefore(DateTime(now.year, now.month));
  }

  void _clearBikeSpecificFields() {
    selectedBikeBrand = null;
    modelNameController.clear();
    _selectedManufactureDate = null;
  }

  void _clearWarrantyFields() {
    _selectedWarrantyTillDate = null;
    warrantyLeftController.clear();
  }

  DateTime? _toDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    try {
      return v.toDate();
    } catch (_) {
      return null;
    }
  }

  // ── Init ─────────────────────────────────────────────────────────────────

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
    setState(() => _enableGallery = configService.enableGallery);
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
    isBillAvailable = data['isBillAvailable'] as bool? ?? false;

    final age = AppUtils.calculateAge(_selectedBillDate);
    _productAgingYears = age['years'] ?? 0;
    _productAgingMonths = age['months'] ?? 0;

    _selectedWarrantyTillDate = _toDateTime(data['warrantyValidTill']);
    isWarrantyAvailable = _selectedWarrantyTillDate != null;
    warrantyLeftController.text =
        _remainingWarrantyText(_selectedWarrantyTillDate);

    priceController.text = data['expectedPrice'] ?? '';
    additionalDetailsController.text = data['additionalDetails'] ?? '';
    _termsAccepted = true;
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    sellerNameController.dispose();
    sellerContactController.dispose();
    accessoriesNameController.dispose();
    brandNameController.dispose();
    modelNameController.dispose();
    cityController.dispose();
    areaController.dispose();
    addressController.dispose();
    pinCodeController.dispose();
    priceController.dispose();
    additionalDetailsController.dispose();
    productSizeController.dispose();
    warrantyLeftController.dispose();
    super.dispose();
  }

  // ── Loading ───────────────────────────────────────────────────────────────

  Future<void> _handleLoading(bool isLoading) async {
    if (mounted) setState(() => _isLoading = isLoading);
  }

  void _openTermsLink() async {
    AppLogger.w('Terms link clicked');
    final uri = Uri.parse(ApiUrl.customersTermsLink);
    final launched = await launchUrl(uri);
    if (launched) {
      setState(() => _termsAccepted = true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Terms & Conditions link.')),
      );
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submitForm() async {
    if (!_termsAccepted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms & Conditions')),
      );
      return;
    }

    final List<String> keywords = [
      selectedCategory?.name ?? '',
      selectedSubcategory ?? '',
      accessoriesNameController.text,
      brandNameController.text,
      selectedBikeBrand ?? '',
      modelNameController.text,
      _selectedManufactureDate != null
          ? _selectedManufactureDate!.year.toString()
          : '',
      selectedState ?? '',
      addressController.text,
      productSizeController.text,
      _productCondition ?? '',
      _formatMonthAndYear(_productAgingYears, _productAgingMonths),
      warrantyLeftController.text,
      priceController.text,
      additionalDetailsController.text,
      ...?selectedCategory?.name.toLowerCase().split(' '),
      ...?selectedSubcategory?.toLowerCase().split(' '),
      ...accessoriesNameController.text.toLowerCase().split(' '),
      ...brandNameController.text.toLowerCase().split(' '),
      ...?selectedBikeBrand?.toLowerCase().split(' '),
      ...modelNameController.text.toLowerCase().split(' '),
      ...addressController.text.toLowerCase().split(' '),
      ...productSizeController.text.toLowerCase().split(' '),
      ...?_productCondition?.toLowerCase().split(' '),
      ..._formatMonthAndYear(_productAgingYears, _productAgingMonths)
          .split(' '),
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
            const SnackBar(
                content: Text('Image upload failed. Please try again.')),
          );
          return;
        }
      }

      final Map<String, dynamic> updateData = {
        'sellerCategory': sellerCategory ?? 'Individual',
        'sellerName': sellerNameController.text,
        'sellerContactNumber':
            '$selectedCountryCode ${sellerContactController.text}',
        'categoryId': selectedCategory?.categoryId ?? '',
        'category': selectedCategory?.name ?? '',
        'subCategory': selectedSubcategory,
        'modelName': accessoriesNameController.text,
        'brandName': brandNameController.text,
        'isProductBikeSpecific': isBikeSpecific,
        'bikeBrandName': selectedBikeBrand ?? '',
        'bikeModelName': modelNameController.text,
        'bikeMfgDate': _selectedManufactureDate,
        'state': selectedState ?? '',
        'city': cityController.text,
        'area': areaController.text,
        'address': addressController.text,
        'pinCode': pinCodeController.text,
        'productSize': productSizeController.text,
        'productCondition': _productCondition,
        'billDate': _selectedBillDate,
        'isBillAvailable': isBillAvailable,
        'productAging':
            _formatMonthAndYear(_productAgingYears, _productAgingMonths),
        'warrantyLimit': warrantyLeftController.text,
        'warrantyValidTill': _selectedWarrantyTillDate,
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
      final bool success =
          await _firebaseApiService.updateProduct(existingId, updateData);
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
    final String countryCode =
        Localizations.localeOf(context).countryCode ?? 'IN';
    final Product newProduct = Product(
      id: productId,
      isApproved: false,
      isSold: false,
      countryCode: countryCode,
      userId: FirebaseAuth.instance.currentUser?.uid,
      categoryId: selectedCategory?.categoryId ?? '',
      category: selectedCategory?.name ?? '',
      sellerContactNumber:
          '$selectedCountryCode ${sellerContactController.text}',
      sellerName: sellerNameController.text,
      sellerCategory: sellerCategory ?? 'Individual',
      subCategory: selectedSubcategory,
      modelName: accessoriesNameController.text,
      isProductBikeSpecific: isBikeSpecific,
      brandName: brandNameController.text,
      bikeBrandName: selectedBikeBrand ?? '',
      bikeModelName: modelNameController.text,
      bikeMfgDate: _selectedManufactureDate,
      state: selectedState ?? '',
      city: cityController.text,
      area: areaController.text,
      address: addressController.text,
      pinCode: pinCodeController.text,
      productSize: productSizeController.text,
      productCondition: _productCondition,
      billDate: _selectedBillDate,
      isBillAvailable: isBillAvailable,
      productAging: _formatMonthAndYear(_productAgingYears, _productAgingMonths),
      warrantyLimit: warrantyLeftController.text,
      warrantyValidTill: _selectedWarrantyTillDate,
      expectedPrice: priceController.text,
      price: priceController.text,
      additionalDetails: additionalDetailsController.text,
      createdAt: FieldValue.serverTimestamp(),
      searchKeywords: keywords,
    );

    AppLogger.d('Accessories product: ${newProduct.toJson()}');

    final bool success = await _firebaseApiService.submitProductForm(
      context: context,
      product: newProduct,
      images: _images,
      onLoading: _handleLoading,
    );

    if (success) {
      sellerNameController.clear();
      sellerContactController.clear();
      accessoriesNameController.clear();
      brandNameController.clear();
      modelNameController.clear();
      cityController.clear();
      areaController.clear();
      addressController.clear();
      pinCodeController.clear();
      priceController.clear();
      additionalDetailsController.clear();
      productSizeController.clear();
      warrantyLeftController.clear();
      setState(() {
        _images.clear();
        selectedState = null;
        sellerCategory = null;
        selectedCategory = null;
        selectedSubcategory = null;
        selectedBikeBrand = null;
        _productCondition = null;
        _selectedBillDate = null;
        _selectedManufactureDate = null;
        _selectedWarrantyTillDate = null;
        isBikeSpecific = false;
        isBillAvailable = false;
        isWarrantyAvailable = false;
        _productAgingYears = 0;
        _productAgingMonths = 0;
        _termsAccepted = false;
      });
      if (!mounted) return;
      AppDialogs.showProductSuccessDialog(context, () {
        onMyListingScreenTap(context, true);
      }, () {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  // ── Shared field padding ──────────────────────────────────────────────────

  Widget _field(Widget child) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 10.0), child: child);

  // ── Banner ────────────────────────────────────────────────────────────────

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: BikerverseColors.accentFill,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: BikerverseColors.accent.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: BikerverseColors.brightGreen),
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 8, 12),
              child: Icon(Icons.build_outlined,
                  color: BikerverseColors.brightGreen, size: 20),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 12, 12, 12),
                child: Text(
                  'Helmets, riding gear, parts & all bike accessories',
                  style: TextStyle(
                    color: BikerverseColors.textPrimary,
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

  // ── Listing Snapshot (Step 5 header) ─────────────────────────────────────

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: BikerverseColors.cardElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BikerverseColors.outline),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: BikerverseColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildListingSnapshot() {
    final name = accessoriesNameController.text;
    final brand = brandNameController.text;
    final category = selectedCategory?.name ?? '';
    final avatarLetter =
        name.isNotEmpty ? name[0].toUpperCase() : (category.isNotEmpty ? category[0].toUpperCase() : '?');

    final chips = <String>[];
    if (_productCondition != null) chips.add(_productCondition!);
    if (isBikeSpecific) chips.add('Bike specific');
    if (_selectedBillDate != null) {
      chips.add(DateFormat('MMM yyyy').format(_selectedBillDate!));
    }
    if (cityController.text.isNotEmpty) chips.add(cityController.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YOUR LISTING',
          style: TextStyle(
            color: BikerverseColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: BikerverseColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BikerverseColors.outline),
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
                      color: BikerverseColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      avatarLetter,
                      style: const TextStyle(
                        color: BikerverseColors.onGreen,
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
                            style: const TextStyle(
                              color: BikerverseColors.brightGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        Text(
                          name.isNotEmpty ? name : 'Your accessory',
                          style: const TextStyle(
                            color: BikerverseColors.textPrimary,
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
                      foregroundColor: BikerverseColors.textSecondary,
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

  // ── Step 1: Seller details ────────────────────────────────────────────────

  Widget _buildSellerStep(BuildContext context) {
    return Column(
      children: [
        _field(BottomSheetSelectorField<String>(
          value: sellerCategory,
          label: 'Seller Category',
          hint: 'Choose Category',
          prefixIcon: const Icon(Icons.person_outline,
              size: 20, color: BikerverseColors.textMuted),
          items: sellerCategories,
          labelBuilder: (item) => item,
          onChanged: (val) => setState(() => sellerCategory = val),
          validator: (val) => val == null ? 'Required' : null,
        )),
        _field(TextFormField(
          controller: sellerNameController,
          decoration: context.inputDecoration(
              'Seller Name', 'Enter your full name',
              icon: Icons.badge_outlined),
          validator: (val) => val!.isEmpty ? 'Required' : null,
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
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                controller: sellerContactController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration:
                    context.inputDecoration('Contact Number', 'Enter phone number'),
                validator: (val) => AppUtils.phoneValidator(val,
                    countryCode: selectedCountryCode),
              ),
            ),
          ],
        )),
      ],
    );
  }

  // ── Step 2: Product details ───────────────────────────────────────────────

  Widget _buildProductStep(BuildContext context) {
    return Column(
      children: [
        _field(CategorySelector(
          initialCategory: selectedCategory,
          initialSubcategory: selectedSubcategory,
          onCategoryChanged: (cat) => setState(() => selectedCategory = cat),
          onSubcategoryChanged: (sub) =>
              setState(() => selectedSubcategory = sub),
        )),
        _field(TextFormField(
          controller: accessoriesNameController,
          decoration: context.inputDecoration(
              'Accessories Name', 'Enter accessory name',
              icon: Icons.inventory_2_outlined),
          validator: (val) => val!.isEmpty ? 'Required' : null,
        )),
        _field(TextFormField(
          controller: brandNameController,
          decoration: context.inputDecoration('Brand Name', 'Enter brand name',
              icon: Icons.label_outline),
          validator: (val) => val!.isEmpty ? 'Required' : null,
        )),
        _field(TextFormField(
          controller: productSizeController,
          decoration: context.inputDecoration('Product Size', 'If applicable',
              icon: Icons.straighten_outlined),
        )),
        _field(BottomSheetSelectorField<String>(
          label: 'Product Condition',
          hint: 'Tap to select',
          value: _productCondition,
          prefixIcon: const Icon(Icons.star_outline,
              size: 20, color: BikerverseColors.textMuted),
          items: productConditionList,
          labelBuilder: (item) => item,
          onChanged: (val) => setState(() => _productCondition = val),
          validator: (val) =>
              val == null ? 'Please select product condition' : null,
        )),
        _field(SegmentedSelectorField(
          label: 'Is this product bike specific?',
          icon: Icons.two_wheeler_outlined,
          options: yesNo,
          value: isBikeSpecific ? 'Yes' : 'No',
          onChanged: (val) => setState(() {
            isBikeSpecific = val == 'Yes';
            if (!isBikeSpecific) _clearBikeSpecificFields();
          }),
        )),
        if (isBikeSpecific) ...[
          _field(BottomSheetSelectorField<String>(
            value: selectedBikeBrand,
            label: 'Bike Brand',
            hint: 'Choose brand',
            prefixIcon: const Icon(Icons.two_wheeler,
                size: 20, color: BikerverseColors.textMuted),
            items: bikeBrands,
            labelBuilder: (item) => item,
            onChanged: (val) => setState(() => selectedBikeBrand = val),
            validator: (val) =>
                isBikeSpecific && val == null ? 'Required' : null,
          )),
          _field(TextFormField(
            controller: modelNameController,
            decoration: context.inputDecoration(
                'Bike Model Name', 'e.g. TRIUMPH Tiger 1200',
                icon: Icons.directions_bike_outlined),
            validator: (val) =>
                isBikeSpecific && (val == null || val.isEmpty)
                    ? 'Required'
                    : null,
          )),
          _field(MonthYearPicker(
            enable: true,
            label: 'Bike Manufacture Date',
            hint: 'Select month and year',
            selectOnlyMonthYear: true,
            selectedDate: _selectedManufactureDate,
            onDateSelected: (date) =>
                setState(() => _selectedManufactureDate = date),
          )),
        ],
      ],
    );
  }

  // ── Step 3: Purchase & Warranty ───────────────────────────────────────────

  Widget _buildPurchaseStep(BuildContext context) {
    return Column(
      children: [
        _field(MonthYearPicker(
          label: 'Purchase Date',
          hint: 'Select month and year',
          selectOnlyMonthYear: true,
          selectedDate: _selectedBillDate,
          validator: (_) => _selectedBillDate == null ? 'Required' : null,
          onDateSelected: (date) {
            setState(() {
              _selectedBillDate = date;
              final age = AppUtils.calculateAge(_selectedBillDate);
              _productAgingYears = age['years'] ?? 0;
              _productAgingMonths = age['months'] ?? 0;
            });
          },
        )),
        _field(InputDecorator(
          decoration: context
              .inputDecoration('Product Age', '', enable: false)
              .copyWith(
                prefixIcon: const Icon(Icons.access_time_outlined,
                    size: 20, color: BikerverseColors.textMuted),
              ),
          isEmpty: _selectedBillDate == null,
          child: Text(
            _selectedBillDate == null
                ? 'Set purchase date to calculate'
                : _formatMonthAndYear(_productAgingYears, _productAgingMonths),
            style: TextStyle(
              color: _selectedBillDate == null
                  ? BikerverseColors.textMuted
                  : BikerverseColors.textPrimary,
              fontSize: 15,
            ),
          ),
        )),
        _field(SegmentedSelectorField(
          label: 'Bill available?',
          icon: Icons.receipt_long_outlined,
          options: yesNo,
          value: isBillAvailable ? 'Yes' : 'No',
          onChanged: (val) => setState(() => isBillAvailable = val == 'Yes'),
        )),
        _field(SegmentedSelectorField(
          label: 'Warranty available?',
          icon: Icons.verified_outlined,
          options: yesNo,
          value: isWarrantyAvailable ? 'Yes' : 'No',
          onChanged: (val) => setState(() {
            isWarrantyAvailable = val == 'Yes';
            if (!isWarrantyAvailable) _clearWarrantyFields();
          }),
        )),
        _field(MonthYearPicker(
          enable: isWarrantyAvailable,
          label: 'Warranty Valid Till',
          hint: 'Select month and year',
          selectOnlyMonthYear: true,
          selectedDate: _selectedWarrantyTillDate,
          validator: (_) {
            if (isWarrantyAvailable &&
                _selectedWarrantyTillDate != null &&
                _isPastMonth(_selectedWarrantyTillDate!)) {
              return 'Warranty valid till cannot be in the past';
            }
            return null;
          },
          onDateSelected: (date) {
            if (date != null && _isPastMonth(date)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Warranty valid till cannot be in the past.')),
              );
              return;
            }
            setState(() {
              _selectedWarrantyTillDate = date;
              warrantyLeftController.text = _remainingWarrantyText(date);
            });
          },
        )),
        _field(TextFormField(
          enabled: isWarrantyAvailable,
          readOnly: true,
          controller: warrantyLeftController,
          decoration: context.inputDecoration('Remaining Warranty',
              'Calculated from warranty valid till date',
              icon: Icons.timelapse_outlined),
        )),
      ],
    );
  }

  // ── Step 4: Location ──────────────────────────────────────────────────────

  Widget _buildLocationStep(BuildContext context) {
    return Column(
      children: [
        _field(BottomSheetSelectorField<String>(
          value: selectedState,
          label: 'State',
          hint: 'Select your state',
          prefixIcon: const Icon(Icons.map_outlined,
              size: 20, color: BikerverseColors.textMuted),
          items: stateNames,
          labelBuilder: (item) => item,
          onChanged: (val) => setState(() => selectedState = val),
          validator: (val) => val == null ? 'Required' : null,
        )),
        _field(TextFormField(
          controller: addressController,
          decoration: context.inputDecoration('Address', 'Enter address',
              icon: Icons.home_outlined),
          maxLines: 1,
          validator: (val) => val!.isEmpty ? 'Required' : null,
        )),
        _field(AutocompleteSearchField(
          label: 'Area',
          hint: 'Enter area name',
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
          validator: (val) => val!.isEmpty ? 'Required' : null,
        )),
        _field(TextFormField(
          controller: cityController,
          decoration: context.inputDecoration('City', 'Enter city name',
              icon: Icons.location_city_outlined),
          validator: (val) => val!.isEmpty ? 'Required' : null,
        )),
        _field(TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          textInputAction: TextInputAction.done,
          controller: pinCodeController,
          decoration: context.inputDecoration('Pin Code', 'Enter pin code',
              icon: Icons.pin_drop_outlined),
          validator: (val) {
            if (val == null || val.isEmpty) return 'Required';
            if (!RegExp(r'^[0-9]{6}$').hasMatch(val)) {
              return 'Enter a valid 6-digit pincode';
            }
            return null;
          },
        )),
      ],
    );
  }

  // ── Step 5: Pricing & Photos ──────────────────────────────────────────────

  Widget _buildPricingStep(BuildContext context) {
    return Column(
      children: [
        _field(_buildListingSnapshot()),
        _field(TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
          controller: priceController,
          decoration: context.inputDecoration(
              'Expected Price', 'Enter expected price',
              icon: Icons.currency_rupee),
          validator: (val) => val!.isEmpty ? 'Required' : null,
        )),
        _field(TextFormField(
          controller: additionalDetailsController,
          decoration: context.inputDecoration(
              'Additional Details', 'Any extra info...',
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
              onChanged: (val) =>
                  setState(() => _termsAccepted = val ?? false),
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
                      recognizer: TapGestureRecognizer()
                        ..onTap = _openTermsLink,
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

  // ── Discard changes ─────────────────────────────────────────────────────────

  bool _hasFormData() {
    final textControllers = <TextEditingController>[
      sellerNameController,
      accessoriesNameController,
      brandNameController,
      sellerContactController,
      modelNameController,
      priceController,
      additionalDetailsController,
      productSizeController,
      warrantyLeftController,
      addressController,
      cityController,
      areaController,
      pinCodeController,
    ];
    for (final c in textControllers) {
      if (c.text.trim().isNotEmpty) return true;
    }
    if (_images.isNotEmpty) return true;
    if (selectedState != null) return true;
    if (sellerCategory != null) return true;
    if (_selectedManufactureDate != null) return true;
    if (_selectedBillDate != null) return true;
    if (_selectedWarrantyTillDate != null) return true;
    if (_productCondition != null) return true;
    if (selectedCategory != null) return true;
    if (selectedSubcategory != null) return true;
    if (selectedBikeBrand != null) return true;
    if (isBikeSpecific) return true;
    if (isBillAvailable) return true;
    if (isWarrantyAvailable) return true;
    if (_termsAccepted) return true;
    if (_productAgingMonths != 0 || _productAgingYears != 0) return true;
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

  // ── Build ─────────────────────────────────────────────────────────────────

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
        appBarTitle:
            _isEditing ? 'Edit Your Accessories' : 'Sell Your Accessories',
        isLoading: _isLoading,
        allowStepJump: _isEditing,
        submitLabel: _isEditing ? 'Update' : 'Submit',
        onSubmit: _submitForm,
        controller: _stepController,
        banner: _buildBanner(),
        onBackPressed: _handleBackPressed,
        steps: [
          FormStep(
            title: 'Seller details',
            subtitle: 'Tell buyers who they\'re dealing with',
            formKey: _stepKeys[0],
            builder: _buildSellerStep,
          ),
          FormStep(
            title: 'Product details',
            subtitle: 'Describe what you\'re selling',
            formKey: _stepKeys[1],
            builder: _buildProductStep,
          ),
          FormStep(
            title: 'Purchase & Warranty',
            subtitle: 'When you bought it and coverage details',
            formKey: _stepKeys[2],
            builder: _buildPurchaseStep,
          ),
          FormStep(
            title: 'Location',
            subtitle: 'Where is the item located?',
            formKey: _stepKeys[3],
            builder: _buildLocationStep,
          ),
          FormStep(
            title: 'Pricing & photos',
            subtitle: 'Set your price and add photos',
            formKey: _stepKeys[4],
            builder: _buildPricingStep,
          ),
        ],
      ),
      ),
    );
  }
}
