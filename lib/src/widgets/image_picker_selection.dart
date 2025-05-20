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
        ...widget.images.map((img) => Stack(
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
            )),
        if (widget.images.length < 10)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: 90,
              height: 90,
              color: Colors.white,
              child: const Column(
                // Wrap Icon in a Column
                mainAxisAlignment: MainAxisAlignment.center,
                // Center content vertically
                children: [
                  Text(
                    "Add Bike Photos", // Your suggested title
                    style: TextStyle(
                      // Style similar to SellerBikeDetails (adjust as needed)
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4), // Add some space between title and icon
                  Icon(Icons.add),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
