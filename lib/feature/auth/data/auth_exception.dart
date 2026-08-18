/// Friendly, presentation-ready error thrown by [AuthRepository].
///
/// The UI layer only ever needs to show [message]; it never has to know
/// about Firebase error codes.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Translates a Firebase Auth error code into a short, user-facing message.
String mapFirebaseAuthErrorCode(String code) {
  switch (code) {
    case 'invalid-email':
      return 'That email address looks invalid.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Incorrect email or password.';
    case 'email-already-in-use':
      return 'An account already exists with that email.';
    case 'weak-password':
      return 'Please choose a stronger password (min. 6 characters).';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    case 'network-request-failed':
      return 'Network error. Check your connection and try again.';
    default:
      return 'Something went wrong. Please try again.';
  }
}
