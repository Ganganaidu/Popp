import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerSection extends StatefulWidget {
  // Changed to StatefulWidget
  final List<File> images;
  final Function(List<File>) onImagesChanged;

  const ImagePickerSection({
    super.key,
    required this.images,
    required this.onImagesChanged,
  });

  @override
  State<ImagePickerSection> createState() => _ImagePickerSectionState();
}

class _ImagePickerSectionState extends State<ImagePickerSection> {
  // State class
  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      List<File> newFiles =
          pickedFiles.map((xFile) => File(xFile.path)).toList();
      List<File> updatedImages = [...widget.images, ...newFiles];

      // Check if the widget is still in the tree before using context
      if (!mounted) return;

      if (updatedImages.length > 10) {
        updatedImages = updatedImages.sublist(0, 10);
        ScaffoldMessenger.of(context).showSnackBar(
          // context is now from the State
          const SnackBar(content: Text("Limit is 10 images.")),
        );
        return;
      }
      widget.onImagesChanged(updatedImages);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        if (widget.images.length < 10)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: double.infinity,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              // Add some horizontal padding
              decoration: BoxDecoration(
                color: Colors.orange[100], // Example: Light blue background
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                // Ensure vertical centering
                mainAxisSize: MainAxisSize.min,
                // Make the Row only as wide as its content
                children: [
                  Text(
                    "Add Photos",
                    style: TextStyle(
                      fontSize: 14, // Slightly larger font
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800], // Example: Dark blue text
                    ),
                  ),
                  const SizedBox(width: 8), // A bit more space
                  Icon(
                    Icons.camera_alt,
                    size: 20, // Slightly larger icon
                    color: Colors.blue[800], // Example: Dark blue icon
                  ),
                ],
              ),
            ),
          ),
        ...widget.images.map((img) => Padding(
              // Added Padding widget
              padding: const EdgeInsets.all(8.0), // Adjust padding as needed
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.file(File(img.path),
                      width: 80, height: 80, fit: BoxFit.cover),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: Colors.red),
                    onPressed: () {
                      final updated = [...widget.images]..remove(img);
                      widget.onImagesChanged(updated);
                    },
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
