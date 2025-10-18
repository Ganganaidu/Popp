import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../api/api_url.dart';
import '../../deeplink/DeepLinkConfig.dart';
import '../../gallery/pic_image_gallery.dart';
import '../../utils/app_loger.dart';
import '../../widgets/image_picker_selection.dart';

class AdsSubmissionScreen extends StatefulWidget {
  const AdsSubmissionScreen({super.key});

  @override
  State<AdsSubmissionScreen> createState() => _AdsSubmissionScreenState();
}

class _AdsSubmissionScreenState extends State<AdsSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _highlightController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _buttonTextController = TextEditingController();
  final TextEditingController _productIdController = TextEditingController();

  final _adsCollection = FirebaseFirestore.instance.collection(ApiUrl.adsPath);

  List<File> _selectedImages = [];
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;
  bool _isSubmitting = false;

  final List<String> _deepLinks = deepLinkConfigs.keys.toList();
  String _selectedDeepLink = aboutUs;

  @override
  void dispose() {
    _titleController.dispose();
    _highlightController.dispose();
    _subtitleController.dispose();
    _buttonTextController.dispose();
    _productIdController.dispose();
    _selectedImages.clear();
    super.dispose();
  }

  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Enforce that an image is provided (either selected and will be
    // uploaded, or already uploaded). The app previously allowed a
    // placeholder image silently; this change makes image mandatory as
    // requested.
    if ((_uploadedImageUrl == null || _uploadedImageUrl!.isEmpty) &&
        _selectedImages.isEmpty) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach an image for the ad')),
      );
      return;
    }

    try {
      // If admin selected images, upload them now (always upload newly selected images)
      final selectedFiles = _selectedImages;
      if (selectedFiles.isNotEmpty) {
        setState(() {
          _isUploadingImage = true;
        });
        try {
          final urls = await uploadMultipleImages(selectedFiles);
          if (urls.isNotEmpty) {
            _uploadedImageUrl = urls.first;
            // clear selected files after successful upload
            _selectedImages.clear();
          }
        } catch (e) {
          AppLogger.e('Image upload failed during submit: $e');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
          setState(() {
            _isUploadingImage = false;
            _isSubmitting = false;
          });
          return; // abort submit because upload failed
        } finally {
          setState(() {
            _isUploadingImage = false;
          });
        }
      }

      final docRef = _adsCollection.doc();

      final data = {
        'imageUrl': _uploadedImageUrl,
        'title': _titleController.text.trim(),
        'highlight': _highlightController.text.trim(),
        'subtitle': _subtitleController.text.trim(),
        'buttonText': _buttonTextController.text.trim(),
        'productId': _productIdController.text.trim(),
        'buttonLink': _selectedDeepLink,
        'isActive': true,
      };

      await docRef.set(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad submitted successfully')),
      );

      // reset form
      _formKey.currentState?.reset();
      _titleController.clear();
      _highlightController.clear();
      _subtitleController.clear();
      _buttonTextController.clear();
      _productIdController.clear();
      setState(() {
        _selectedDeepLink = aboutUs;
        _selectedImages.clear();
        _uploadedImageUrl = null;
        _isUploadingImage = false;
      });
    } catch (e) {
      AppLogger.e('Error submitting ad: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit ad: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create / Submit Ad',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Orbitron'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Use the reusable ImagePickerSection widget (gallery only, single image)
                  ImagePickerSection(
                    images: _selectedImages,
                    // only update selected images here; do not auto-upload
                    onImagesChanged: (files) {
                      setState(() {
                        _selectedImages = files;
                        // If admin selects a new image, clear _uploadedImageUrl so
                        // the new image will be uploaded during submit.
                        if (files.isNotEmpty) _uploadedImageUrl = null;
                      });
                    },
                    title: 'Attache Advertisement/Promo Image',
                    isGalleryOnly: true,
                    allowMultipleImages: false,
                  ),

                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _highlightController,
                    decoration: const InputDecoration(
                        labelText:
                            'Highlight (Subtitle that will come in Green color)'),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _subtitleController,
                    decoration: const InputDecoration(
                        labelText: 'Description about the promo/ad'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _buttonTextController,
                    decoration: const InputDecoration(
                        labelText: 'Button Text(e.g., Learn More/About us)'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Button text is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _productIdController,
                    decoration: const InputDecoration(
                      labelText:
                          'Product ID (required only if linking to a product)',
                      helperText:
                          'Optional: link this ad to a product or service id',
                    ),
                  ),
                  const SizedBox(height: 30),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDeepLink,
                    items: _deepLinks
                        .map((key) => DropdownMenuItem(
                            value: key,
                            // Prefer human-friendly label from deepLinkConfigs
                            // (loginMessage). Fallback to the key itself.
                            child: Text(
                                deepLinkConfigs[key]?.loginMessage ?? key)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _selectedDeepLink = v);
                    },
                    validator: (v) => v == null || v.isEmpty
                        ? 'Please select a deeplink for the button'
                        : null,
                    decoration: const InputDecoration(
                        labelText: 'Button Link (deeplink)'),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _isSubmitting || _isUploadingImage
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: Text((_isSubmitting || _isUploadingImage)
                            ? 'Please wait...'
                            : 'Submit Ad'),
                      ),
                      onPressed: (_isSubmitting || _isUploadingImage)
                          ? null
                          : _submitAd,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
