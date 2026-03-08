import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/api/api_url.dart';
import 'package:popp/src/login/model/user_data_model.dart'; // Adjust path to your UserData model
import 'package:popp/src/theme/bikerverse_colors.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:popp/src/widgets/web_constrained_box.dart';
import 'package:url_launcher/url_launcher.dart';

import '../navigation/nav_router.dart';
import '../utils/product_content_data.dart';
import '../widgets/custom_dropdown_form_field.dart';
import '../widgets/title_text.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  String? selectedState;

  bool _isLoading = true;
  bool _isSaving = false;
  UserData? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle user not logged in case
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found. Please log in again.')),
        );
      }
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection(ApiUrl.userPath)
          .doc(user.uid)
          .get();
      if (doc.exists) {
        _userData = UserData.fromFirestore(doc);
        _nameController.text = _userData?.username ?? '';
        _addressController.text = _userData?.address ?? '';
        _cityController.text = _userData?.city ?? '';
        selectedState = _userData?.stateName ?? '';
      }
    } catch (e) {
      AppLogger.e("Error loading user data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile data.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection(ApiUrl.userPath)
          .doc(user.uid)
          .update({
        'username': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'stateName': selectedState,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop(); // Go back after saving
      }
    } catch (e) {
      AppLogger.e("Error updating user data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _launchDeleteAccountUrl() async {
    // IMPORTANT: Replace with your actual account deletion URL
    final Uri url = Uri.parse(ApiUrl.deleteAccountPolicy);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Could not open the link. Please visit ${url.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitleText('Profile Details'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text('Could not load profile.'))
              : WebConstrainedBox(child: _buildProfileForm()),
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Personal Information'),
                  _buildReadOnlyField(
                    label: 'Email Address',
                    value: _userData!.email,
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    suffix: Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Preview",
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Name cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("State"),
                      const SizedBox(height: 8),
                      CustomDropdownFormField<String>(
                        value: (selectedState == null || selectedState!.isEmpty)
                            ? _userData!.stateName
                            : selectedState,
                        label: "",
                        hint: "Select your state",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                        dropdownColor: BikerverseColors.cardElevated,
                        fillColor: BikerverseColors.cardElevated,
                        prefixIcon:
                            const Icon(Icons.apartment, color: Colors.grey),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: BikerverseColors.cardElevated,
                          prefixIcon:
                              const Icon(Icons.apartment, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1), width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: BikerverseColors.accent),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                        items: stateNames
                            .map((b) =>
                                DropdownMenuItem(value: b, child: Text(b)))
                            .toList(),
                        onChanged: (val) => setState(() => selectedState = val),
                        validator: (val) =>
                            val == null ? "State is required" : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _cityController,
                    label: 'City',
                    icon: Icons.location_city,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Account Management'),
                  _buildListTile(
                    context,
                    icon: Icons.lock_outline,
                    title: "Change Password",
                    enabled: FirebaseAuth.instance.currentUser != null,
                    onTap: () => onForgotPasswordTap(context, true),
                  ),
                  const SizedBox(height: 10),
                  _buildDeletionInfo(),
                ],
              ),
            ),
          ),
          _buildSaveButton(),
          const SizedBox(height: 35),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 20.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: BikerverseColors.accent,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: BikerverseColors.cardElevated,
            prefixIcon: Icon(icon, color: Colors.grey),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: BikerverseColors.accent),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(
      {required String label, required String value, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          readOnly: true,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: BikerverseColors.cardElevated,
            prefixIcon: Icon(icon, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: BikerverseColors.background,
      // Match background to hide line if needed, or just overlay
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDeletionInfo() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F1212), // Deep red/brown background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3E1F1F), width: 1),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.delete_outline, color: Color(0xFFE25C5C), size: 28),
              SizedBox(width: 12),
              Text(
                'DELETE ACCOUNT',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.0,
                  color: Color(0xFFE25C5C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'If you wish to permanently delete your account and all associated data, please follow the link below. This action is irreversible.',
            style: TextStyle(
              color: const Color(0xFFE25C5C).withOpacity(0.8),
              height: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _launchDeleteAccountUrl,
            child: const Text(
              'PROCEED TO ACCOUNT DELETION',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 1.2,
                color: Color(0xFF5FACE3),
                // Blue link color
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF5FACE3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        // Navigate to login screen or splash screen after logout
        // Replace '/login' with your actual login route
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      AppLogger.e("Error logging out: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to logout.')),
        );
      }
    }
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Row(
        children: [
          // Logout Button
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: const Color(0xFFE25C5C), // Red color
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'LOGOUT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Save Button
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _updateUserData,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: BikerverseColors.accent,
                  foregroundColor: Colors.black,
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 3),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, color: Colors.black, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'SAVE',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    bool enabled = true,
    bool disableArrow = true,
    bool isHighlight = false,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: BikerverseColors.cardElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ??
            (disableArrow && enabled
                ? const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey)
                : null),
        enabled: enabled,
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
