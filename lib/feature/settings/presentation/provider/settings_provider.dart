import 'package:flutter/foundation.dart';
import 'package:property/feature/auth/data/auth_repository.dart';
import 'package:property/feature/settings/data/model/profile_model.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(AuthRepository authRepository)
    : _signOut = authRepository.signOut;

  SettingsProvider.withSignOut(Future<void> Function() signOut)
    : _signOut = signOut;

  final Future<void> Function() _signOut;

  bool _isSigningOut = false;
  bool get isSigningOut => _isSigningOut;

  ProfileModel? _profile;
  ProfileModel? get profile => _profile;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDisposed = false;

  Future<void> signOut() async {
    if (_isSigningOut) return;

    _isSigningOut = true;
    _errorMessage = null;
    _notifyListeners();

    try {
      await _signOut();
    } catch (_) {
      _errorMessage = 'Could not sign out. Please try again.';
    } finally {
      _isSigningOut = false;
      _notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    _notifyListeners();
  }

  void applyProfile(ProfileModel profile) {
    _profile = profile;
    _notifyListeners();
  }

  void _notifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
