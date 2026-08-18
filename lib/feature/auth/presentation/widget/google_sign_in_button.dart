import 'package:flutter/material.dart';

/// "Continue with Google" button. Drawn with a plain "G" avatar instead of a
/// bundled logo asset, so no extra image dependency is needed.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: const CircleAvatar(
        radius: 10,
        backgroundColor: Colors.white,
        child: Text(
          'G',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF4285F4),
          ),
        ),
      ),
      label: const Text('Continue with Google'),
    );
  }
}
