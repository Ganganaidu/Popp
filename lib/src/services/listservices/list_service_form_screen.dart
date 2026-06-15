import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:popp/src/navigation/nav_router.dart';
import 'package:popp/src/theme/bikerverse_colors.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:popp/src/utils/product_utils.dart';
import 'package:popp/src/widgets/app_dialogs.dart';
import 'package:popp/src/widgets/bottom_sheet_selector_field.dart';
import 'package:popp/src/widgets/image_picker_selection.dart';
import 'package:popp/src/widgets/month_year_picker.dart';
import 'package:popp/src/widgets/stepped_form_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/api_url.dart';
import '../../api/firebase/firebase_api_service.dart';
import '../../api/firebase/remote_config_service.dart';
import '../../gallery/pic_image_gallery.dart';
import '../../search/autocomplete_search_field.dart';
import '../../utils/app_loger.dart';
import '../../utils/product_content_data.dart';
import '../../widgets/working_hours_picker.dart';

class ListServiceFormScreen extends StatefulWidget {
  final String? category;
  final Map<String, dynamic>? existingData;

  const ListServiceFormScreen({super.key, this.category, this.existingData});

  @override
  State<ListServiceFormScreen> createState() => _ListServiceFormScreenState();
}


class _ListServiceFormScreenState extends State<ListServiceFormScreen> {
  final FirebaseApiService _productsService = FirebaseApiService();
  final SteppedFormController _stepController = SteppedFormController();
  final List<GlobalKey<FormState>> _stepKeys =
      List.generate(5, (_) => GlobalKey<FormState>());

  // --- Common controllers ---
  final TextEditingController businessTitleController = TextEditingController();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController businessContactController =
      TextEditingController();
  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController businessDescriptionController =
      TextEditingController();
  final TextEditingController businessAddressController =
      TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController googleMapLinkController = TextEditingController();
  final TextEditingController socialMediaLinkController =
      TextEditingController();
  final TextEditingController businessWorkingDaysHoursController =
      TextEditingController();

  // --- Track Day / Training Day specific ---
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController maxSlotsController = TextEditingController();
  final TextEditingController eventDetailedDescriptionController =
      TextEditingController();
  final TextEditingController locationNameController = TextEditingController();
  final TextEditingController locationAddressController =
      TextEditingController();
  final TextEditingController googleFormLinkController =
      TextEditingController();

  // --- Towing Service specific ---
  final TextEditingController bikeRSAController = TextEditingController();
  final TextEditingController customTowingServiceTypeController =
      TextEditingController();

  final List<String> _selectedTowingServiceTypes = [];
  String? _serviceCoverageArea;

  String? _selectedCategory;
  String selectedCountryCode = '+91';
  final List<File> _promoImages = [];
  final List<File> _shopGarageImages = [];
  String? _doYouInspectPremiumBikes;
  String? _isTyreFitmentAvailable;
  String? _selectedState;
  String? _bikeProvision;
  String? _riderSkillLevel;
  DateTime? _eventStartDate;
  DateTime? _eventEndDate;
  TimeOfDay? _eventStartTime;
  TimeOfDay? _eventEndTime;

  bool _isLoading = false;
  bool _termsAccepted = false;
  bool _enableGallery = false;

  bool get _isEditing => widget.existingData != null;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  TimeOfDay? _parseTime(String? s) {
    if (s == null || s.isEmpty) return null;
    final parts = s.split(':');
    if (parts.length < 2) return null;
    int h = int.tryParse(parts[0]) ?? 0;
    final minPart = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
    int m = int.tryParse(minPart) ?? 0;
    final lower = s.toLowerCase();
    if (lower.contains('pm') && h != 12) h += 12;
    if (lower.contains('am') && h == 12) h = 0;
    return TimeOfDay(hour: h, minute: m);
  }

  void _initFromExistingData(Map<String, dynamic> data) {
    businessTitleController.text = data['businessTitle'] ?? '';
    shopNameController.text = data['shopName'] ?? '';
    businessDescriptionController.text =
        data['businessDescription'] ?? data['eventDetailedDescription'] ?? '';
    contactNameController.text =
        data['contactName'] ?? data['pointOfContactName'] ?? '';
    gstController.text = data['gstNumber'] ?? '';
    businessAddressController.text =
        data['businessAddress'] ?? data['locationAddress'] ?? '';
    areaController.text = data['area'] ?? '';
    cityController.text = data['city'] ?? '';
    pincodeController.text = data['pincode'] ?? '';
    googleMapLinkController.text = data['googleMapLink'] ?? '';
    socialMediaLinkController.text = data['socialMediaLink'] ?? '';
    businessWorkingDaysHoursController.text =
        data['businessWorkingDaysHours'] ?? data['workingHours'] ?? '';

    final contact =
        (data['businessContact'] ?? data['contact'] ?? '') as String;
    final spaceIdx = contact.indexOf(' ');
    if (spaceIdx > 0) {
      selectedCountryCode = contact.substring(0, spaceIdx);
      businessContactController.text = contact.substring(spaceIdx + 1);
    } else {
      businessContactController.text = contact;
    }

    _selectedState = data['state'] as String?;
    _doYouInspectPremiumBikes = data['doYouInspectPremiumBikes'] as String?;
    _isTyreFitmentAvailable = data['isTyreFitmentAvailable'] as String?;
    bikeRSAController.text = data['bikeRSA'] ?? '';
    _serviceCoverageArea = data['serviceCoverageArea'] as String?;

    final towingTypes = data['towingServiceType'];
    if (towingTypes is List) {
      _selectedTowingServiceTypes.addAll(towingTypes.cast<String>());
    }

    eventNameController.text = data['eventName'] ?? '';
    maxSlotsController.text = data['maxSlots'] ?? '';
    eventDetailedDescriptionController.text =
        data['eventDetailedDescription'] ?? '';
    locationNameController.text = data['locationName'] ?? '';
    locationAddressController.text = data['locationAddress'] ?? '';
    googleFormLinkController.text = data['googleFormLink'] ?? '';
    _bikeProvision = data['bikeProvision'] as String?;
    _riderSkillLevel = data['riderSkillLevel'] as String?;

    final startDateStr = data['eventStartDate'] as String?;
    if (startDateStr != null) {
      try {
        _eventStartDate = DateTime.parse(startDateStr);
      } catch (_) {}
    }
    final endDateStr = data['eventEndDate'] as String?;
    if (endDateStr != null) {
      try {
        _eventEndDate = DateTime.parse(endDateStr);
      } catch (_) {}
    }
    _eventStartTime = _parseTime(data['eventStartTime'] as String?);
    _eventEndTime = _parseTime(data['eventEndTime'] as String?);
    _termsAccepted = true;
  }

