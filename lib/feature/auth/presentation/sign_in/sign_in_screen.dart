import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:property/config/router/app_router.dart';
import 'package:property/core/util/my_dialog.dart';
import 'package:property/feature/auth/presentation/sign_in/sign_in_provider.dart';
import 'package:property/feature/auth/presentation/sign_in/widget/sign_in_form.dart';
import 'package:property/feature/auth/presentation/widget/auth_divider.dart';
import 'package:property/feature/auth/presentation/widget/auth_footer_link.dart';
import 'package:property/feature/auth/presentation/widget/auth_header.dart';
import 'package:property/feature/auth/presentation/widget/google_sign_in_button.dart';

/// Sign-in screen shown by [AuthGate] when there's no active session.
///
/// Expects a [SignInProvider] to already be available above it in the
/// widget tree (see [AppRouter]).
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Consumer<SignInProvider>(
            builder: (context, provider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: 'Welcome back',
                    subtitle: 'Sign in to continue',
                  ),
                  SizedBox(height: 32.h),
                  SignInForm(provider: provider),
                  SizedBox(height: 20.h),
                  const AuthDivider(),
                  SizedBox(height: 20.h),
                  GoogleSignInButton(
                    isLoading: provider.isLoading,
                    onPressed: () async {
                      final error = await provider.signInWithGoogle();
                      if (!context.mounted) return;
                      if (error != null) {
                        MyDialog().showFailedToast(
                          msg: error,
                          context: context,
                        );
                      } else {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      }
                    },
                  ),
                  SizedBox(height: 24.h),
                  AuthFooterLink(
                    question: "Don't have an account?",
                    actionLabel: 'Sign Up',
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed(AppRouteName.signUp),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
