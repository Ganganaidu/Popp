import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerSection extends StatefulWidget { // Changed to StatefulWidget
  final List<XFile> images;
  final Function(List<XFile>) onImagesChanged;

  const ImagePickerSection({
    super.key,
    required this.images,
    required this.onImagesChanged,
  });

  @override
  State<ImagePickerSection> createState() => _ImagePickerSectionState();
}

class _ImagePickerSectionState extends State<ImagePickerSection> { // State class
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();

    // Check if the widget is still in the tree before using context
    if (!mounted) return;

    if (picked.length + widget.images.length > 10) {
      ScaffoldMessenger.of(context).showSnackBar( // context is now from the State
        const SnackBar(content: Text("Limit is 10 images.")),
      );
      return;
    }
    widget.onImagesChanged([...widget.images, ...picked]);
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
            onTap: _pickImages, // Call _pickImages without context
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }
}