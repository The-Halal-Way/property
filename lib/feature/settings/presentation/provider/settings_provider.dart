import 'package:flutter/foundation.dart';
import 'package:property/feature/auth/data/auth_repository.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._authRepository);

  final AuthRepository _authRepository;

  bool _isSigningOut = false;
  bool get isSigningOut => _isSigningOut;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDisposed = false;

  Future<void> signOut() async {
    if (_isSigningOut) return;

    _isSigningOut = true;
    _errorMessage = null;
    _notifyListeners();

    try {
      await _authRepository.signOut();
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

  void _notifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
