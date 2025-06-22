import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/app_loger.dart';

Future<File?> pickImageFromGallery() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    return File(pickedFile.path);
  } else {
    return null;
  }
}

Future<String> uploadImageToFirebase(
    File imageFile, String catId, String productId) async {
  final storageRef = FirebaseStorage.instance
      .ref()
      .child('product_images/$catId/$productId.jpg');

  final uploadTask = storageRef.putFile(imageFile);
  final snapshot = await uploadTask;

  // Get the download URL
  final downloadUrl = await snapshot.ref.getDownloadURL();
  return downloadUrl;
}

Future<List<File>> pickMultipleImages() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: true,
  );

  if (result != null) {
    return result.paths.map((path) => File(path!)).toList();
  } else {
    return [];
  }
}

Future<List<String>> uploadImagesHelper(
    List<File> images, BuildContext context, Function(bool) onLoading) async {
  if (images.isEmpty) return [];
  try {
    final urls = await uploadMultipleImages(images);
    if (urls.isEmpty) {
      onLoading(false);
      if (!context.mounted) return [];
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed. Please try again.')),
      );
      return [];
    }
    return urls;
  } catch (e) {
    onLoading(false);
    if (!context.mounted) return [];
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image upload failed. Please try again.')),
    );
    return [];
  }
}

Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
  List<String> downloadUrls = [];

  for (int i = 0; i < imageFiles.length; i++) {
    try {
      String fileName =
          'product_images/${DateTime.now().millisecondsSinceEpoch}_${imageFiles[i].path.split('/').last}';
      final storageRef = FirebaseStorage.instance.ref().child(fileName);

      final uploadTask = storageRef.putFile(imageFiles[i]);

      // Await the upload and get download URL
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      downloadUrls.add(downloadUrl);
    } on FirebaseException catch (e) {
      AppLogger.e(
          'Firebase upload error for image $i: ${e.code} - ${e.message}');
      rethrow; // or return []; to stop and indicate failure
    } catch (e) {
      AppLogger.e('Unexpected error during image upload $i: $e');
      rethrow; // or return []; or continue; based on desired behavior
    }
  }
  return downloadUrls;
}

Future<void> deleteImagesFromStorage(List<String> imageUrls) async {
  for (final imageUrl in imageUrls) {
    await deleteImageFromStorageByUrl(imageUrl);
  }
}

// In FirebaseProductsService or a separate StorageService
Future<void> deleteImageFromStorageByUrl(String imageUrl) async {
  if (imageUrl.isEmpty) return;
  try {
    Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
    await storageRef.delete();
    AppLogger.d("Image deleted from storage: $imageUrl");
  } catch (e) {
    // It's possible the file doesn't exist, or permissions error
    // Log it but don't necessarily treat it as a hard failure for the update flow
    AppLogger.w(
        "Error deleting image from storage ($imageUrl): $e. "
            "It might have already been deleted or path is incorrect.");
  }
}

// You might also want a function to delete a whole folder if all images for a product are changed.
Future<void> deleteProductImagesFolder(String productId) async {
  try {
    final listResult = await FirebaseStorage.instance
        .ref('product_images/$productId')
        .listAll();
    for (final item in listResult.items) {
      await item.delete();
    }
    AppLogger.d("All images for product $productId deleted from storage.");
  } catch (e) {
    AppLogger.w("Error deleting images folder for product $productId: $e");
  }
}

// Future<void> pickAndUploadMultipleImages() async {
//   final imageFiles = await pickMultipleImages();
//
//   if (imageFiles.isNotEmpty) {
//     final productId = "prod_001"; // your product ID
//     final imageUrls = await uploadMultipleImages(imageFiles, productId);
//
//     print('Uploaded Images URLs: $imageUrls');
//
//     // Now you can store this List<String> imageUrls to Firestore under 'imageUrls' field
//   } else {
//     print('No images selected.');
//   }
// }

// Future<void> pickAndUploadImage() async {
//   final imageFile = await pickImageFromGallery();
//   if (imageFile != null) {
//     final productId = "prod_001"; // Generate productId before if needed
//     final imageUrl = await uploadImageToFirebase(imageFile, productId);
//     print('Uploaded Image URL: $imageUrl');
//     // Now you can store this imageUrl along with product info in Firestore!
//   } else {
//     print('No image selected.');
//   }
// }
