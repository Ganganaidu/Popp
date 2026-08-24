import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popp/src/utils/app_constants.dart';

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

  Future<void> _pickSingleImage(ImageSource source) async {
    if (widget.images.length >= _maxImages) {
      _showMaxImagesDialog();
      return;
    }
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final newImages = List<File>.from(widget.images)..add(File(pickedFile.path));
      widget.onImagesChanged(newImages);
    }
  }

  Future<void> _pickMultipleImages() async {
    if (widget.images.length >= _maxImages) {
      _showMaxImagesDialog();
      return;
    }
    final remaining = _maxImages - widget.images.length;
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null && result.paths.isNotEmpty) {
      final files = result.paths.map((p) => File(p!)).toList();
      final accepted = files.length > remaining ? files.sublist(0, remaining) : files;
      final newImages = List<File>.from(widget.images)..addAll(accepted);
      widget.onImagesChanged(newImages);
      if (files.length > accepted.length) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You selected ${files.length} images, but only ${accepted.length} were added. '
              'Max $_maxImages images allowed.',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    final newImages = List<File>.from(widget.images)..removeAt(index);
    widget.onImagesChanged(newImages);
  }

  void _handleAddTap() {
    if (widget.images.length >= _maxImages) {
      _showMaxImagesDialog();
      return;
    }
    if (widget.allowGallery && widget.allowCamera) {
      _showImageSourceSheet();
    } else if (widget.allowGallery) {
      if (widget.allowMultipleImages) {
        _pickMultipleImages();
      } else {
        _pickSingleImage(ImageSource.gallery);
      }
    } else if (widget.allowCamera) {
      _pickSingleImage(ImageSource.camera);
    } else {
      _showImageSourceSheet();
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(sheetCtx).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (widget.allowGallery)
              ListTile(
                leading: Icon(Icons.photo_library_outlined,
                    color: Theme.of(sheetCtx)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6)),
                title: Text('Choose from Gallery',
                    style: TextStyle(
                        color: Theme.of(sheetCtx).colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  if (widget.allowMultipleImages) {
                    _pickMultipleImages();
                  } else {
                    _pickSingleImage(ImageSource.gallery);
                  }
                },
              ),
            if (widget.allowCamera)
              ListTile(
                leading: Icon(Icons.camera_alt_outlined,
                    color: Theme.of(sheetCtx)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6)),
                title: Text('Take a Photo',
                    style: TextStyle(
                        color: Theme.of(sheetCtx).colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _pickSingleImage(ImageSource.camera);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.images.length;
    final atMax = count >= _maxImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Text(
              '$count/$_maxImages · first is cover',
              style: TextStyle(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            if (!atMax) _AddPhotoTile(onTap: _handleAddTap),
            for (int i = 0; i < widget.images.length; i++)
              _ImageTile(
                file: widget.images[i],
                isCover: i == 0,
                onRemove: () => _removeImage(i),
              ),
          ],
        ),
      ],
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPhotoTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
            color: Theme.of(context).colorScheme.primary),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined,
                  color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(height: 6),
              Text(
                'Add photo',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final File file;
  final bool isCover;
  final VoidCallback onRemove;
  const _ImageTile(
      {required this.file, required this.isCover, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.antiAlias,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(file, fit: BoxFit.cover),
          ),
        ),
        if (isCover)
          Positioned(
            left: 6,
            top: 6,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'COVER',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 1.5;
    const dashLength = 6.0;
    const gapLength = 5.0;
    const radius = 12.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromLTRBR(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth / 2,
      size.height - strokeWidth / 2,
      const Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        dashPath.addPath(metric.extractPath(distance, end), Offset.zero);
        distance += dashLength + gapLength;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
