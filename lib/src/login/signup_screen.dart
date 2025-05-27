import 'package:flutter/material.dart';
import 'package:poppflutter/src/login/model/user_data_model.dart';
import 'package:poppflutter/src/login/sign_up_bike_details_screen.dart';
import 'package:poppflutter/src/utils/build_extensions.dart';
import '../services/models/bike_form_data.dart';

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

  void goToBikeDetailsPage() {
    if (_formKey.currentState!.validate()) {
      UserData userData = UserData(
        username: usernameController.text,
        email: emailController.text,
        phoneNumber: phoneNumberController.text,
        password: passwordController.text,
        address: addressController.text,
        state: selectedState ?? "",
        city: cityController.text,
        pinCode: pinCodeController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpBikeDetailsScreen(userData: userData),
        ),
      );
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
                      _buildTextField(
                          "Phone number optional", phoneNumberController,
                          keyboardType: TextInputType.number,
                          isRequired: false),
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
                      DropdownButtonFormField<String>(
                        value: selectedState,
                        decoration:
                            context.inputDecoration("", "Select your state"),
                        items: stateNames
                            .map((state) => DropdownMenuItem(
                                value: state, child: Text(state)))
                            .toList(),
                        onChanged: (val) => setState(() => selectedState = val),
                        validator: (val) => val == null ? "Required" : null,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField("City", cityController),
                      _buildTextField("Address", addressController,
                          icon: null, maxLines: 2),
                      _buildTextField("Pin Code", pinCodeController,
                          keyboardType: TextInputType.number),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: goToBikeDetailsPage,
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                ),
                child: const Text("Next",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            )
          ],
        ),
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
            return 'Required';
          }
          if (hint == "Email") {
            // Check if the field is for Email
            if (value != null &&
                !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value)) {
              return 'Enter a valid email address';
            }
          }
          if (hint == "Confirm Password" &&
              controller.text != passwordController.text) {
            return "Passwords do not match";
          }
          // PinCode Validation
          if (hint == "Pin Code") {
            if (value != null) {
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
