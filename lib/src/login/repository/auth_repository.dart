import 'package:firebase_auth/firebase_auth.dart';

/// Thin data-access wrapper around [FirebaseAuth] for the auth flows (login,
/// signup, verification, password reset) and sign-out. Each method is a direct
/// pass-through — no added logic — so behaviour is identical to calling
/// `FirebaseAuth.instance` inline, but the screens no longer depend on the SDK
/// singleton directly.
class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  /// Sends the verification email to [user] (or the current user when omitted),
  /// optionally with [actionCodeSettings].
  Future<void> sendEmailVerification({
    User? user,
    ActionCodeSettings? actionCodeSettings,
  }) async {
    final target = user ?? _auth.currentUser;
    if (target != null) {
      await target.sendEmailVerification(actionCodeSettings);
    }
  }

  Future<void> sendPasswordResetEmail(
    String email, {
    ActionCodeSettings? actionCodeSettings,
  }) =>
      _auth.sendPasswordResetEmail(
          email: email, actionCodeSettings: actionCodeSettings);

  Future<void> reloadCurrentUser() async => _auth.currentUser?.reload();

  Future<void> signOut() => _auth.signOut();
}
