import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:property/config/router/app_router.dart';
import 'package:property/core/util/my_dialog.dart';
import 'package:property/feature/auth/presentation/sign_up/sign_up_provider.dart';
import 'package:property/feature/auth/presentation/sign_up/widget/sign_up_form.dart';
import 'package:property/feature/auth/presentation/widget/auth_divider.dart';
import 'package:property/feature/auth/presentation/widget/auth_footer_link.dart';
import 'package:property/feature/auth/presentation/widget/auth_header.dart';
import 'package:property/feature/auth/presentation/widget/google_sign_in_button.dart';

/// Sign-up screen, pushed from [AuthScreen] via [AppRouteName.signUp].
///
/// Expects a [SignUpProvider] to already be available above it in the
/// widget tree (see [AppRouter]).
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Consumer<SignUpProvider>(
            builder: (context, provider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: 'Create account',
                    subtitle: 'Sign up to get started',
                  ),
                  SizedBox(height: 32.h),
                  SignUpForm(provider: provider),
                  SizedBox(height: 20.h),
                  const AuthDivider(),
                  SizedBox(height: 20.h),
                  GoogleSignInButton(
                    isLoading: provider.isLoading,
                    onPressed: () async {
                      final error = await provider.signUpWithGoogle();
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
                    question: 'Already have an account?',
                    actionLabel: 'Sign In',
                    onPressed: () {
                      final navigator = Navigator.of(context);
                      if (navigator.canPop()) {
                        navigator.pop();
                      } else {
                        navigator.pushReplacementNamed(AppRouteName.signIn);
                      }
                    },
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
