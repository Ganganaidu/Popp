import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:popp/src/toolbar/common_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:popp/src/api/api_url.dart';
import 'package:popp/src/login/model/user_data_model.dart';
import 'package:popp/src/login/repository/auth_repository.dart';
import 'package:popp/src/login/validation_requiremen_text.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:popp/src/widgets/title_text.dart';

import '../navigation/app_routes.dart';
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
  final AuthRepository _authRepository = AuthRepository();
  String? selectedState;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
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
    areaController.dispose();
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
      final userCredential = await _authRepository.signUp(
          email: emailController.text, password: passwordController.text);

      final user = userCredential.user;
      if (user == null) throw Exception("User creation failed.");

      var acs = ActionCodeSettings(
          url: ApiUrl.welcomePage,
          handleCodeInApp: true,
          iOSBundleId: Constants.appBundleId,
          androidPackageName: Constants.appBundleId,
          androidInstallApp: true,
          androidMinimumVersion: '12');
      await _authRepository.sendEmailVerification(
          user: user, actionCodeSettings: acs);

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
        area: areaController.text,
        stateName: selectedState ?? "",
        city: cityController.text,
        pinCode: pinCodeController.text,
        bikeData: bikeDataList,
        createdAt: FieldValue.serverTimestamp(),
      );

      if (!mounted) return;

      context.pushVerification(VerificationArgs(
        userData: userData,
        email: userData.email,
        password: passwordController.text,
        isFromSignUp: true,
      ));
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
      AppLogger.e(errorMessage);
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
    if (kIsWeb && context.isDesktop) {
      return _buildWebLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        titleWidget: const TitleText("Create Account"),
        showBackButton: true,
        onBackPressed: () => context.goLogin(),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [Colors.grey[850]!, Colors.grey[900]!]
                : [const Color(0xFFFDFBFB), const Color(0xFFEBEDEE)],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWebHeader(),
                          const SizedBox(height: 40),
                          _buildWebFormContent(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildWebSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        titleWidget: const TitleText("Create Account"),
        showBackButton: true,
        onBackPressed: () => context.goLogin(),
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
                        keyboardType: TextInputType.phone,
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
                    _buildPasswordRequirements(),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Your Location",
                        "Used to find rides and services near you."),
                    _buildDropdownField(),
                    const SizedBox(height: 15),
                    _buildAreaTextField(),
                    const SizedBox(height: 15),
                    _buildAutocompleteField(),
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
              padding: const EdgeInsets.fromLTRB(
                16.0,
                16.0,
                16.0,
                50.0,
              ),
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _createAccountAndContinue,
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: context.primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: isSubmitting
                    ? CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary)
                    : const Text("Create Account",
                        style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWebHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Create Your Account",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Join our community and start your biking journey today",
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildWebFormContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column - Account Details
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWebSectionHeader(
                  "Account Details",
                  "Create your login credentials",
                  Icons.person_outline,
                ),
                const SizedBox(height: 20),
                _buildTextField("Name", usernameController,
                    icon: Icons.person_outline),
                const SizedBox(height: 20),
                _buildTextField("Email", emailController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _buildTextField("Phone number", phoneNumberController,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    isRequired: false),
                const SizedBox(height: 20),
                _buildTextField("Password", passwordController,
                    icon: Icons.lock_outline,
                    isPasswordTextField: true,
                    currentPasswordVisibility: _isPasswordVisible,
                    onTogglePasswordVisibility: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible)),
                const SizedBox(height: 20),
                _buildTextField("Confirm Password", confirmPasswordController,
                    icon: Icons.lock_person_outlined,
                    isPasswordTextField: true,
                    currentPasswordVisibility: _isConfirmPasswordVisible,
                    onTogglePasswordVisibility: () => setState(() =>
                        _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible)),
                const SizedBox(height: 20),
                _buildPasswordRequirements(),
              ],
            ),
          ),
        ),
        // Right Column - Location & Bike Details
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWebSectionHeader(
                  "Your Location",
                  "Used to find rides and services near you",
                  Icons.location_on_outlined,
                ),
                const SizedBox(height: 20),
                _buildDropdownField(),
                const SizedBox(height: 20),
                _buildAutocompleteField(),
                const SizedBox(height: 20),
                _buildTextField("City", cityController,
                    icon: Icons.location_city_outlined),
                const SizedBox(height: 20),
                _buildTextField("Pin Code", pinCodeController,
                    icon: Icons.pin_drop_outlined,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 30),
                _buildWebSectionHeader(
                  "Bike Details (Optional)",
                  "Add your bikes for custom notifications",
                  Icons.two_wheeler_outlined,
                ),
                const SizedBox(height: 20),
                _buildWebBikeSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebSubmitButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SizedBox(
            width: 300,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : _createAccountAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 2,
              ),
              child: isSubmitting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebSectionHeader(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]?.withOpacity(0.5)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[700]!
              : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: context.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildPasswordRequirements() {
    final isWeb = kIsWeb && context.isDesktop;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: passwordController,
      builder: (context, value, child) {
        final currentPassword = value.text;

        if (isWeb) {
          // Web version - always visible in a styled container
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]?.withOpacity(0.3)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]!
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Password Requirements",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                ValidationRequirementText(
                    text: "At least 8 characters",
                    isValid: currentPassword.length >= 8),
                const SizedBox(height: 8),
                ValidationRequirementText(
                    text: "At least one uppercase letter (A-Z)",
                    isValid: RegExp(r'(?=.*[A-Z])').hasMatch(currentPassword)),
                const SizedBox(height: 8),
                ValidationRequirementText(
                    text: "At least one lowercase letter (a-z)",
                    isValid: RegExp(r'(?=.*[a-z])').hasMatch(currentPassword)),
                const SizedBox(height: 8),
                ValidationRequirementText(
                    text: "At least one number (0-9)",
                    isValid: RegExp(r'(?=.*\d)').hasMatch(currentPassword)),
              ],
            ),
          );
        } else {
          // Mobile version - expandable tile
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
        }
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
    final isWeb = kIsWeb && context.isDesktop;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText:
          isPasswordTextField ? !(currentPasswordVisibility ?? false) : false,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: hint == "Phone number"
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ]
          : null,
      style: TextStyle(fontSize: isWeb ? 16 : 14),
      validator: (value) {
        if (hint == "Phone number") {
          return AppUtils.phoneValidator(value, isRequired: isRequired);
        }
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
      decoration: context
          .inputDecoration("", hint,
              icon: icon, borderRadius: isWeb ? 8.0 : 8.0)
          .copyWith(
            contentPadding: EdgeInsets.symmetric(
              horizontal: isWeb ? 20 : 16,
              vertical: isWeb ? 18 : 16,
            ),
            suffixIcon: isPasswordTextField
                ? IconButton(
                    icon: Icon(
                      (currentPasswordVisibility ?? false)
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: isWeb ? 20 : 18,
                    ),
                    onPressed: onTogglePasswordVisibility,
                  )
                : null,
          ),
    );
  }

  Widget _buildDropdownField() {
    return CustomDropdownFormField<String>(
      value: selectedState,
      label: "",
      hint: "Select your state",
      items: stateNames
          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
          .toList(),
      onChanged: (val) => setState(() => selectedState = val),
      validator: (val) => val == null ? "State is required" : null,
    );
  }

  Widget _buildAreaTextField() {
    return TextFormField(
      controller: addressController,
      decoration: context.inputDecoration("", "Enter address or locality",
          icon: Icons.home),
      maxLines: 1,
      validator: (val) => val!.isEmpty ? "Required" : null,
    );
  }

  Widget _buildAutocompleteField() {
    return AutocompleteSearchField(
      label: "",
      hint: "Enter your area",
      controller: areaController,
      icon: Icons.area_chart,
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
    );
  }

  Widget _buildWebBikeSection() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bikes.length,
          itemBuilder: (context, index) => _buildWebBikeFields(index),
        ),
        if (bikes.length < 3)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _addBike,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Add Another Bike"),
              style: TextButton.styleFrom(
                foregroundColor: context.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWebBikeFields(int index) {
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

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]?.withOpacity(0.3)
            : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[700]!
              : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bike ${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                if (bikes.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.redAccent),
                    onPressed: () => _removeBike(index),
                    tooltip: 'Remove Bike',
                  ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedBrand,
              decoration: context
                  .inputDecoration("", "Choose brand",
                      icon: Icons.two_wheeler_outlined, borderRadius: 8.0)
                  .copyWith(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                  ),
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
            if (isBrandOthers) ...[
              const SizedBox(height: 20),
              _buildTextField('Enter Brand Name', brandController,
                  focusNode: brandFocusNodes[index],
                  icon: Icons.edit_outlined,
                  isRequired: true),
            ],
            if (!isBrandOthers) ...[
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedModel,
                decoration: context
                    .inputDecoration(
                      "",
                      selectedBrand != null
                          ? "Choose model"
                          : "Select a brand first",
                      icon: Icons.motorcycle_outlined,
                      borderRadius: 8.0,
                    )
                    .copyWith(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
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
              if (isModelOthers) ...[
                const SizedBox(height: 20),
                _buildTextField('Enter Model Name', modelController,
                    focusNode: modelFocusNodes[index],
                    icon: Icons.edit_outlined,
                    isRequired: true),
              ],
            ],
            if (isBrandOthers) ...[
              const SizedBox(height: 20),
              _buildTextField('Enter Model Name', modelController,
                  icon: Icons.motorcycle_outlined, isRequired: true),
            ],
            const SizedBox(height: 20),
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
}
