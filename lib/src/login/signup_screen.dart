import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:popp/src/api/api_url.dart';
import 'package:popp/src/login/model/user_data_model.dart';
import 'package:popp/src/login/validation_requiremen_text.dart';
import 'package:popp/src/utils/build_extensions.dart';

import '../navigation/nav_router.dart';
import '../search/autocomplete_search_field.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';
import '../utils/product_content_data.dart';
import '../widgets/custom_dropdown_form_field.dart';
import '../widgets/month_year_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedState;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  final List<Map<String, dynamic>> bikes = [];
  final List<FocusNode> brandFocusNodes = [];
  final List<FocusNode> modelFocusNodes = [];

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _addBike();
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    addressController.dispose();
    cityController.dispose();
    pinCodeController.dispose();

    for (final bike in bikes) {
      (bike['brandController'] as TextEditingController).dispose();
      (bike['modelController'] as TextEditingController).dispose();
    }
    for (final node in brandFocusNodes) {
      node.dispose();
    }
    for (final node in modelFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _addBike() {
    if (bikes.length < 3) {
      setState(() {
        bikes.add({
          'brand': null,
          'model': null,
          'monthYear': null,
          'brandController': TextEditingController(),
          'modelController': TextEditingController(),
        });
        brandFocusNodes.add(FocusNode());
        modelFocusNodes.add(FocusNode());
      });
    }
  }

  void _removeBike(int index) {
    (bikes[index]['brandController'] as TextEditingController).dispose();
    (bikes[index]['modelController'] as TextEditingController).dispose();
    brandFocusNodes[index].dispose();
    modelFocusNodes[index].dispose();

    setState(() {
      bikes.removeAt(index);
      brandFocusNodes.removeAt(index);
      modelFocusNodes.removeAt(index);
    });
  }

  Future<void> _createAccountAndContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => isSubmitting = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      final user = userCredential.user;
      if (user == null) throw Exception("User creation failed.");

      var acs = ActionCodeSettings(
          url: ApiUrl.baseUrl,
          handleCodeInApp: true,
          iOSBundleId: Constants.appBundleId,
          androidPackageName: Constants.appBundleId,
          androidInstallApp: true,
          androidMinimumVersion: '12');
      await user.sendEmailVerification(acs);

      final bikeDataList = bikes
          .map((bikeData) {
            final brandController =
                bikeData['brandController'] as TextEditingController;
            final modelController =
                bikeData['modelController'] as TextEditingController;
            final selectedBrand = bikeData['brand'] as String?;
            final selectedModel = bikeData['model'] as String?;

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

            final monthYear = bikeData['monthYear'] as DateTime?;
            final monthYearString = monthYear != null
                ? DateFormat('MM/yyyy').format(monthYear)
                : '';

            return BikeData(
              brand: finalBrand,
              model: finalModel,
              monthYear: monthYearString,
            );
          })
          .where((bike) =>
              bike.brand.isNotEmpty ||
              bike.model.isNotEmpty ||
              bike.monthYear.isNotEmpty)
          .toList();

      UserData userData = UserData(
        uid: user.uid,
        username: usernameController.text,
        email: emailController.text,
        phoneNumber: phoneNumberController.text,
        address: addressController.text,
        stateName: selectedState ?? "",
        city: cityController.text,
        pinCode: pinCodeController.text,
        bikeData: bikeDataList,
        createdAt: FieldValue.serverTimestamp(),
      );

      if (!mounted) return;

      onVerificationScreenTap(
          context, userData, userData.email, passwordController.text, true);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for that email.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => onLoginTap(context),
          tooltip: 'Back',
        ),
        title: const Text("Create Account"),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader(
                        "Account Details", "Create your login credentials."),
                    _buildTextField("Name", usernameController,
                        icon: Icons.person_outline),
                    const SizedBox(height: 15),
                    _buildTextField("Email", emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 15),
                    _buildTextField("Phone number", phoneNumberController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.number,
                        isRequired: false),
                    const SizedBox(height: 15),
                    _buildTextField("Password", passwordController,
                        icon: Icons.lock_outline,
                        isPasswordTextField: true,
                        currentPasswordVisibility: _isPasswordVisible,
                        onTogglePasswordVisibility: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible)),
                    const SizedBox(height: 15),
                    _buildTextField(
                        "Confirm Password", confirmPasswordController,
                        icon: Icons.lock_person_outlined,
                        isPasswordTextField: true,
                        currentPasswordVisibility: _isConfirmPasswordVisible,
                        onTogglePasswordVisibility: () => setState(() =>
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible)),
                    _buildPasswordRequirementsDisclosure(),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Your Location",
                        "Used to find rides and services near you."),
                    CustomDropdownFormField<String>(
                        value: selectedState,
                        label: "",
                        hint: "Select your state",
                        items: stateNames
                            .map((b) =>
                                DropdownMenuItem(value: b, child: Text(b)))
                            .toList(),
                        onChanged: (val) => setState(() => selectedState = val),
                        validator: (val) =>
                            val == null ? "State is required" : null),
                    const SizedBox(height: 15),
                    AutocompleteSearchField(
                      label: "Address",
                      hint: "Start typing your address...",
                      controller: addressController,
                      icon: Icons.home_outlined,
                      lat: stateCoordinates[selectedState]?['lat'] ?? 0.0,
                      lon: stateCoordinates[selectedState]?['lon'] ?? 0.0,
                      onPlaceSelected: (suggestion) {
                        // Update all location controllers when a place is selected
                        setState(() {
                          addressController.text = suggestion.text;
                          cityController.text = suggestion.municipality ?? '';
                          pinCodeController.text = suggestion.postalCode ?? '';
                        });
                      },
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 15),
                    // --- UPDATED: CITY FIELD (NOW AUTO-POPULATED) ---
                    _buildTextField("City", cityController,
                        icon: Icons.location_city_outlined),
                    const SizedBox(height: 15),
                    // --- UPDATED: PIN CODE FIELD (NOW AUTO-POPULATED) ---
                    _buildTextField("Pin Code", pinCodeController,
                        icon: Icons.pin_drop_outlined,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Bike Details (Optional)",
                        "Add your bikes for custom notifications."),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bikes.length,
                      itemBuilder: (context, index) => _buildBikeFields(index),
                    ),
                    if (bikes.length < 3)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _addBike,
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text("Add Another Bike"),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _createAccountAndContinue,
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Account",
                        style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    // ... (This method remains unchanged)
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildBikeFields(int index) {
    // ... (This method remains unchanged)
    final bike = bikes[index];
    final selectedBrand = bike['brand'] as String?;
    final brandController = bike['brandController'] as TextEditingController;
    final selectedModel = bike['model'] as String?;
    final modelController = bike['modelController'] as TextEditingController;

    final bool isBrandOthers = selectedBrand == 'Others';
    final bool isModelOthers = selectedModel == 'Others';

    final modelsForBrand = isBrandOthers
        ? <String>[] // No models if brand is "Others"
        : (bikeBrandModels[selectedBrand] ?? []);
    final brandListWithOthers = [...bikeBrands, 'Others'];
    final modelListWithOthers =
        modelsForBrand.isNotEmpty ? [...modelsForBrand, 'Others'] : <String>[];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bike ${index + 1}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                if (bikes.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.redAccent),
                    onPressed: () => _removeBike(index),
                    tooltip: 'Remove Bike',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedBrand,
              decoration: context.inputDecoration("", "Choose brand",
                  icon: Icons.two_wheeler_outlined),
              items: brandListWithOthers
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  bikes[index]['brand'] = val;
                  bikes[index]['model'] = null;
                  modelController.clear();
                  if (val != 'Others') {
                    brandController.clear();
                  } else {
                    brandFocusNodes[index].requestFocus();
                  }
                });
              },
            ),
            if (isBrandOthers)
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: _buildTextField('Enter Brand Name', brandController,
                    focusNode: brandFocusNodes[index],
                    icon: Icons.edit_outlined,
                    isRequired: true),
              ),
            const SizedBox(height: 15),
            if (!isBrandOthers)
              Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedModel,
                    decoration: context.inputDecoration(
                      "",
                      selectedBrand != null
                          ? "Choose model"
                          : "Select a brand first",
                      icon: Icons.motorcycle_outlined,
                    ),
                    onChanged: selectedBrand != null
                        ? (val) {
                            setState(() {
                              bikes[index]['model'] = val;
                              if (val != 'Others') {
                                modelController.clear();
                              } else {
                                modelFocusNodes[index].requestFocus();
                              }
                            });
                          }
                        : null,
                    items: modelListWithOthers
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                  ),
                  if (isModelOthers)
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: _buildTextField(
                          'Enter Model Name', modelController,
                          focusNode: modelFocusNodes[index],
                          icon: Icons.edit_outlined,
                          isRequired: true),
                    ),
                ],
              ),
            if (isBrandOthers)
              _buildTextField('Enter Model Name', modelController,
                  icon: Icons.motorcycle_outlined, isRequired: true),
            const SizedBox(height: 15),
            MonthYearPicker(
              label: "",
              hint: "Manufacture Date",
              selectOnlyMonthYear: true,
              selectedDate: bike['monthYear'],
              onDateSelected: (date) =>
                  setState(() => bikes[index]['monthYear'] = date),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRequirementsDisclosure() {
    // ... (This method remains unchanged)
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: passwordController,
      builder: (context, value, child) {
        final currentPassword = value.text;
        return ExpansionTile(
          title: const Text("Password Requirements",
              style: TextStyle(fontWeight: FontWeight.w600)),
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.symmetric(vertical: 8.0),
          children: <Widget>[
            ValidationRequirementText(
                text: "At least 8 characters",
                isValid: currentPassword.length >= 8),
            ValidationRequirementText(
                text: "At least one uppercase letter (A-Z)",
                isValid: RegExp(r'(?=.*[A-Z])').hasMatch(currentPassword)),
            ValidationRequirementText(
                text: "At least one lowercase letter (a-z)",
                isValid: RegExp(r'(?=.*[a-z])').hasMatch(currentPassword)),
            ValidationRequirementText(
                text: "At least one number (0-9)",
                isValid: RegExp(r'(?=.*\d)').hasMatch(currentPassword)),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {IconData? icon,
      int maxLines = 1,
      bool isRequired = true,
      TextInputType? keyboardType,
      bool isPasswordTextField = false,
      VoidCallback? onTogglePasswordVisibility,
      bool? currentPasswordVisibility,
      FocusNode? focusNode}) {
    // ... (This method remains unchanged)
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText:
          isPasswordTextField ? !(currentPasswordVisibility ?? false) : false,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '$hint is required';
        }
        if (hint == "Email" && value != null && !AppUtils.isEmailValid(value)) {
          return 'Enter a valid email address';
        }
        if (hint == "Password" && value != null && isRequired) {
          if (value.length < 8) {
            return 'Password must be at least 8 characters long';
          }
          if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
            return 'Password must contain an uppercase letter';
          }
          if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
            return 'Password must contain a lowercase letter';
          }
          if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
            return 'Password must contain a number';
          }
        }
        if (hint == "Confirm Password" &&
            controller.text != passwordController.text) {
          return "Passwords do not match";
        }
        if (hint == "Pin Code" && value != null && value.isNotEmpty) {
          if (value.length != 6) return 'Pincode must be 6 digits';
          if (!RegExp(r"^[0-9]{6}$").hasMatch(value)) {
            return 'Enter a valid pincode';
          }
        }
        return null;
      },
      decoration: context.inputDecoration("", hint, icon: icon).copyWith(
            suffixIcon: isPasswordTextField
                ? IconButton(
                    icon: Icon((currentPasswordVisibility ?? false)
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: onTogglePasswordVisibility,
                  )
                : null,
          ),
    );
  }
}
