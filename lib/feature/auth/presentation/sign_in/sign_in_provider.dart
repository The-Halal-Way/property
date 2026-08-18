import 'package:flutter/material.dart';
import 'package:property/feature/auth/data/auth_exception.dart';
import 'package:property/feature/auth/data/auth_repository.dart';

/// UI state holder for [AuthScreen]: form controllers, validation, loading
/// state, and the calls into [AuthRepository].
///
/// Successful sign-in isn't handled here — [AuthGate] reacts to
/// [AuthRepository.authStateChanges] and swaps to the home screen on its
/// own, so this provider only needs to report success/failure back to the
/// screen for UI feedback (e.g. an error toast).
class SignInProvider extends ChangeNotifier {
  SignInProvider(this._authRepository);

  final AuthRepository _authRepository;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  /// Returns an error message on failure, or null on success/cancel.
  Future<String?> signIn() async {
    if (!formKey.currentState!.validate()) return null;
    _setLoading(true);
    try {
      await _authRepository.signInWithEmail(
        email: emailController.text,
        password: passwordController.text,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  /// Returns an error message on failure, or null on success/cancel.
  Future<String?> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _authRepository.signInWithGoogle();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
