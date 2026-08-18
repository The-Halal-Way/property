import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:property/core/service/global_service.dart';
import 'package:property/feature/auth/data/auth_exception.dart';

/// Data-layer gateway to Firebase Authentication.
///
/// Wraps [FirebaseAuth] and [GoogleSignIn] behind a small, presentation
/// friendly API, and keeps [GlobalService]'s cached ID token in sync with
/// the current session so [BaseClient] can attach it to API calls.
///
/// There is no domain layer in this app, so this repository is the single
/// source of truth for auth state — the presentation layer talks to it
/// directly.
class AuthRepository {
  AuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance {
    // Keep the cached ID token fresh for every sign-in/sign-out, including
    // the automatic sign-in Firebase performs on app start from its own
    // on-device session persistence.
    _firebaseAuth.authStateChanges().listen(_syncIdToken);
  }

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  bool _googleSignInInitialized = false;

  /// Emits whenever the signed-in user changes (including on app start,
  /// restoring whatever session Firebase persisted on-device). Drives
  /// [AuthGate] and gives "stay signed in until sign-out" for free.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> _syncIdToken(User? user) async {
    GlobalService.instance.idToken = await user?.getIdToken();
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    // On Android/iOS this reads client IDs from google-services.json /
    // GoogleService-Info.plist automatically once Firebase is connected.
    await _googleSignIn.initialize();
    _googleSignInInitialized = true;
  }

  /// Signs in an existing user with email + password.
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthErrorCode(e.code));
    }
  }

  /// Creates a new account with email + password, and sets the display name.
  Future<User?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthErrorCode(e.code));
    }
  }

  /// Signs in with Google, creating the Firebase account on first use.
  ///
  /// Returns null if the user cancels the Google account picker.
  Future<User?> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthException('Google sign-in failed. Please try again.');
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw const AuthException('Google sign-in failed. Please try again.');
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthErrorCode(e.code));
    }
  }

  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }
}
