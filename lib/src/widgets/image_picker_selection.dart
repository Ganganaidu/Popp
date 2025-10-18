import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

// widgets/image_picker_selection.dart
class ImagePickerSection extends StatefulWidget {
  final List<File> images;
  final ValueChanged<List<File>> onImagesChanged;
  final String title;
  final bool isCameraOnly;
  final bool isGalleryOnly;
  final bool allowMultipleImages;

  const ImagePickerSection({
    super.key,
    required this.images,
    required this.onImagesChanged,
    this.title = "Upload Pictures",
    this.isCameraOnly = false,
    this.isGalleryOnly = false,
    this.allowMultipleImages = false,
  });

  @override
  State<ImagePickerSection> createState() => _ImagePickerSectionState();
}

class _ImagePickerSectionState extends State<ImagePickerSection> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickSingleImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        final newImages = List<File>.from(widget.images);
        newImages.add(File(pickedFile.path));
        widget.onImagesChanged(newImages);
      });
    }
  }

  Future<void> _pickMultipleImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null && result.paths.isNotEmpty) {
      final files = result.paths.map((p) => File(p!)).toList();
      final newImages = List<File>.from(widget.images)..addAll(files);
      widget.onImagesChanged(newImages);
    }
  }

  void _removeImage(int index) {
    setState(() {
      final newImages = List<File>.from(widget.images);
      newImages.removeAt(index);
      widget.onImagesChanged(newImages);
    });
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (!widget.isGalleryOnly)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickSingleImage(ImageSource.camera);
                  },
                ),
              if (!widget.isCameraOnly)
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.allowMultipleImages) {
                      _pickMultipleImages();
                    } else {
                      _pickSingleImage(ImageSource.gallery);
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        SizedBox(
          height: 100, // Adjust height as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.images.length + 1, // +1 for the add button
            itemBuilder: (context, index) {
              if (index == widget.images.length) {
                return GestureDetector(
                  onTap: () {
                    // If gallery only, open gallery directly. If camera only, open camera. Otherwise show options.
                    if (widget.isGalleryOnly) {
                      if (widget.allowMultipleImages) {
                        _pickMultipleImages();
                      } else {
                        _pickSingleImage(ImageSource.gallery);
                      }
                    } else if (widget.isCameraOnly) {
                      _pickSingleImage(ImageSource.camera);
                    } else {
                      _showImageSourceActionSheet(context);
                    }
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Icon(Icons.add_a_photo,
                        color: Colors.grey, size: 40),
                  ),
                );
              } else {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(widget.images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
