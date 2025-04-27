import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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

Future<List<String>> uploadMultipleImages(List<File> imageFiles, String productId) async {
  List<String> downloadUrls = [];

  for (int i = 0; i < imageFiles.length; i++) {
    final storageRef = FirebaseStorage.instance.ref().child('product_images/${productId}_$i.jpg');

    final uploadTask = storageRef.putFile(imageFiles[i]);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    downloadUrls.add(downloadUrl);
  }

  return downloadUrls;
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
