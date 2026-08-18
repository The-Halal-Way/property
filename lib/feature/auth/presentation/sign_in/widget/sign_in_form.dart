import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/core/util/my_dialog.dart';
import 'package:property/feature/auth/presentation/sign_in/sign_in_provider.dart';
import 'package:property/feature/auth/presentation/widget/auth_primary_button.dart';
import 'package:property/feature/auth/presentation/widget/auth_text_field.dart';

/// Email + password form for the sign-in screen.
class SignInForm extends StatelessWidget {
  const SignInForm({super.key, required this.provider});

  final SignInProvider provider;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: provider.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: provider.emailController,
            label: 'Email',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.mail_outline,
            validator: provider.validateEmail,
          ),
          SizedBox(height: 16.h),
          AuthTextField(
            controller: provider.passwordController,
            label: 'Password',
            hint: 'Enter your password',
            obscureText: provider.obscurePassword,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline,
            validator: provider.validatePassword,
            suffixIcon: IconButton(
              icon: Icon(
                provider.obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: provider.toggleObscurePassword,
            ),
          ),
          SizedBox(height: 24.h),
          AuthPrimaryButton(
            label: 'Sign In',
            isLoading: provider.isLoading,
            onPressed: () async {
              final error = await provider.signIn();
              if (!context.mounted) return;
              if (error != null) {
                MyDialog().showFailedToast(msg: error, context: context);
              } else {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }
}
