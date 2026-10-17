import 'package:property/core/model/google_auth_response.dart';

/// App-wide authentication state returned by the backend.
class GlobalService {
  GlobalService._();

  static final GlobalService instance = GlobalService._();

  GoogleAuthResponse? googleAuthResponse;

  /// Backend bearer token used by every authorized API request.
  String? token;

  /// Compatibility alias for older call sites that used the Firebase name.
  String? get idToken => token;

  set idToken(String? value) => token = value;

  void saveGoogleAuthResponse(GoogleAuthResponse response) {
    googleAuthResponse = response;
    token = response.data.token;
  }

  void clearAuth() {
    googleAuthResponse = null;
    token = null;
  }
}
