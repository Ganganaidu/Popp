import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:popp/src/login/model/user_data_model.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // canceled

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    await _saveUserToFireStore(userCredential.user);
  }

  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<void> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);
      final userCredential =
          await _auth.signInWithCredential(facebookAuthCredential);
      await _saveUserToFireStore(userCredential.user);
    }
  }

  Future<void> signInWithApple() async {
    if (!Platform.isIOS) return;

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName
      ],
    );

    final oAuthCredential = OAuthProvider("apple.com").credential(
      idToken: credential.identityToken,
      accessToken: credential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(oAuthCredential);
    await _saveUserToFireStore(userCredential.user);
  }

  Future<void> _saveUserToFireStore(User? user) async {
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final doc = await docRef.get();
    if (doc.exists) {
      AppLogger.i('User already exists. Skipping Firestore write.');
      return;
    }

    AppLogger.i("Saving user in firebase ${user.toString()}");
    await _fireStore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? '',
      'photoURL': user.photoURL ?? '',
      'provider': user.providerData.first.providerId,
    }, SetOptions(merge: true));
  }
}

Future<String?> registerUserWithEmail(String email, String password) async {
  try {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return credential.user?.uid;
  } on FirebaseAuthException catch (e) {
    // You can handle specific error codes here or re-throw a more specific exception
    AppLogger.e(
        "FirebaseAuthException during registration: ${e.code} - ${e.message}");
    rethrow; // Re-throwing the Firebase specific exception
  } catch (e, s) {
    AppLogger.e("Unexpected error during registration: $e. StackTrace: $s");
    // You might want to throw a generic error or a custom one
    throw Exception("An unexpected error occurred during registration.");
  }
}

// Option B: Return a more detailed result object (recommended for richer feedback)
class FireStoreResult {
  final bool success;
  final String? errorMessage;
  final String? errorCode; // For Firebase specific error codes

  FireStoreResult({required this.success, this.errorMessage, this.errorCode});
}

Future<FireStoreResult> saveUserDataToFireStore(UserData userData) async {
  final auth = FirebaseAuth.instance;
  final uid = auth.currentUser?.uid;

  if (uid == null) {
    const message = "User not logged in, cannot save data.";
    AppLogger.e("saveUserDataToFireStore: $message");
    return FireStoreResult(success: false, errorMessage: message);
  }

  final fireStore = FirebaseFirestore.instance;
  try {
    AppLogger.d(
        "Attempting to save user data for UID: $uid. Data: ${userData.toMap()}");
    await fireStore.collection('users').doc(uid).set(userData.toMap());
    AppLogger.i("User data successfully saved for UID: $uid");
    return FireStoreResult(success: true);
  } on FirebaseException catch (e) {
    AppLogger.e(
        "FirebaseException while saving user data for UID: $uid. Code: ${e.code}. Message: ${e.message}");
    return FireStoreResult(
        success: false,
        errorMessage: e.message ?? "A Firebase error occurred.",
        errorCode: e.code);
  } catch (e, s) {
    AppLogger.e(
        "Unexpected error while saving user data for UID: $uid. Error: $e. StackTrace: $s");
    return FireStoreResult(
        success: false,
        errorMessage: "An unexpected error occurred: ${e.toString()}");
  }
}

Future<void> updateRegistrationComplete({
  required String? uid,
  required bool registrationComplete,
}) async {
  try {
    if (uid == null) {
      AppLogger.e('No user is currently signed in.');
      return;
    }
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'registrationComplete': registrationComplete,
    });
  } catch (e) {
    AppLogger.e('Failed to update subscription: $e');
  }
}
