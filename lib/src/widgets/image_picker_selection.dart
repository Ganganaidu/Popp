import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:popp/src/utils/app_constants.dart';

// widgets/image_picker_selection.dart
class ImagePickerSection extends StatefulWidget {
  final List<File> images;
  final ValueChanged<List<File>> onImagesChanged;
  final String title;
  final bool allowCamera;
  final bool allowGallery;
  final bool allowMultipleImages;

  const ImagePickerSection({
    super.key,
    required this.images,
    required this.onImagesChanged,
    this.title = "Upload Pictures",
    this.allowCamera = true,
    this.allowGallery = false,
    this.allowMultipleImages = false,
  });

  @override
  State<ImagePickerSection> createState() => _ImagePickerSectionState();
}

class _ImagePickerSectionState extends State<ImagePickerSection> {
  final ImagePicker _picker = ImagePicker();
  static const int _maxImages = 8;

  // Show a non-blocking SnackBar informing the user about the max images limit.
  void _showMaxImagesDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Max 8 images allowed. To submit more, '
          'finish this listing and contact ${Constants.appName} support — they can '
          'help add extra photos for you.',
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  // Append single picked image so the internal list stays chronological (oldest->newest).
  // The UI reverses this list so the newest image displays first.
  Future<void> _pickSingleImage(ImageSource source) async {
    if (widget.images.length >= _maxImages) {
      _showMaxImagesDialog();
      return;
    }

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        final newImages = List<File>.from(widget.images);
        newImages.add(File(pickedFile.path)); // append newest at end
        widget.onImagesChanged(newImages);
      });
    }
  }

  // Append multiple picked images in selection order; the UI will reverse the list so the last selected displays first.
  Future<void> _pickMultipleImages() async {
    if (widget.images.length >= _maxImages) {
      _showMaxImagesDialog();
      return;
    }

    final remaining = _maxImages - widget.images.length;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null && result.paths.isNotEmpty) {
      final files = result.paths.map((p) => File(p!)).toList();

      // If user selected more files than remaining capacity, accept only up to remaining
      final accepted =
          files.length > remaining ? files.sublist(0, remaining) : files;

      setState(() {
        final newImages = List<File>.from(widget.images);
        // Append the accepted picked files so the chronological order is preserved
        newImages.addAll(accepted);
        widget.onImagesChanged(newImages);
      });

      if (files.length > accepted.length) {
        // Notify user that only a subset was accepted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You selected ${files.length} images, but only ${accepted.length} were added. '
              'Max $_maxImages images allowed. To add more, please contact '
              '${Constants.appName} support after submitting this listing.',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
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
              if (widget.allowGallery)
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.images.length >= _maxImages) {
                      _showMaxImagesDialog();
                      return;
                    }
                    if (widget.allowMultipleImages) {
                      _pickMultipleImages();
                    } else {
                      _pickSingleImage(ImageSource.gallery);
                    }
                  },
                ),
              if (widget.allowCamera)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.images.length >= _maxImages) {
                      _showMaxImagesDialog();
                      return;
                    }
                    _pickSingleImage(ImageSource.camera);
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
    // We'll display an add button first, then images in newest-first order by reversing the chronological list.
    final displayedImages = widget.images.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        SizedBox(
          height: 100, // Adjust height as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayedImages.length + 1,
            // +1 for the add button at start
            itemBuilder: (context, index) {
              if (index == 0) {
                // Add/select button at the start
                return GestureDetector(
                  onTap: () {
                    // If already at max, show dialog and don't open picker
                    if (widget.images.length >= _maxImages) {
                      _showMaxImagesDialog();
                      return;
                    }

                    // If gallery only, open gallery directly. If camera only, open camera. Otherwise show options.
                    if (widget.allowGallery) {
                      if (widget.allowMultipleImages) {
                        _pickMultipleImages();
                      } else {
                        _pickSingleImage(ImageSource.gallery);
                      }
                    } else if (widget.allowCamera) {
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
                // For displayedImages, map back to the original index when removing
                final displayedIndex = index - 1; // index into displayedImages
                final file = displayedImages[displayedIndex];
                // original index in widget.images (chronological list): last element is newest
                final originalIndex = widget.images.length - 1 - displayedIndex;

                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(file),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _removeImage(originalIndex),
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
