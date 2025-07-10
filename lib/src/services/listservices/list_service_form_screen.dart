import 'dart:io';

import 'package:flutter/material.dart';
import 'package:popp/src/navigation/nav_router.dart';
import 'package:popp/src/utils/build_extensions.dart'; // From build_extensions.dart
import 'package:popp/src/widgets/custom_dropdown_form_field.dart'; // You might need to create this widget
import 'package:popp/src/widgets/image_picker_selection.dart'; // You might need to create this widget
import 'package:popp/src/widgets/loading_overlay.dart'; // You might need to create this widget
import 'package:popp/src/widgets/month_year_picker.dart';

import '../../firebase/firebase_api_service.dart';
import '../../utils/app_loger.dart';
import '../../utils/product_content_data.dart';
import '../../widgets/working_hours_picker.dart'; // You might need to create this widget

class ListServiceFormScreen extends StatefulWidget {
  const ListServiceFormScreen({super.key});

  @override
  State<ListServiceFormScreen> createState() => _ListServiceFormScreenState();
}

class _ListServiceFormScreenState extends State<ListServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseApiService _productsService = FirebaseApiService();

  // --- Common controllers, now potentially used in multiple sections based on category ---
  final TextEditingController businessTitleController = TextEditingController();
  final TextEditingController businessContactController =
      TextEditingController();
  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController panController = TextEditingController();
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

  // --- Track Day / Training Day specific controllers ---
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController maxSlotsController = TextEditingController();
  final TextEditingController eventDetailedDescriptionController =
      TextEditingController();
  final TextEditingController locationNameController = TextEditingController();
  final TextEditingController locationAddressController =
      TextEditingController();
  final TextEditingController googleFormLinkController =
      TextEditingController();

  String? _selectedCategory;
  String selectedCountryCode = "+91";
  final List<File> _promoImages = [];
  final List<File> _shopGarageImages =
      []; // Specific to Book Service/Bike Rentals
  String? _doYouInspectPremiumBikes; // For Book Service
  String? _selectedState; // For Bike Rentals
  String? _bikeProvision; // For Track/Training Day
  String? _riderSkillLevel; // For Track/Training Day
  DateTime? _eventStartDate; // For Track/Training Day
  DateTime? _eventEndDate; // For Track/Training Day
  TimeOfDay? _eventStartTime; // For Track/Training Day
  TimeOfDay? _eventEndTime; // For Track/Training Day

  bool _isLoading = false;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    // Show category selection bottom sheet on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedCategory == null) {
        _showCategorySelectionSheet();
      }
    });
  }

  @override
  void dispose() {
    businessTitleController.dispose();
    businessContactController.dispose();
    contactNameController.dispose();
    gstController.dispose();
    panController.dispose();
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
    super.dispose();
  }

  Future<void> _handleLoading(bool isLoading) async {
    if (mounted) {
      setState(() {
        _isLoading = isLoading;
      });
    }
  }

  // Method to clear ALL form fields (common and category-specific)
  void _clearAllFields() {
    _formKey.currentState?.reset(); // Resets the form
    // Clear all text controllers
    businessTitleController.clear();
    businessContactController.clear();
    contactNameController.clear();
    gstController.clear();
    panController.clear();
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

    // Clear all dropdown selections and dates
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
    });
  }

  Future<void> _submitForm() async {
    // Only validate and submit if a category is selected
    if (_selectedCategory == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service category first')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (!_termsAccepted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept the Terms & Conditions')),
        );
        return;
      }

      // Collect data based on category
      Map<String, dynamic> formData = {};

      if (_selectedCategory == serviceCategories[0] ||
          _selectedCategory == serviceCategories[1]) {
        formData.addAll({
          'category': _selectedCategory,
          'businessTitle': businessTitleController.text,
          'businessPromoPicture': _promoImages.map((e) => e.path).toList(),
          'shopGaragePics': _shopGarageImages.map((e) => e.path).toList(),
          'businessContact':
              '$selectedCountryCode ${businessContactController.text}',
          'contactName': contactNameController.text,
          'gstNumber': gstController.text,
          'panNumber': panController.text,
          'businessDescription': businessDescriptionController.text,
          'businessAddress': businessAddressController.text,
          'area': areaController.text,
          'city': cityController.text,
          'searchKeywords':
              '${businessTitleController.text} ${areaController.text} '
                      '${cityController.text} $_selectedCategory '
                  .toLowerCase()
                  .split(' '),
          'state': _selectedState,
          'pincode': pincodeController.text,
          'doYouInspectPremiumBikes': _doYouInspectPremiumBikes,
          'googleMapLink': googleMapLinkController.text,
          'socialMediaLink': socialMediaLinkController.text,
          'businessWorkingDaysHours': businessWorkingDaysHoursController.text,
        });
      } else if (_selectedCategory == serviceCategories[2]  ||
          _selectedCategory == serviceCategories[3] ) {
        formData.addAll({
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
          // This was a text field, will collect value if needed
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
          'panNumber': panController.text,
          'googleMapLink': googleMapLinkController.text,
          'googleFormLink': googleFormLinkController.text,
          'socialMediaLink': socialMediaLinkController.text,
          'contact': businessContactController.text,
          'pointOfContactName': contactNameController.text,
        });
      }

      bool success = await _productsService.submitListServicesForm(
        context: context,
        data: formData,
        promoImages: _promoImages,
        shopGarageImages: _shopGarageImages,
        onLoading: _handleLoading,
      );

      AppLogger.d("Form submission success: $success");
      if (success) {
        _clearAllFields(); // Clear all fields after successful submission
        if (!mounted) return;
        // Optionally navigate to a success page or home
        onServiceListingTap(context, _selectedCategory!, true);
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
    }
  }

  void _showCategorySelectionSheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.zero,
          topRight: Radius.zero,
        ),
      ),
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Select Service Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(thickness: 1, height: 0),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: serviceCategories
                      .map((category) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: Theme.of(context).colorScheme.surface,
                              child: ListTile(
                                title: Center(
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop(category);
                                },
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (selected != null && selected != _selectedCategory) {
      setState(() {
        _clearAllFields();
        _selectedCategory = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List your service'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Change Service Category',
            onPressed: _showCategorySelectionSheet,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedCategory == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Text(
                        "Please choose a service category to enable the form fields.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (_selectedCategory == 'Book your Bike service' ||
                    _selectedCategory == 'Bike Rentals') ...[
                  // Fields for Book your Service / Bike Rentals (from image_1a7749.png)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: businessTitleController, // 1
                      decoration: context.inputDecoration(
                          "Business Title", "Enter your business title"),
                      validator: (val) =>
                          val!.isEmpty ? "Business Title is mandatory" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ImagePickerSection(
                      title: "Upload pics for Business Promo or Adv Picture",
                      // 2
                      images: _promoImages,
                      onImagesChanged: (images) => setState(() {
                        _promoImages.clear();
                        _promoImages.addAll(images);
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ImagePickerSection(
                      title: "Upload pics for Shop/Garage Pics", // 3
                      images: _shopGarageImages,
                      onImagesChanged: (images) => setState(() {
                        _shopGarageImages.clear();
                        _shopGarageImages.addAll(images);
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                            controller: businessContactController, // 4
                            keyboardType: TextInputType.phone,
                            decoration: context.inputDecoration(
                                "Business Contact #",
                                "Enter business contact number"),
                            validator: (val) =>
                                val!.isEmpty ? "Contact is mandatory" : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: contactNameController, // 5
                      decoration: context.inputDecoration(
                          "Contact Name", "Enter contact person's name"),
                      validator: (val) =>
                          val!.isEmpty ? "Contact Name is mandatory" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: businessDescriptionController, // 8
                      decoration: context.inputDecoration(
                          "Business Description/Clauses",
                          "Describe your business and terms"),
                      maxLines: 3,
                      validator: (val) => val!.isEmpty
                          ? "Business Description is mandatory"
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: businessAddressController, // 9
                      decoration: context.inputDecoration(
                          "Business Address", "Enter your business address"),
                      validator: (val) =>
                          val!.isEmpty ? "Address is mandatory" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: areaController, // 10
                      decoration: context.inputDecoration("Area", "Enter area"),
                      validator: (val) =>
                          val!.isEmpty ? "Area is mandatory" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: cityController, // 11
                      decoration:
                          context.inputDecoration("City", "Enter city name"),
                      validator: (val) =>
                          val!.isEmpty ? "City is mandatory" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CustomDropdownFormField<String>(
                      label: "State",
                      hint: "Select your state",
                      value: _selectedState,
                      items: stateNames
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedState = val),
                      validator: (val) => val == null ? "Required" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: pincodeController, // 13
                      keyboardType: TextInputType.number,
                      decoration:
                          context.inputDecoration("Pin code", "Enter pin code"),
                      validator: (val) =>
                          val!.isEmpty ? "Pin code is mandatory" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CustomDropdownFormField<String>(
                      label: "Premium Bike Inspection",
                      hint: "Do you inspect premium bikes?",
                      value: _doYouInspectPremiumBikes,
                      items: yesNo
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _doYouInspectPremiumBikes = val),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: gstController, // 6
                      decoration: context.inputDecoration(
                          "GST #", "Enter GST number (optional)"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: panController, // 7
                      decoration: context.inputDecoration(
                          "PAN #", "Enter PAN number (optional)"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: googleMapLinkController, // 14
                      decoration: context.inputDecoration("Google Map Link",
                          "Enter Google Maps link (optional)"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: socialMediaLinkController, // 15
                      decoration: context.inputDecoration("Social Media Link",
                          "Enter social media link (optional)"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: WorkingHoursPicker(
                      label: "Business Working Days & Hours",
                      hint: "Select working days and hours",
                      controller: businessWorkingDaysHoursController,
                      onChanged: (value) {
                        setState(() {
                          // The controller text is updated internally by WorkingHoursPicker
                          // You might want to trigger form validation here if necessary
                          // _formKey.currentState?.validate();
                        });
                      },
                      validator: (val) => val!.isEmpty ||
                              val == "No days selected, No time selected"
                          ? "Working days and hours are mandatory"
                          : null,
                    ),
                  ),
                ],
                if (_selectedCategory == 'Track day' ||
                    _selectedCategory == 'Training day') ...[
                  // Fields for Track Day / Training Day (from image_1a79f1.png)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: eventNameController, // 1
                      decoration: context.inputDecoration(
                          "Event Name", "Enter the event name"),
                      validator: (val) =>
                          val!.isEmpty ? "Event Name is mandatory" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ImagePickerSection(
                      title: "Event Promo Picture", // 2
                      images: _promoImages,
                      onImagesChanged: (images) => setState(() {
                        _promoImages.clear();
                        _promoImages.addAll(images);
                      }),
                    ),
                  ),
                  // Bike Type/Model (TextFormField as it's free text) - Not explicitly mapped to controller
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      // 3
                      decoration: context.inputDecoration(
                          "Bike Type/Model", "e.g., Any Superbike, 600cc+"),
                      // No controller needed if just a display or optional input
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CustomDropdownFormField<String>(
                      label: 'Bike Provision',
                      // 4
                      hint: 'Self/Organizer',
                      value: _bikeProvision,
                      items: ['Self', 'Organizer']
                          .map((provision) => DropdownMenuItem(
                                value: provision,
                                child: Text(provision),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _bikeProvision = val),
                      validator: (val) =>
                          val == null ? 'Bike Provision is mandatory' : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CustomDropdownFormField<String>(
                      label: 'Rider Skill Level',
                      // 5
                      hint: 'All/Beginner/Novice/Intermediate/Expert',
                      value: _riderSkillLevel,
                      items: riderSkillLevels
                          .map((level) => DropdownMenuItem(
                                value: level,
                                child: Text(level),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _riderSkillLevel = val),
                      validator: (val) =>
                          val == null ? 'Rider Skill Level is mandatory' : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: MonthYearPicker(
                      // 6
                      enable: true,
                      label: "Event Start Date",
                      hint: "Select start date",
                      selectedDate: _eventStartDate,
                      onDateSelected: (date) =>
                          setState(() => _eventStartDate = date),
                      validator: (date) =>
                          date == null ? "Event Start Date is mandatory" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: MonthYearPicker(
                      // 7
                      enable: true,
                      label: "Event End Date",
                      hint: "Select end date",
                      selectedDate: _eventEndDate,
                      onDateSelected: (date) =>
                          setState(() => _eventEndDate = date),
                      validator: (date) =>
                          date == null ? "Event End Date is mandatory" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: InkWell(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _eventStartTime ?? TimeOfDay.now(),
                        );
                        if (picked != null && picked != _eventStartTime) {
                          setState(() {
                            _eventStartTime = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: context
                            .inputDecoration(
                              "Event Start Time", // 8
                              _eventStartTime?.format(context) ??
                                  "Select start time",
                            )
                            .copyWith(
                              errorText: _eventStartTime == null &&
                                      _formKey.currentState?.validate() == false
                                  ? "Event Start Time is mandatory"
                                  : null,
                            ),
                        child: Text(
                          _eventStartTime?.format(context) ??
                              'Select start time',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: InkWell(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _eventEndTime ?? TimeOfDay.now(),
                        );
                        if (picked != null && picked != _eventEndTime) {
                          setState(() {
                            _eventEndTime = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: context
                            .inputDecoration(
                              "Event End Time", // 9
                              _eventEndTime?.format(context) ??
                                  "Select end time",
                            )
                            .copyWith(
                              errorText: _eventEndTime == null &&
                                      _formKey.currentState?.validate() == false
                                  ? "Event End Time is mandatory"
                                  : null,
                            ),
                        child: Text(
                          _eventEndTime?.format(context) ?? 'Select end time',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: maxSlotsController, // 10
                      keyboardType: TextInputType.number,
                      decoration: context.inputDecoration(
                          "Max Slots", "Enter maximum slots available"),
                      validator: (val) =>
                          val!.isEmpty ? "Max Slots is mandatory" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: eventDetailedDescriptionController, // 11
                      decoration: context.inputDecoration(
                          "Event Detailed Description",
                          "Tell what you provide, rider briefing & requirements/clauses"),
                      maxLines: 3,
                      validator: (val) => val!.isEmpty
                          ? "Event Description is mandatory"
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: locationNameController, // 12
                      decoration: context.inputDecoration(
                          "Location Name", "Enter location name"),
                      validator: (val) =>
                          val!.isEmpty ? "Location Name is mandatory" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: locationAddressController, // 13
                      decoration: context.inputDecoration("Location Address",
                          "Enter location address with landmark"),
                      validator: (val) =>
                          val!.isEmpty ? "Location Address is mandatory" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: areaController, // 14
                      decoration: context.inputDecoration("Area", "Enter area"),
                      validator: (val) =>
                          val!.isEmpty ? "Area is mandatory" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: cityController, // 15
                      decoration:
                          context.inputDecoration("City", "Enter city name"),
                      validator: (val) =>
                          val!.isEmpty ? "City is mandatory" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CustomDropdownFormField<String>(
                      label: "State",
                      hint: "Select your state",
                      value: _selectedState,
                      items: stateNames
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedState = val),
                      validator: (val) => val == null ? "Required" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: pincodeController, // 17
                      keyboardType: TextInputType.number,
                      decoration:
                          context.inputDecoration("Pin code", "Enter pin code"),
                      validator: (val) =>
                          val!.isEmpty ? "Pin code is mandatory" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: gstController, // 18
                      decoration: context.inputDecoration(
                          "GST #", "Enter GST number (optional)"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: panController, // 19
                      decoration: context.inputDecoration(
                          "PAN #", "Enter PAN number (optional)"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: googleMapLinkController, // 20
                      decoration: context.inputDecoration("Google Map Link",
                          "Enter Google Maps link (optional)"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: googleFormLinkController, // 21
                      decoration: context.inputDecoration(
                          "Google Form/Redirect Link",
                          "Enter Google Form or redirect link (optional)"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: socialMediaLinkController, // 22
                      decoration: context.inputDecoration("Social Media Link",
                          "Enter social media link (optional)"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                            controller: businessContactController,
                            // 23 (Contact #)
                            keyboardType: TextInputType.phone,
                            decoration: context.inputDecoration(
                                "Contact #", "Enter contact number"),
                            validator: (val) =>
                                val!.isEmpty ? "Contact is mandatory" : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: contactNameController,
                      // 24 (Point of Contact Name)
                      decoration: context.inputDecoration(
                          "Point of Contact Name",
                          "Enter point of contact name"),
                      validator: (val) => val!.isEmpty
                          ? "Point of Contact Name is mandatory"
                          : null,
                    ),
                  ),
                ],
                // Terms & Conditions (18/26 from images) - Only show if a category is selected
                if (_selectedCategory != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _termsAccepted = newValue ?? false;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                            "I accept the Terms & Conditions",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Submit Button
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (_isLoading || _selectedCategory == null)
                            ? null
                            : _submitForm,
                        // Disabled if loading or no category selected
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              (_isLoading || _selectedCategory == null)
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
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
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
