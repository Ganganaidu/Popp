import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:poppflutter/src/login/model/user_data_model.dart';
import 'package:poppflutter/src/login/sign_up_bike_details_screen.dart';
import 'package:poppflutter/src/login/validation_requiremen_text.dart';
import 'package:poppflutter/src/utils/app_utils.dart';
import 'package:poppflutter/src/utils/build_extensions.dart';

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
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isPasswordRequirementsExpanded = false; // Initially collapsed
  bool isSubmitting = false;

  Future<void> goToBikeDetailsPage() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSubmitting = true);

      try {
        final userId = await registerUserWithEmail(
            emailController.text, passwordController.text);

        setState(() => isSubmitting = false);
        if (userId != null) {
          // Registration successful, navigate to home screen or show success message
          AppLogger.d("User registered successfully: $userId");
          UserData userData = UserData(
            uid: userId,
            username: usernameController.text,
            email: emailController.text,
            phoneNumber: phoneNumberController.text,
            address: addressController.text,
            stateName: selectedState ?? "",
            city: cityController.text,
            pinCode: pinCodeController.text,
            createdAt: FieldValue.serverTimestamp(),
          );

          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpBikeDetailsScreen(userData: userData),
            ),
          );
        } else {}
      } on FirebaseAuthException catch (e) {
        setState(() => isSubmitting = false);
        String errorMessage;
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            errorMessage = 'The account already exists for that email.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          default:
            errorMessage = 'An undefined error happened.';
        }
        // Display errorMessage to the user (e.g., in a SnackBar or Dialog)
        AppLogger.e("Error registering user: $errorMessage (Code: ${e.code})");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        return;
      } catch (e) {
        setState(() => isSubmitting = false);
        // Handle other generic errors
        AppLogger.e("An unexpected error occurred: $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("An unexpected error occurred Please try again")),
        );
        return;
        // Display a generic error message to the user
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30),
                      const Text("Sign up",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      Text("Create your account",
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[700]),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      _buildTextField("Username", usernameController,
                          icon: Icons.person),
                      _buildTextField("Email", emailController,
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress),
                      _buildTextField("Phone number ", phoneNumberController,
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
                      CustomDropdownFormField<String>(
                        value: selectedState,
                        label: "",
                        hint: "Select your state",
                        items: stateNames
                            .map((b) =>
                                DropdownMenuItem(value: b, child: Text(b)))
                            .toList(),
                        onChanged: (val) => setState(() => selectedState = val),
                        // This should now work
                        validator: (val) =>
                            val == null ? "Required" : null, // Adjust validator
                      ),
                      const SizedBox(height: 20),
                      _buildTextField("City", cityController),
                      _buildTextField("Address", addressController,
                          icon: null, maxLines: 2),
                      _buildTextField("Pin Code", pinCodeController,
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 20),
                      _buildPasswordRequirementsDisclosure(),
                      // Your new disclosure widget
                      const SizedBox(height: 10),
                      _buildGeneralRequirementsDisclosure(),
                      // Optional: for other fields
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: isSubmitting ? null : goToBikeDetailsPage,
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Next",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget for Password Requirements Disclosure
  Widget _buildPasswordRequirementsDisclosure() {
    final currentPassword = passwordController.text;
    ThemeData theme = Theme.of(context);

    return Card(
      // Wrap ExpansionTile in a Card for distinct background and elevation
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1, // Subtle elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        key: const PageStorageKey<String>('passwordRequirements'),
        // Helps maintain state on scroll
        title: Text(
          "Password Requirements",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor.withOpacity(0.5),
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
          // ValidationRequirementText(
          //   text: "At least one special character (!@#\$%^&*...)",
          //   isValid: RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(currentPassword),
          // ),
        ],
      ),
    );
  }

  // Optional: Disclosure for other general requirements
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
            color: theme.primaryColor.withOpacity(0.5),
          ),
        ),
        initiallyExpanded: false,
        // Collapse by default
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
                .copyWith(top: 0),
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: theme.colorScheme.onSurfaceVariant,
        children: const <Widget>[
          ValidationRequirementText(text: "Username", isValid: true),
          // 'isValid' might be static for these
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

  // Inside _SignupScreenState class
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
            return 'Required';
          }

          if (hint == "Email") {
            if (value != null && !AppUtils.isEmailValid(value)) {
              return 'Enter a valid email address';
            }
          }

          // --- Password Validations ---
          if (hint == "Password") {
            if (value != null) {
              if (value.length < 6) {
                return 'Password must be at least 6 characters long';
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
              // Optional: Special character validation
              // if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(value)) {
              //   return 'Password must contain a special character';
              // }
            }
          }
          // --- End Password Validations ---
          if (hint == "Confirm Password") {
            if (controller.text != passwordController.text) {
              // Accessing passwordController directly
              return "Passwords do not match";
            }
          }

          if (hint == "Pin Code") {
            if (value != null) {
              // Your existing pincode validation
              if (value.length != 6) {
                // Assuming pincode should be 6 digits
                return 'Pincode must be 6 digits';
              }
              if (!RegExp(r"^[0-9]{6}$").hasMatch(value)) {
                // Assuming 6 digits
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
