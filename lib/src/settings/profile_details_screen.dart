import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:popp/src/api/api_url.dart';
import 'package:popp/src/login/model/user_data_model.dart'; // Adjust path to your UserData model
import 'package:popp/src/utils/app_loger.dart';
import 'package:popp/src/utils/build_extensions.dart';
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
    final Uri url = Uri.parse('https://popp-71efb.web.app/delete-account.html');
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
              : _buildProfileForm(),
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
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Name cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomDropdownFormField<String>(
                      value: (selectedState == null || selectedState!.isEmpty)
                          ? _userData!.stateName
                          : selectedState,
                      label: "",
                      hint: "Select your state",
                      items: stateNames
                          .map(
                              (b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedState = val),
                      validator: (val) =>
                          val == null ? "State is required" : null),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _cityController,
                    label: 'City',
                    icon: Icons.location_city,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 32),
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
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: context.inputDecoration(label, "", icon: icon),
      validator: validator,
    );
  }

  Widget _buildReadOnlyField(
      {required String label, required String value, required IconData icon}) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: context.inputDecoration(label, "", icon: icon, enable: false),
    );
  }

  Widget _buildDeletionInfo() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.red.shade100, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delete Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'If you wish to permanently delete your account and all associated data, please follow the link below. This action is irreversible.',
              style: TextStyle(color: Colors.red.shade700, height: 1.5),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _launchDeleteAccountUrl,
                child: const Text(
                  'Proceed to Account Deletion',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _updateUserData,
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: context.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3),
                )
              : const Text('Save Changes', style: TextStyle(fontSize: 18)),
        ),
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
    final color =
        isHighlight ? context.primaryColor : Theme.of(context).iconTheme.color;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ??
            (disableArrow && enabled
                ? const Icon(Icons.arrow_forward_ios, size: 16)
                : null),
        enabled: enabled,
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