  @override
  void initState() {
    super.initState();
    if (widget.category != null) _selectedCategory = widget.category;
    if (widget.existingData != null) {
      _selectedCategory ??= widget.existingData!['category'] as String?;
      _initFromExistingData(widget.existingData!);
    }
    _loadConfig();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedCategory == null) _showCategorySelectionSheet();
    });
  }

  void _loadConfig() async {
    final configService = await RemoteConfigService.getInstance();
    setState(() => _enableGallery = configService.enableGallery);
  }

  @override
  void dispose() {
    businessTitleController.dispose();
    shopNameController.dispose();
    businessContactController.dispose();
    contactNameController.dispose();
    gstController.dispose();
    businessDescriptionController.dispose();
    businessAddressController.dispose();
    areaController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    googleMapLinkController.dispose();
    socialMediaLinkController.dispose();
    businessWorkingDaysHoursController.dispose();
    eventNameController.dispose();
    maxSlotsController.dispose();
    eventDetailedDescriptionController.dispose();
    locationNameController.dispose();
    locationAddressController.dispose();
    googleFormLinkController.dispose();
    bikeRSAController.dispose();
    customTowingServiceTypeController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Widget _field(Widget child) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: child);

  Widget _buildChip(String label) => Container(
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

  Widget _buildCountryCodeRow(BuildContext context,
      {required String label, required String hint}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: BikerverseColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: BikerverseColors.outline),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCountryCode,
              dropdownColor: BikerverseColors.surface,
              style: const TextStyle(
                  color: BikerverseColors.textPrimary, fontSize: 15),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              items: countryCodes
                  .map((code) => DropdownMenuItem(
                        value: code,
                        child: Text(code,
                            style: const TextStyle(
                                color: BikerverseColors.textPrimary)),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedCountryCode = val!),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: businessContactController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: context.inputDecoration(label, hint),
            validator: (val) =>
                val!.isEmpty ? '$label is mandatory' : null,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Category selection sheet (dark-themed)
  // ---------------------------------------------------------------------------

  void _showCategorySelectionSheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: BikerverseColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select Service Category',
                      style: TextStyle(
                        color: BikerverseColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: BikerverseColors.textMuted),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: BikerverseColors.divider, height: 1),
            const SizedBox(height: 8),
            ...ProductUtils.listYourServiceCategories.map(
              (category) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: InkWell(
                  onTap: () => Navigator.of(ctx).pop(category),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: BikerverseColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: BikerverseColors.outline),
                    ),
                    child: Text(
                      category,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: BikerverseColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (selected != null) {
      if (selected != _selectedCategory) {
        _clearAllFields();
        setState(() => _selectedCategory = selected);
      }
    } else {
      if (_selectedCategory == null) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Form state
  // ---------------------------------------------------------------------------

  void _clearAllFields() {
    for (final key in _stepKeys) {
      key.currentState?.reset();
    }
    businessTitleController.clear();
    shopNameController.clear();
    businessContactController.clear();
    contactNameController.clear();
    gstController.clear();
    businessDescriptionController.clear();
    businessAddressController.clear();
    areaController.clear();
    cityController.clear();
    pincodeController.clear();
    googleMapLinkController.clear();
    socialMediaLinkController.clear();
    businessWorkingDaysHoursController.clear();
    eventNameController.clear();
    maxSlotsController.clear();
    eventDetailedDescriptionController.clear();
    locationNameController.clear();
    locationAddressController.clear();
    googleFormLinkController.clear();
    bikeRSAController.clear();
    customTowingServiceTypeController.clear();

    setState(() {
      _promoImages.clear();
      _shopGarageImages.clear();
      _selectedState = null;
      _bikeProvision = null;
      _riderSkillLevel = null;
      _eventStartDate = null;
      _eventEndDate = null;
      _eventStartTime = null;
      _eventEndTime = null;
      _termsAccepted = false;
      _doYouInspectPremiumBikes = null;
      _isTyreFitmentAvailable = null;
      _selectedTowingServiceTypes.clear();
      _serviceCoverageArea = null;
    });
    _stepController.jumpTo(0);
  }

  bool _hasFormData() {
    final textControllers = <TextEditingController>[
      businessTitleController,
      shopNameController,
      businessContactController,
      contactNameController,
      gstController,
      businessDescriptionController,
      businessAddressController,
      areaController,
      cityController,
      pincodeController,
      googleMapLinkController,
      socialMediaLinkController,
      businessWorkingDaysHoursController,
      eventNameController,
      maxSlotsController,
      eventDetailedDescriptionController,
      locationNameController,
      locationAddressController,
      googleFormLinkController,
      bikeRSAController,
      customTowingServiceTypeController,
    ];
    for (final c in textControllers) {
      if (c.text.trim().isNotEmpty) return true;
    }
    if (_promoImages.isNotEmpty) return true;
    if (_shopGarageImages.isNotEmpty) return true;
    if (_selectedState != null) return true;
    if (_bikeProvision != null) return true;
    if (_riderSkillLevel != null) return true;
    if (_selectedTowingServiceTypes.isNotEmpty) return true;
    if (_serviceCoverageArea != null) return true;
    if (_eventStartDate != null || _eventEndDate != null) return true;
    if (_eventStartTime != null || _eventEndTime != null) return true;
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

  // ---------------------------------------------------------------------------
  // Terms link
  // ---------------------------------------------------------------------------

  void _openTermsLink() async {
    AppLogger.w('Terms link clicked');
    final uri = Uri.parse(ApiUrl.customersTermsLink);
    final launched = await launchUrl(uri);
    if (launched) {
      setState(() => _termsAccepted = true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not open Terms & Conditions link.')),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> _handleLoading(bool isLoading) async {
    if (mounted) setState(() => _isLoading = isLoading);
  }

  Future<void> _submitForm() async {
    if (_selectedCategory == null) return;

    Map<String, dynamic> formData = {};
    final String countryCode =
        Localizations.localeOf(context).countryCode ?? 'IN';

    if (ProductUtils.isBikeAndOthersCategory(_selectedCategory)) {
      formData.addAll({
        'isActive': true,
        'category': _selectedCategory,
        'shopName': shopNameController.text,
        'businessTitle': businessTitleController.text,
        'businessDescription': businessDescriptionController.text,
        'businessContact':
            '$selectedCountryCode ${businessContactController.text}',
        'contactName': contactNameController.text,
        'state': _selectedState,
        'area': areaController.text,
        'city': cityController.text,
        'businessAddress': businessAddressController.text,
        'pincode': pincodeController.text,
        'gstNumber': gstController.text,
        'doYouInspectPremiumBikes': _doYouInspectPremiumBikes,
        'isTyreFitmentAvailable': _isTyreFitmentAvailable,
        'bikeRSA': bikeRSAController.text,
        'towingServiceType': _selectedTowingServiceTypes
            .map((type) => type == 'Others'
                ? customTowingServiceTypeController.text
                : type)
            .toList(),
        'serviceCoverageArea': _serviceCoverageArea,
        'googleMapLink': googleMapLinkController.text,
        'socialMediaLink': socialMediaLinkController.text,
        'businessWorkingDaysHours': businessWorkingDaysHoursController.text,
        'businessPromoPicture': _promoImages.map((e) => e.path).toList(),
        'shopGaragePics': _shopGarageImages.map((e) => e.path).toList(),
        'searchKeywords':
            '${businessTitleController.text} ${areaController.text} '
                    '${cityController.text} $_selectedCategory '
                    '${shopNameController.text} '
                .toLowerCase()
                .split(' '),
        'countryCode': countryCode,
      });
    } else if (ProductUtils.isTrackAndTrainingCategory(_selectedCategory)) {
      formData.addAll({
        'isActive': true,
        'countryCode': countryCode,
        'category': _selectedCategory,
        'eventName': eventNameController.text,
        'eventPromoPicture': _promoImages.map((e) => e.path).toList(),
        'searchKeywords': '${eventNameController.text} $_selectedCategory '
                '${locationAddressController.text} '
                '${locationNameController.text}'
                '${cityController.text}'
                '${areaController.text}'
                'events'
                ' ${businessContactController.text}'
            .toLowerCase()
            .split(' '),
        'bikeTypeModel': null,
        'bikeProvision': _bikeProvision,
        'riderSkillLevel': _riderSkillLevel,
        'eventStartDate': _eventStartDate?.toIso8601String(),
        'eventEndDate': _eventEndDate?.toIso8601String(),
        'eventStartTime': _eventStartTime?.format(context),
        'eventEndTime': _eventEndTime?.format(context),
        'maxSlots': maxSlotsController.text,
        'eventDetailedDescription': eventDetailedDescriptionController.text,
        'locationName': locationNameController.text,
        'locationAddress': locationAddressController.text,
        'area': areaController.text,
        'city': cityController.text,
        'state': _selectedState,
        'pincode': pincodeController.text,
        'gstNumber': gstController.text,
        'googleMapLink': googleMapLinkController.text,
        'googleFormLink': googleFormLinkController.text,
        'socialMediaLink': socialMediaLinkController.text,
        'contact': businessContactController.text,
        'pointOfContactName': contactNameController.text,
      });
    } else if (_selectedCategory == ProductUtils.towingService) {
      formData.addAll({
        'isActive': true,
        'category': _selectedCategory,
        'shopName': shopNameController.text,
        'businessTitle': businessTitleController.text,
        'bikeRSA': bikeRSAController.text,
        'businessDescription': businessDescriptionController.text,
        'towingServiceType': _selectedTowingServiceTypes
            .map((type) => type == 'Others'
                ? customTowingServiceTypeController.text
                : type)
            .toList(),
        'serviceCoverageArea': _serviceCoverageArea,
        'businessAddress': businessAddressController.text,
        'area': areaController.text,
        'city': cityController.text,
        'state': _selectedState,
        'pincode': pincodeController.text,
        'contactName': contactNameController.text,
        'businessContact':
            '$selectedCountryCode ${businessContactController.text}',
        'gstNumber': gstController.text,
        'googleMapLink': googleMapLinkController.text,
        'socialMediaLink': socialMediaLinkController.text,
        'businessWorkingDaysHours': businessWorkingDaysHoursController.text,
        'businessPromoPicture': _promoImages.map((e) => e.path).toList(),
        'shopGaragePics': _shopGarageImages.map((e) => e.path).toList(),
        'searchKeywords':
            '${shopNameController.text} ${areaController.text} '
                    '${cityController.text} $_selectedCategory '
                    '${businessTitleController.text} '
                .toLowerCase()
                .split(' '),
        'countryCode': countryCode,
      });
    }

    if (_isEditing) {
      final String serviceId = widget.existingData!['id'];
      final existingPromo =
          (widget.existingData!['promoImageUrls'] as List? ?? []).cast<String>();
      final existingShop =
          (widget.existingData!['shopImageUrls'] as List? ?? []).cast<String>();

      List<String> promoUrls = existingPromo;
      if (_promoImages.isNotEmpty) {
        final uploaded = await uploadMultipleImages(_promoImages);
        if (uploaded.isNotEmpty) promoUrls = uploaded;
      }

      List<String> shopUrls = existingShop;
      if (_shopGarageImages.isNotEmpty) {
        final uploaded = await uploadMultipleImages(_shopGarageImages);
        if (uploaded.isNotEmpty) shopUrls = uploaded;
      }

      formData['promoImageUrls'] = promoUrls;
      formData['shopImageUrls'] = shopUrls;
      formData['status'] = 'pending';
      formData['isApproved'] = false;

      await _handleLoading(true);
      final bool success =
          await _productsService.updateService(serviceId, formData);
      await _handleLoading(false);

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service updated! It is under review.')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update failed. Please try again.')),
        );
      }
      return;
    }

    bool success = await _productsService.submitListServicesForm(
      context: context,
      data: formData,
      promoImages: _promoImages,
      shopGarageImages: _shopGarageImages,
      onLoading: _handleLoading,
    );

    AppLogger.d('Form submission success: $success');
    if (success) {
      _clearAllFields();
      if (!mounted) return;
      AppLogger.d('Form submission navigate to : $_selectedCategory');
      await AppDialogs.showServiceSubmitDialog(context, _selectedCategory!, () {
        onServiceListingTap(context, _selectedCategory!, null, true);
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Listing snapshot (Step 5)
  // ---------------------------------------------------------------------------

  Widget _buildListingSnapshot(BuildContext context) {
    final isTrack = ProductUtils.isTrackAndTrainingCategory(_selectedCategory);
    final name = isTrack
        ? (eventNameController.text.isNotEmpty
            ? eventNameController.text
            : (_selectedCategory ?? 'Event'))
        : (shopNameController.text.isNotEmpty
            ? shopNameController.text
            : (_selectedCategory ?? 'Service'));
    final letter = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    final subtitle = isTrack
        ? businessContactController.text
        : businessTitleController.text;

    final chips = <String>[
      if (!isTrack && _selectedCategory != null) _selectedCategory!,
      if (isTrack && _bikeProvision != null) 'Bikes: $_bikeProvision',
      if (isTrack && _riderSkillLevel != null) _riderSkillLevel!,
      if (isTrack && _eventStartDate != null)
        DateFormat('d MMM yyyy').format(_eventStartDate!),
      if (_selectedState != null) _selectedState!,
      if (cityController.text.isNotEmpty) cityController.text,
    ];

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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: BikerverseColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BikerverseColors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: BikerverseColors.accent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: const TextStyle(
                        color: BikerverseColors.onGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCategory?.toUpperCase() ?? '',
                          style: const TextStyle(
                            color: BikerverseColors.brightGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          name,
                          style: const TextStyle(
                            color: BikerverseColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: BikerverseColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _stepController.jumpTo(0),
                    icon: const Icon(Icons.edit_outlined,
                        size: 14, color: BikerverseColors.accent),
                    label: const Text(
                      'Edit',
                      style: TextStyle(
                          color: BikerverseColors.accent, fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              if (chips.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: chips.map(_buildChip).toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Terms field (used in every Step 5)
  // ---------------------------------------------------------------------------

  Widget _buildTermsField(BuildContext context) {
    return FormField<bool>(
      initialValue: _termsAccepted,
      validator: (val) =>
          (val != true) ? 'Please accept the Terms & Conditions' : null,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _termsAccepted,
                activeColor: BikerverseColors.accent,
                onChanged: (v) {
                  setState(() => _termsAccepted = v ?? false);
                  state.didChange(v ?? false);
                },
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        color: BikerverseColors.textSecondary, fontSize: 14),
                    children: [
                      const TextSpan(text: 'I have read and agree to the '),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: const TextStyle(
                          color: BikerverseColors.brightGreen,
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
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 2),
              child: Text(
                state.errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Towing multi-select field
  // ---------------------------------------------------------------------------

  static const _towingTypes = [
    'Flatbed Tow Truck',
    'Hydraulic Lift Tow Truck',
    'Pickup Truck',
    'Motorcycle Trailer',
    'Wheel Clamp Towing',
    'Others',
  ];

  Widget _buildTowingTypesField(BuildContext context) {
    final selectedText = _selectedTowingServiceTypes.isEmpty
        ? null
        : _selectedTowingServiceTypes.join(', ');

    return FormField<List<String>>(
      initialValue: List.from(_selectedTowingServiceTypes),
      validator: (val) =>
          (val == null || val.isEmpty) ? 'Select at least one service type' : null,
      builder: (state) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showTowingTypeSheet(state),
          child: InputDecorator(
            decoration: context
                .inputDecoration('Towing Service Types', 'Select all that apply')
                .copyWith(
                  suffixIcon: const Icon(Icons.keyboard_arrow_down,
                      color: Colors.grey),
                  errorText: state.hasError ? state.errorText : null,
                ),
            isEmpty: selectedText == null,
            child: selectedText != null
                ? Text(
                    selectedText,
                    style: const TextStyle(
                        color: BikerverseColors.textPrimary, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
          ),
        );
      },
    );
  }

  void _showTowingTypeSheet(FormFieldState<List<String>> state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: BikerverseColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, scrollController) => Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: BikerverseColors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Towing Service Types',
                      style: TextStyle(
                        color: BikerverseColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const Divider(color: BikerverseColors.divider, height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: _towingTypes.map((item) {
                      final isSelected =
                          _selectedTowingServiceTypes.contains(item);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 3),
                        child: InkWell(
                          onTap: () {
                            setSheetState(() {
                              if (isSelected) {
                                _selectedTowingServiceTypes.remove(item);
                              } else {
                                _selectedTowingServiceTypes.add(item);
                              }
                            });
                            setState(() {});
                            state.didChange(
                                List.from(_selectedTowingServiceTypes));
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: isSelected
                                ? BoxDecoration(
                                    color: BikerverseColors.accentFill,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: BikerverseColors.accent
                                          .withValues(alpha: 0.3),
                                    ),
                                  )
                                : null,
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_box_rounded
                                      : Icons.check_box_outline_blank_rounded,
                                  color: isSelected
                                      ? BikerverseColors.accent
                                      : BikerverseColors.textMuted,
                                  size: 22,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      color: isSelected
                                          ? BikerverseColors.textPrimary
                                          : BikerverseColors.textSecondary,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BikerverseColors.accent,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                      child: const Text('Done',
                          style: TextStyle(
                              color: BikerverseColors.onGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BIKE & OTHERS steps
  // ---------------------------------------------------------------------------

  Widget _buildBikeStep1(BuildContext context) => Column(
        children: [
          _field(TextFormField(
            controller: shopNameController,
            decoration: context.inputDecoration(
                'Shop name',
                ProductUtils.getShopNameHint(_selectedCategory)),
            validator: (val) =>
                val!.isEmpty ? 'Shop name is mandatory' : null,
          )),
          _field(TextFormField(
            controller: businessTitleController,
            decoration: context.inputDecoration(
                'Business name', 'As per GST or official records'),
            validator: (val) =>
                val!.isEmpty ? 'Business name is mandatory' : null,
          )),
          _field(TextFormField(
            controller: businessDescriptionController,
            maxLines: 3,
            decoration: context.inputDecoration(
                'Business description',
                ProductUtils.getBusinessDescriptionHint(_selectedCategory)),
            validator: (val) =>
                val!.isEmpty ? 'Business description is mandatory' : null,
          )),
          if (_selectedCategory == ProductUtils.findMechanic)
            _field(BottomSheetSelectorField<String>(
              label: 'Premium Bike Inspection',
              hint: 'Would you offer a premium bike inspection?',
              value: _doYouInspectPremiumBikes,
              items: yesNo,
              labelBuilder: (s) => s,
              onChanged: (val) =>
                  setState(() => _doYouInspectPremiumBikes = val),
            )),
          if (_selectedCategory == ProductUtils.tyreShop)
            _field(BottomSheetSelectorField<String>(
              label: 'Tyre Fitment',
              hint: 'Is tyre fitment available?',
              value: _isTyreFitmentAvailable,
              items: yesNo,
              labelBuilder: (s) => s,
              onChanged: (val) =>
                  setState(() => _isTyreFitmentAvailable = val),
            )),
        ],
      );

  Widget _buildBikeStep2(BuildContext context) => Column(
        children: [
          _field(_buildCountryCodeRow(context,
              label: 'Business contact',
              hint: 'Enter business contact number')),
          _field(TextFormField(
            controller: contactNameController,
            decoration: context.inputDecoration(
                'Contact name', "Enter contact person's name"),
            validator: (val) =>
                val!.isEmpty ? 'Contact name is mandatory' : null,
          )),
          _field(BottomSheetSelectorField<String>(
            label: 'State',
            hint: 'Select your state',
            value: _selectedState,
            items: stateNames,
            labelBuilder: (s) => s,
            onChanged: (val) => setState(() => _selectedState = val),
            validator: (val) => val == null ? 'State is required' : null,
          )),
        ],
      );

  Widget _buildBikeStep3(BuildContext context) => Column(
        children: [
          _field(TextFormField(
            controller: businessAddressController,
            decoration: context.inputDecoration(
                'Address', 'Enter your shop/garage address'),
            validator: (val) =>
                val!.isEmpty ? 'Address is mandatory' : null,
          )),
          const SizedBox(height: 8),
          AutocompleteSearchField(
            label: 'Area',
            hint: 'Enter area details',
            controller: areaController,
            icon: null,
            lat: stateCoordinates[_selectedState]?['lat'] ?? 0.0,
            lon: stateCoordinates[_selectedState]?['lon'] ?? 0.0,
            onPlaceSelected: (suggestion) => setState(() {
              areaController.text = suggestion.text;
              cityController.text = suggestion.municipality ?? '';
              pincodeController.text = suggestion.postalCode ?? '';
            }),
            validator: (val) => val!.isEmpty ? 'Area is required' : null,
          ),
          const SizedBox(height: 8),
          _field(TextFormField(
            controller: cityController,
            decoration:
                context.inputDecoration('City', 'Enter city name'),
            validator: (val) =>
                val!.isEmpty ? 'City is mandatory' : null,
          )),
          _field(TextFormField(
            controller: pincodeController,
            keyboardType: TextInputType.text,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
            decoration:
                context.inputDecoration('Pin code', 'Enter pin code'),
            validator: (val) =>
                val!.isEmpty ? 'Pin code is mandatory' : null,
          )),
          _field(TextFormField(
            controller: gstController,
            decoration: context.inputDecoration('GST #', 'Enter GST number'),
            validator: (val) =>
                val!.isEmpty ? 'GST number is mandatory' : null,
          )),
        ],
      );

  Widget _buildBikeStep4(BuildContext context) => Column(
        children: [
          _field(TextFormField(
            controller: googleMapLinkController,
            decoration: context.inputDecoration(
                'Google Map link', 'Enter Google Maps link (optional)'),
          )),
          _field(TextFormField(
            controller: socialMediaLinkController,
            decoration: context.inputDecoration(
                'Social media link', 'Enter social media link (optional)'),
          )),
          _field(WorkingHoursPicker(
            label: 'Business working days & hours',
            hint: 'Select working days and hours',
            controller: businessWorkingDaysHoursController,
            onChanged: (_) => setState(() {}),
            validator: (val) =>
                val!.isEmpty || val == 'No days selected, No time selected'
                    ? 'Working days and hours are mandatory'
                    : null,
          )),
        ],
      );

  Widget _buildBikeStep5(BuildContext context) => Column(
        children: [
          _buildListingSnapshot(context),
          _field(ImagePickerSection(
            title: 'Promo / advertising pictures',
            allowGallery: _enableGallery,
            allowMultipleImages: _enableGallery,
            images: _promoImages,
            onImagesChanged: (imgs) => setState(() {
              _promoImages
                ..clear()
                ..addAll(imgs);
            }),
          )),
          _field(ImagePickerSection(
            title: 'Shop / garage pictures',
            allowGallery: _enableGallery,
            allowMultipleImages: _enableGallery,
            images: _shopGarageImages,
            onImagesChanged: (imgs) => setState(() {
              _shopGarageImages
                ..clear()
                ..addAll(imgs);
            }),
          )),
          _field(_buildTermsField(context)),
        ],
      );

  // ---------------------------------------------------------------------------
  // TRACK & TRAINING steps
  // ---------------------------------------------------------------------------

  Widget _buildTrackStep1(BuildContext context) => Column(
        children: [
          _field(TextFormField(
            controller: eventNameController,
            decoration: context.inputDecoration(
                'Event name', 'Enter the event name'),
            validator: (val) =>
                val!.isEmpty ? 'Event name is mandatory' : null,
          )),
          _field(_buildCountryCodeRow(context,
              label: 'Contact', hint: 'Enter contact number')),
          _field(TextFormField(
            controller: contactNameController,
            decoration: context.inputDecoration(
                'Point of contact name', 'Enter point of contact name'),
            validator: (val) =>
                val!.isEmpty ? 'Contact name is mandatory' : null,
          )),
        ],
      );

  Widget _buildTrackStep2(BuildContext context) => Column(
        children: [
          _field(TextFormField(
            decoration: context.inputDecoration(
                'Bike type / model', 'e.g. Any Superbike, 600cc+ (optional)'),
          )),
          _field(BottomSheetSelectorField<String>(
            label: 'Bike provision',
            hint: 'Self / Organizer',
            value: _bikeProvision,
            items: const ['Self', 'Organizer'],
            labelBuilder: (s) => s,
            onChanged: (val) => setState(() => _bikeProvision = val),
            validator: (val) =>
                val == null ? 'Bike provision is mandatory' : null,
          )),
          _field(BottomSheetSelectorField<String>(
            label: 'Rider skill level',
            hint: 'Select skill level',
            value: _riderSkillLevel,
            items: riderSkillLevels,
            labelBuilder: (s) => s,
            onChanged: (val) => setState(() => _riderSkillLevel = val),
            validator: (val) =>
                val == null ? 'Rider skill level is mandatory' : null,
          )),
          _field(MonthYearPicker(
            enable: true,
            label: 'Event start date',
            hint: 'Select start date',
            selectedDate: _eventStartDate,
            onDateSelected: (d) => setState(() => _eventStartDate = d),
            validator: (d) =>
                d == null ? 'Event start date is mandatory' : null,
          )),
          _field(MonthYearPicker(
            enable: true,
            label: 'Event end date',
            hint: 'Select end date',
            selectedDate: _eventEndDate,
            onDateSelected: (d) => setState(() => _eventEndDate = d),
            validator: (d) =>
                d == null ? 'Event end date is mandatory' : null,
          )),
          _field(_buildTimePicker(context,
              label: 'Event start time',
              value: _eventStartTime,
              onChanged: (t) => setState(() => _eventStartTime = t),
              validator: (t) =>
                  t == null ? 'Event start time is mandatory' : null)),
          _field(_buildTimePicker(context,
              label: 'Event end time',
              value: _eventEndTime,
              onChanged: (t) => setState(() => _eventEndTime = t),
              validator: (t) =>
                  t == null ? 'Event end time is mandatory' : null)),
          _field(TextFormField(
            controller: maxSlotsController,
            keyboardType: TextInputType.text,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
            decoration: context.inputDecoration(
                'Max slots', 'Enter maximum slots available'),
            validator: (val) =>
                val!.isEmpty ? 'Max slots is mandatory' : null,
          )),
        ],
      );

  Widget _buildTimePicker(
    BuildContext context, {
    required String label,
    required TimeOfDay? value,
    required ValueChanged<TimeOfDay?> onChanged,
    required FormFieldValidator<TimeOfDay> validator,
  }) {
    return FormField<TimeOfDay>(
      initialValue: value,
      validator: validator,
      builder: (state) => InkWell(
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: state.value ?? TimeOfDay.now(),
          );
          if (picked != null) {
            state.didChange(picked);
            onChanged(picked);
          }
        },
        child: InputDecorator(
          decoration: context
              .inputDecoration(label, state.value?.format(context) ?? 'Select time')
              .copyWith(errorText: state.errorText),
          child: Text(
            state.value?.format(context) ?? 'Select time',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildTrackStep3(BuildContext context) => Column(
        children: [
          _field(TextFormField(
            controller: locationNameController,
            decoration: context.inputDecoration(
                'Location name', 'Enter name of the location'),
            validator: (val) =>
                val!.isEmpty ? 'Location name is mandatory' : null,
          )),
          _field(BottomSheetSelectorField<String>(
            label: 'State',
            hint: 'Select your state',
            value: _selectedState,
            items: stateNames,
            labelBuilder: (s) => s,
            onChanged: (val) => setState(() => _selectedState = val),
            validator: (val) => val == null ? 'State is required' : null,
          )),
          const SizedBox(height: 8),
          AutocompleteSearchField(
            label: 'Location address',
            hint: 'Enter location address with landmark',
            controller: locationAddressController,
            icon: null,
            lat: stateCoordinates[_selectedState]?['lat'] ?? 0.0,
            lon: stateCoordinates[_selectedState]?['lon'] ?? 0.0,
            onPlaceSelected: (suggestion) => setState(() {
              businessAddressController.text = suggestion.text;
              cityController.text = suggestion.municipality ?? '';
              pincodeController.text = suggestion.postalCode ?? '';
            }),
            validator: (val) => val!.isEmpty ? 'Address is required' : null,
          ),
          const SizedBox(height: 8),
          _field(TextFormField(
            controller: areaController,
            decoration:
                context.inputDecoration('Area', 'Enter area'),
            validator: (val) =>
                val!.isEmpty ? 'Area is mandatory' : null,
          )),
          _field(TextFormField(
            controller: cityController,
            decoration:
                context.inputDecoration('City', 'Enter city name'),
            validator: (val) =>
                val!.isEmpty ? 'City is mandatory' : null,
          )),
          _field(TextFormField(
            controller: pincodeController,
            keyboardType: TextInputType.text,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
            decoration:
                context.inputDecoration('Pin code', 'Enter pin code'),
            validator: (val) =>
                val!.isEmpty ? 'Pin code is mandatory' : null,
          )),
        ],
      );

  Widget _buildTrackStep4(BuildContext context) => Column(
        children: [
          _field(TextFormField(
            controller: eventDetailedDescriptionController,
            maxLines: 4,
            decoration: context.inputDecoration(
                'Event description',
                'Rider briefing, requirements and clauses'),
            validator: (val) =>
                val!.isEmpty ? 'Event description is mandatory' : null,
          )),
          _field(TextFormField(
            controller: gstController,
            decoration: context.inputDecoration(
                'GST #', 'Enter GST number (optional)'),
          )),
          _field(TextFormField(
            controller: googleMapLinkController,
            decoration: context.inputDecoration(
                'Google Map link', 'Enter Google Maps link (optional)'),
          )),
          _field(TextFormField(
            controller: googleFormLinkController,
            decoration: context.inputDecoration(
                'Google Form / redirect link',
                'Enter booking form or redirect link (optional)'),
          )),
          _field(TextFormField(
            controller: socialMediaLinkController,
            decoration: context.inputDecoration(
                'Social media link', 'Enter social media link (optional)'),
          )),
        ],
      );

  Widget _buildTrackStep5(BuildContext context) => Column(
        children: [
          _buildListingSnapshot(context),
          _field(ImagePickerSection(
            title: 'Event promo pictures',
            allowGallery: _enableGallery,
            allowMultipleImages: _enableGallery,
            images: _promoImages,
            onImagesChanged: (imgs) => setState(() {
              _promoImages
                ..clear()
                ..addAll(imgs);
            }),
          )),
          _field(_buildTermsField(context)),
        ],
      );

  // ---------------------------------------------------------------------------
  // TOWING SERVICE steps
  // ---------------------------------------------------------------------------

  Widget _buildTowingStep1(BuildContext context) => Column(
        children: [
          _field(TextFormField(
            controller: shopNameController,
            decoration: context.inputDecoration('Towing service name',
                ProductUtils.getShopNameHint(_selectedCategory)),
            validator: (val) =>
                val!.isEmpty ? 'Towing service name is mandatory' : null,
          )),
          _field(TextFormField(
            controller: businessTitleController,
            decoration: context.inputDecoration(
                'Business name', 'As per GST or official records'),
            validator: (val) =>
                val!.isEmpty ? 'Business name is mandatory' : null,
          )),
          _field(TextFormField(
            controller: bikeRSAController,
            decoration: context.inputDecoration(
                'Bike RSA', 'Enter Bike RSA details'),
            validator: (val) =>
                val!.isEmpty ? 'Bike RSA is mandatory' : null,
          )),
          _field(TextFormField(
            controller: businessDescriptionController,
            maxLines: 3,
            decoration: context.inputDecoration(
                'Business description',
                ProductUtils.getBusinessDescriptionHint(_selectedCategory)),
            validator: (val) =>
                val!.isEmpty ? 'Business description is mandatory' : null,
          )),
          _field(BottomSheetSelectorField<String>(
            label: 'Service coverage area',
            hint: 'Select coverage area',
            value: _serviceCoverageArea,
            items: const ['City', 'Highway', 'District'],
            labelBuilder: (s) => s,
            onChanged: (val) => setState(() => _serviceCoverageArea = val),
            validator: (val) =>
                val == null ? 'Coverage area is required' : null,
          )),
        ],
      );

  Widget _buildTowingStep2(BuildContext context) => Column(
        children: [
          _field(_buildTowingTypesField(context)),
          if (_selectedTowingServiceTypes.contains('Others'))
            _field(TextFormField(
              controller: customTowingServiceTypeController,
              decoration: context.inputDecoration(
                  'Custom towing service', 'Enter your custom service type'),
              validator: (val) =>
                  val!.isEmpty ? 'Custom service type is mandatory' : null,
            )),
        ],
      );

  Widget _buildTowingStep3(BuildContext context) => Column(
        children: [
          _field(TextFormField(
            controller: businessAddressController,
            decoration: context.inputDecoration(
                'Address', 'Enter your shop/garage address'),
            validator: (val) =>
                val!.isEmpty ? 'Address is mandatory' : null,
          )),
          const SizedBox(height: 8),
          AutocompleteSearchField(
            label: 'Area',
            hint: 'Enter area details',
            controller: areaController,
            icon: null,
            lat: stateCoordinates[_selectedState]?['lat'] ?? 0.0,
            lon: stateCoordinates[_selectedState]?['lon'] ?? 0.0,
            onPlaceSelected: (suggestion) => setState(() {
              areaController.text = suggestion.text;
              cityController.text = suggestion.municipality ?? '';
              pincodeController.text = suggestion.postalCode ?? '';
            }),
            validator: (val) => val!.isEmpty ? 'Area is required' : null,
          ),
          const SizedBox(height: 8),
          _field(TextFormField(
            controller: cityController,
            decoration:
                context.inputDecoration('City', 'Enter city name'),
            validator: (val) =>
                val!.isEmpty ? 'City is mandatory' : null,
          )),
          _field(BottomSheetSelectorField<String>(
            label: 'State',
            hint: 'Select your state',
            value: _selectedState,
            items: stateNames,
            labelBuilder: (s) => s,
            onChanged: (val) => setState(() => _selectedState = val),
            validator: (val) => val == null ? 'State is required' : null,
          )),
          _field(TextFormField(
            controller: pincodeController,
            keyboardType: TextInputType.text,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
            decoration:
                context.inputDecoration('Pin code', 'Enter pin code'),
            validator: (val) =>
                val!.isEmpty ? 'Pin code is mandatory' : null,
          )),
        ],
      );

  Widget _buildTowingStep4(BuildContext context) => Column(
        children: [
          _field(TextFormField(
            controller: contactNameController,
            decoration: context.inputDecoration(
                'Contact name', "Enter contact person's name"),
            validator: (val) =>
                val!.isEmpty ? 'Contact name is mandatory' : null,
          )),
          _field(_buildCountryCodeRow(context,
              label: 'Business contact',
              hint: 'Enter business contact number')),
          _field(TextFormField(
            controller: gstController,
            decoration:
                context.inputDecoration('GST #', 'Enter GST number'),
            validator: (val) =>
                val!.isEmpty ? 'GST number is mandatory' : null,
          )),
          _field(TextFormField(
            controller: googleMapLinkController,
            decoration: context.inputDecoration(
                'Google Map link', 'Enter Google Maps link (optional)'),
          )),
          _field(TextFormField(
            controller: socialMediaLinkController,
            decoration: context.inputDecoration(
                'Social media link', 'Enter social media link (optional)'),
          )),
          _field(WorkingHoursPicker(
            label: 'Business working days & hours',
            hint: 'Select working days and hours',
            controller: businessWorkingDaysHoursController,
            onChanged: (_) => setState(() {}),
            validator: (val) =>
                val!.isEmpty || val == 'No days selected, No time selected'
                    ? 'Working days and hours are mandatory'
                    : null,
          )),
        ],
      );

  Widget _buildTowingStep5(BuildContext context) => Column(
        children: [
          _buildListingSnapshot(context),
          _field(ImagePickerSection(
            title: 'Towing vehicle pictures',
            allowGallery: _enableGallery,
            allowMultipleImages: _enableGallery,
            images: _shopGarageImages,
            onImagesChanged: (imgs) => setState(() {
              _shopGarageImages
                ..clear()
                ..addAll(imgs);
            }),
          )),
          _field(ImagePickerSection(
            title: 'Promo / advertising pictures',
            allowGallery: _enableGallery,
            allowMultipleImages: _enableGallery,
            images: _promoImages,
            onImagesChanged: (imgs) => setState(() {
              _promoImages
                ..clear()
                ..addAll(imgs);
            }),
          )),
          _field(_buildTermsField(context)),
        ],
      );

  // ---------------------------------------------------------------------------
  // Unified step dispatchers
  // ---------------------------------------------------------------------------

  bool get _isTrack =>
      ProductUtils.isTrackAndTrainingCategory(_selectedCategory);
  bool get _isTowing => _selectedCategory == ProductUtils.towingService;

  Widget _buildStep1(BuildContext context) => _isTrack
      ? _buildTrackStep1(context)
      : _isTowing
          ? _buildTowingStep1(context)
          : _buildBikeStep1(context);

  Widget _buildStep2(BuildContext context) => _isTrack
      ? _buildTrackStep2(context)
      : _isTowing
          ? _buildTowingStep2(context)
          : _buildBikeStep2(context);

  Widget _buildStep3(BuildContext context) => _isTrack
      ? _buildTrackStep3(context)
      : _isTowing
          ? _buildTowingStep3(context)
          : _buildBikeStep3(context);

  Widget _buildStep4(BuildContext context) => _isTrack
      ? _buildTrackStep4(context)
      : _isTowing
          ? _buildTowingStep4(context)
          : _buildBikeStep4(context);

  Widget _buildStep5(BuildContext context) => _isTrack
      ? _buildTrackStep5(context)
      : _isTowing
          ? _buildTowingStep5(context)
          : _buildBikeStep5(context);

  // ---------------------------------------------------------------------------
  // Step titles
  // ---------------------------------------------------------------------------

  String get _step1Title =>
      _isTrack ? 'Event basics' : _isTowing ? 'Service info' : 'Business info';
  String get _step1Sub => _isTrack
      ? 'Tell us about the event'
      : _isTowing
          ? 'About your towing service'
          : ProductUtils.getShopNameHint(_selectedCategory);

  String get _step2Title =>
      _isTrack ? 'Event schedule' : _isTowing ? 'Services' : 'Contact details';
  String get _step2Sub => _isTrack
      ? 'Dates, times and capacity'
      : _isTowing
          ? 'What types of towing do you offer?'
          : 'How customers reach you';

  String get _step3Title =>
      _isTrack ? 'Venue' : _isTowing ? 'Location' : 'Location';
  String get _step3Sub => _isTrack
      ? 'Where is the event?'
      : _isTowing
          ? 'Where do you operate?'
          : 'Where are you based?';

  String get _step4Title => _isTrack
      ? 'Links & description'
      : _isTowing
          ? 'Contact & online'
          : 'Online presence';
  String get _step4Sub => _isTrack
      ? 'Event details and links'
      : _isTowing
          ? 'How to reach you'
          : 'Links and working hours';

  String get _step5Title => 'Photos & submit';
  String get _step5Sub => 'Add photos and submit your listing';

  List<FormStep> get _currentSteps => [
        FormStep(
          title: _step1Title,
          subtitle: _step1Sub,
          formKey: _stepKeys[0],
          builder: _buildStep1,
        ),
        FormStep(
          title: _step2Title,
          subtitle: _step2Sub,
          formKey: _stepKeys[1],
          builder: _buildStep2,
        ),
        FormStep(
          title: _step3Title,
          subtitle: _step3Sub,
          formKey: _stepKeys[2],
          builder: _buildStep3,
        ),
        FormStep(
          title: _step4Title,
          subtitle: _step4Sub,
          formKey: _stepKeys[3],
          builder: _buildStep4,
        ),
        FormStep(
          title: _step5Title,
          subtitle: _step5Sub,
          formKey: _stepKeys[4],
          builder: _buildStep5,
        ),
      ];

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasFormData(),
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_hasFormData()) {
          AppLogger.d('[ListServiceFormScreen] unsaved data detected on pop');
          final discard = await _confirmDiscardChanges();
          if (discard && mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        } else {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        }
      },
      child: _selectedCategory == null
          ? _buildCategoryPlaceholder(context)
          : SteppedFormScaffold(
              key: ValueKey(_selectedCategory),
              appBarTitle: _selectedCategory!,
              steps: _currentSteps,
              onSubmit: _submitForm,
              submitLabel: _isEditing ? 'Update' : 'Submit',
              isLoading: _isLoading,
              controller: _stepController,
              onBackPressed: () async {
                AppLogger.d('[ListServiceFormScreen] AppBar back pressed');
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
              },
              actions: [
                if (widget.category == null)
                  IconButton(
                    icon: const Icon(Icons.swap_horiz_rounded,
                        color: BikerverseColors.textSecondary),
                    tooltip: 'Change service category',
                    onPressed: _showCategorySelectionSheet,
                  ),
              ],
            ),
    );
  }

  Widget _buildCategoryPlaceholder(BuildContext context) {
    return Scaffold(
      backgroundColor: BikerverseColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.category_outlined,
                  size: 64, color: BikerverseColors.textMuted),
              const SizedBox(height: 16),
              const Text(
                'Choose a service category to get started',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: BikerverseColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _showCategorySelectionSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BikerverseColors.accent,
                  foregroundColor: BikerverseColors.onGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                ),
                child: const Text('Select Category',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
