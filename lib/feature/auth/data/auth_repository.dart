import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:property/core/service/global_service.dart';
import 'package:property/feature/auth/data/auth_exception.dart';
import 'package:property/feature/auth/data/google_auth_remote_data_source.dart';

/// Data-layer gateway to Firebase Authentication.
///
/// Wraps [FirebaseAuth] and [GoogleSignIn] behind a small, presentation
/// friendly API, and keeps [GlobalService]'s backend session in sync.
///
/// There is no domain layer in this app, so this repository is the single
/// source of truth for auth state — the presentation layer talks to it
/// directly.
class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    GoogleAuthRemoteDataSource? googleAuthRemoteDataSource,
    Future<String> Function()? deviceNameProvider,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _googleAuthRemoteDataSource =
           googleAuthRemoteDataSource ?? DioGoogleAuthRemoteDataSource(),
       _deviceNameProvider = deviceNameProvider ?? _defaultDeviceName;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final GoogleAuthRemoteDataSource _googleAuthRemoteDataSource;
  final Future<String> Function() _deviceNameProvider;
  bool _googleSignInInitialized = false;

  /// Keeps signed-out state and the in-memory backend session aligned.
  Stream<User?> get authStateChanges async* {
    await for (final user in _firebaseAuth.idTokenChanges()) {
      if (user == null) {
        GlobalService.instance.clearAuth();
      } else {
        // Email authentication still uses its Firebase token until its backend
        // exchange endpoint is available. A completed Google flow already has
        // a backend token here, so it is never overwritten by this fallback.
        GlobalService.instance.token ??= await user.getIdToken();
      }
      yield user;
    }
  }

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    // This is the Web OAuth client (client_type 3), not the Android client.
    // Backend ID-token verification must use this same client ID as audience.
    await _googleSignIn.initialize(serverClientId: _googleServerClientId);
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

  /// Exchanges the Google ID token with the backend, then creates/restores the
  /// Firebase session used by [AuthGate].
  ///
  /// Returns null if the user cancels the Google account picker.
  Future<User?> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();
      final account = await _googleSignIn.authenticate();
      final googleIdToken = account.authentication.idToken;
      if (googleIdToken == null) {
        throw const AuthException('Google sign-in failed. Please try again.');
      }
      _logGoogleIdTokenClaims(googleIdToken);

      final authResponse = await _googleAuthRemoteDataSource.signIn(
        googleIdToken: googleIdToken,
        deviceName: await _deviceNameProvider(),
      );
      GlobalService.instance.saveGoogleAuthResponse(authResponse);

      try {
        final credential = GoogleAuthProvider.credential(
          idToken: googleIdToken,
        );
        final userCredential = await _firebaseAuth.signInWithCredential(
          credential,
        );
        if (kDebugMode) {
          debugPrint(
            '[GoogleAuth] Backend and Firebase sign-in completed for '
            '${userCredential.user?.email ?? account.email}',
          );
        }
        return userCredential.user;
      } catch (_) {
        GlobalService.instance.clearAuth();
        try {
          await _firebaseAuth.signOut();
        } catch (_) {
          // Preserve the original sign-in error if rollback also fails.
        }
        rethrow;
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw const AuthException('Google sign-in failed. Please try again.');
    } on GoogleAuthApiException catch (e) {
      throw AuthException(e.message);
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthErrorCode(e.code));
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    try {
      if (_googleSignInInitialized) {
        await _googleSignIn.signOut();
      }
    } finally {
      GlobalService.instance.clearAuth();
    }
  }
}

const String _googleServerClientId =
    '1004868151524-kgjf4gjvnl53e7on1lou2b3gonfu1cb6.apps.googleusercontent.com';

void _logGoogleIdTokenClaims(String idToken) {
  if (!kDebugMode) return;

  try {
    final segments = idToken.split('.');
    if (segments.length != 3) {
      debugPrint('[GoogleAuth] Google ID token is not a JWT.');
      return;
    }

    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(segments[1]))),
    );
    if (payload is! Map) {
      debugPrint('[GoogleAuth] Google ID token payload is invalid.');
      return;
    }

    final claims = payload.map((key, value) => MapEntry(key.toString(), value));
    final expiresAtSeconds = switch (claims['exp']) {
      final num value => value.toInt(),
      final Object value => int.tryParse(value.toString()),
      null => null,
    };
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expiresInSeconds = expiresAtSeconds == null
        ? null
        : expiresAtSeconds - nowSeconds;

    debugPrint(
      '[GoogleAuth] Google ID token claims: '
      'aud=${claims['aud']}, '
      'azp=${claims['azp']}, '
      'iss=${claims['iss']}, '
      'expiresIn=${expiresInSeconds}s',
    );
  } catch (error) {
    debugPrint('[GoogleAuth] Could not decode Google ID token claims: $error');
  }
}

Future<String> _defaultDeviceName() async {
  if (kIsWeb) return 'Web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'Android',
    TargetPlatform.iOS => 'iOS',
    TargetPlatform.macOS => 'macOS',
    TargetPlatform.windows => 'Windows',
    TargetPlatform.linux => 'Linux',
    TargetPlatform.fuchsia => 'Fuchsia',
  };
}
