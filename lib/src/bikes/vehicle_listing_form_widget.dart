import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class VehicleListingFormWidget extends StatefulWidget {
  const VehicleListingFormWidget({super.key});

  @override
  State<VehicleListingFormWidget> createState() =>
      _VehicleListingFormWidgetState();
}

class _VehicleListingFormWidgetState extends State<VehicleListingFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];

  final _brandNameController = TextEditingController();
  final _modelNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _expectedPriceController = TextEditingController();

  bool _isLoading = false;

  Future<List<String>> uploadImages(List<XFile> images) async {
    List<String> downloadUrls = [];
    final uuid = const Uuid().v4();

    for (var image in images) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('bikes/$uuid/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await ref.putFile(File(image.path));
      final url = await uploadTask.ref.getDownloadURL();
      downloadUrls.add(url);
    }

    return downloadUrls;
  }

  Future<void> submitListing() async {
    if (!_formKey.currentState!.validate() || _images.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final imageUrls = await uploadImages(_images);
      final uid = FirebaseAuth.instance.currentUser?.uid;

      final listing = {
        'brandName': _brandNameController.text.trim(),
        'modelName': _modelNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'expectedPrice': int.parse(_expectedPriceController.text),
        'imageUrls': imageUrls,
        'status': 'pending',
        'sellerId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('bikes').add(listing);

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Listing submitted for approval.")),
        );
      }

      // Optionally: reset form
      _formKey.currentState?.reset();
      setState(() {
        _images = [];
      });
    } catch (e) {
      print("Error: $e");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Something went wrong. Please try again.")),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() => _images = picked);
    }
  }

  @override
  void dispose() {
    _brandNameController.dispose();
    _modelNameController.dispose();
    _descriptionController.dispose();
    _expectedPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _brandNameController,
                    decoration: const InputDecoration(labelText: "Brand Name"),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: _modelNameController,
                    decoration: const InputDecoration(labelText: "Model Name"),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                    maxLines: 3,
                    validator: (value) =>
                        value == null || value.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: _expectedPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "Expected Price (INR)"),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: pickImages,
                    icon: const Icon(Icons.image),
                    label: Text(_images.isEmpty
                        ? "Pick Images"
                        : "${_images.length} Images Selected"),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: submitListing,
                    child: const Text("Submit Listing"),
                  ),
                ],
              ),
            ),
          );
  }
}
