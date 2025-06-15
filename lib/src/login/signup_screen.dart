import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/login/model/user_data_model.dart';
import 'package:popp/src/login/register_and_subscribe_screen.dart';
import 'package:popp/src/login/validation_requiremen_text.dart';
import 'package:popp/src/utils/app_utils.dart';
import 'package:popp/src/utils/build_extensions.dart';

import '../firebase/auth_service.dart';
import '../utils/product_content_data.dart';
import '../utils/app_loger.dart';
import '../widgets/custom_dropdown_form_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedState;

  // Controllers for user details
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  // Controllers for bike details, starts with one entry.
  final List<Map<String, TextEditingController>> bikes = [
    {
      'brand': TextEditingController(),
      'model': TextEditingController(),
      'monthYear': TextEditingController(),
    }
  ];

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isPasswordRequirementsExpanded = false;
  bool isSubmitting = false;

  @override
  void dispose() {
    // Dispose all user detail controllers
    usernameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    addressController.dispose();
    cityController.dispose();
    pinCodeController.dispose();

    // Dispose all bike controllers to prevent memory leaks
    for (final bike in bikes) {
      bike['brand']!.dispose();
      bike['model']!.dispose();
      bike['monthYear']!.dispose();
    }
    super.dispose();
  }

  /// Adds a new set of bike form fields, up to a maximum of 3.
  void _addBike() {
    if (bikes.length < 3) {
      setState(() {
        bikes.add({
          'brand': TextEditingController(),
          'model': TextEditingController(),
          'monthYear': TextEditingController(),
        });
      });
    }
  }

  /// Removes a bike form field at a specific index.
  void _removeBike(int index) {
    if (bikes.length > 1) {
      setState(() {
        // Dispose controllers before removing to avoid memory leaks
        bikes[index]['brand']!.dispose();
        bikes[index]['model']!.dispose();
        bikes[index]['monthYear']!.dispose();
        bikes.removeAt(index);
      });
    } else {
      // Optionally, clear the fields of the last remaining bike
      bikes[index]['brand']!.clear();
      bikes[index]['model']!.clear();
      bikes[index]['monthYear']!.clear();
    }
  }

  /// Handles the entire registration process, including user and bike details,
  /// and then navigates to the subscribe screen.
  Future<void> _registerAndContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSubmitting = true);

      try {
        final userId = await registerUserWithEmail(
            emailController.text, passwordController.text);

        if (userId == null) {
          setState(() => isSubmitting = false);
          AppLogger.e("Registration failed, user ID is null.");
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration failed. Please try again.")),
          );
          return;
        }

        AppLogger.d("User registered successfully: $userId");

        // Collect bike data from controllers
        final bikeDataList = bikes
            .map((bikeControllers) => BikeData(
          brand: bikeControllers['brand']!.text,
          model: bikeControllers['model']!.text,
          monthYear: bikeControllers['monthYear']!.text,
        ))
            .where((bike) =>
        bike.brand.isNotEmpty ||
            bike.model.isNotEmpty ||
            bike.monthYear.isNotEmpty)
            .toList();

        // Create the complete UserData object
        UserData userData = UserData(
          uid: userId,
          username: usernameController.text,
          email: emailController.text,
          phoneNumber: phoneNumberController.text,
          address: addressController.text,
          stateName: selectedState ?? "",
          city: cityController.text,
          pinCode: pinCodeController.text,
          bikeData: bikeDataList, // Assign the collected bike data
          createdAt: FieldValue.serverTimestamp(),
        );

        setState(() => isSubmitting = false);

        if (!mounted) return;

        // Navigate to the final screen
        Navigator.pushReplacement( // Using pushReplacement to prevent going back to signup
          context,
          MaterialPageRoute(
            builder: (context) =>
                RegisterAndSubscribeScreen(userData: userData),
          ),
        );

      } on FirebaseAuthException catch (e) {
        setState(() => isSubmitting = false);
        String errorMessage;
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            errorMessage = 'An account already exists for that email.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          default:
            errorMessage = 'An undefined error happened.';
        }
        AppLogger.e("Error registering user: $errorMessage (Code: ${e.code})");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        setState(() => isSubmitting = false);
        AppLogger.e("An unexpected error occurred: $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("An unexpected error occurred. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text("Sign up",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      const Text("Create your account to get started",
                          style:
                          TextStyle(fontSize: 15, color: Colors.grey),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 30),
                      _buildTextField("Name", usernameController,
                          icon: Icons.person),
                      _buildTextField("Email", emailController,
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress),
                      _buildTextField("Phone number", phoneNumberController,
                          icon: Icons.phone_android_sharp,
                          keyboardType: TextInputType.number,
                          isRequired: true),
                      _buildTextField("Password", passwordController,
                          icon: Icons.lock,
                          isPasswordTextField: true,
                          currentPasswordVisibility: _isPasswordVisible,
                          onTogglePasswordVisibility: () {
                            setState(
                                    () => _isPasswordVisible = !_isPasswordVisible);
                          }),
                      _buildTextField(
                          "Confirm Password", confirmPasswordController,
                          icon: Icons.lock,
                          isPasswordTextField: true,
                          currentPasswordVisibility: _isConfirmPasswordVisible,
                          onTogglePasswordVisibility: () {
                            setState(() => _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible);
                          }),
                      _buildTextField("Address", addressController,
                          icon: Icons.home, maxLines: 2),
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
                        val == null ? "State is required" : null,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField("City", cityController, icon: Icons.location_city),
                      _buildTextField("Pin Code", pinCodeController,
                          icon: Icons.pin_drop,
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 20),

                      // --- Merged Bike Details Section ---
                      const Divider(thickness: 1),
                      const SizedBox(height: 20),
                      const Text(
                        'Please enter the details of bikes you own for custom notifications',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '(This step is optional. You can skip if you don’t own a bike.)',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
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
                            icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                            label: Text(
                              "Add Another Bike",
                              style: TextStyle(color: theme.colorScheme.primary),
                            ),
                          ),
                        ),
                      // --- End of Merged Section ---

                      const SizedBox(height: 20),
                      _buildPasswordRequirementsDisclosure(),
                      const SizedBox(height: 10),
                      _buildGeneralRequirementsDisclosure(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _registerAndContinue,
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Sign Up & Continue",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Builds the group of fields for a single bike.
  Widget _buildBikeFields(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bike ${index + 1} Details (Optional)',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  if (bikes.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                      onPressed: () => _removeBike(index),
                      tooltip: 'Remove Bike',
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                  'Brand Name', bikes[index]['brand']!, isRequired: false, icon: Icons.two_wheeler),
              _buildTextField(
                  'Model Name', bikes[index]['model']!, isRequired: false, icon: Icons.motorcycle),
              _buildTextField('MFG Month & Year',
                  bikes[index]['monthYear']!, isRequired: false, icon: Icons.calendar_today),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirementsDisclosure() {
    final currentPassword = passwordController.text;
    ThemeData theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        key: const PageStorageKey<String>('passwordRequirements'),
        title: Text(
          "Password Requirements",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
          ),
        ),
        initiallyExpanded: _isPasswordRequirementsExpanded,
        onExpansionChanged: (bool expanded) {
          setState(() {
            _isPasswordRequirementsExpanded = expanded;
          });
        },
        tilePadding:
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        childrenPadding:
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
            .copyWith(top: 0),
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: theme.colorScheme.onSurfaceVariant,
        children: <Widget>[
          ValidationRequirementText(
            text: "At least 8 characters",
            isValid: currentPassword.length >= 8,
          ),
          ValidationRequirementText(
            text: "At least one uppercase letter (A-Z)",
            isValid: RegExp(r'(?=.*[A-Z])').hasMatch(currentPassword),
          ),
          ValidationRequirementText(
            text: "At least one lowercase letter (a-z)",
            isValid: RegExp(r'(?=.*[a-z])').hasMatch(currentPassword),
          ),
          ValidationRequirementText(
            text: "At least one number (0-9)",
            isValid: RegExp(r'(?=.*\d)').hasMatch(currentPassword),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralRequirementsDisclosure() {
    ThemeData theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        key: const PageStorageKey<String>('generalRequirements'),
        title: Text(
          "Other Required Fields",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
          ),
        ),
        initiallyExpanded: false,
        tilePadding:
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        childrenPadding:
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
            .copyWith(top: 0),
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: theme.colorScheme.onSurfaceVariant,
        children: const <Widget>[
          ValidationRequirementText(text: "Username", isValid: true),
          ValidationRequirementText(
              text: "Email (must be valid)", isValid: true),
          ValidationRequirementText(text: "State", isValid: true),
          ValidationRequirementText(text: "City", isValid: true),
          ValidationRequirementText(text: "Address", isValid: true),
          ValidationRequirementText(text: "Pin Code (6 digits)", isValid: true),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String hint,
      TextEditingController controller, {
        IconData? icon,
        bool obscureText = false,
        int maxLines = 1,
        bool isRequired = true,
        TextInputType? keyboardType,
        bool isPasswordTextField = false,
        VoidCallback? onTogglePasswordVisibility,
        bool? currentPasswordVisibility,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPasswordTextField
            ? !(currentPasswordVisibility ?? false)
            : obscureText,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$hint is required';
          }

          if (hint == "Email") {
            if (value != null && !AppUtils.isEmailValid(value)) {
              return 'Enter a valid email address';
            }
          }

          if (hint == "Password") {
            if (value != null && isRequired) {
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
          }

          if (hint == "Confirm Password") {
            if (controller.text != passwordController.text) {
              return "Passwords do not match";
            }
          }

          if (hint == "Pin Code") {
            if (value != null && value.isNotEmpty) {
              if (value.length != 6) {
                return 'Pincode must be 6 digits';
              }
              if (!RegExp(r"^[0-9]{6}$").hasMatch(value)) {
                return 'Enter a valid pincode (only numbers)';
              }
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
      ),
    );
  }
}
