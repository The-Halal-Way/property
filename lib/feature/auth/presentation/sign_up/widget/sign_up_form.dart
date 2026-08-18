import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/core/util/my_dialog.dart';
import 'package:property/feature/auth/presentation/sign_up/sign_up_provider.dart';
import 'package:property/feature/auth/presentation/widget/auth_primary_button.dart';
import 'package:property/feature/auth/presentation/widget/auth_text_field.dart';

/// Name + email + password + confirm-password form for the sign-up screen.
class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key, required this.provider});

  final SignUpProvider provider;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: provider.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: provider.nameController,
            label: 'Full name',
            hint: 'Your name',
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.person_outline,
            validator: provider.validateName,
          ),
          SizedBox(height: 16.h),
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
            hint: 'Create a password',
            obscureText: provider.obscurePassword,
            textInputAction: TextInputAction.next,
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
          SizedBox(height: 16.h),
          AuthTextField(
            controller: provider.confirmPasswordController,
            label: 'Confirm password',
            hint: 'Re-enter your password',
            obscureText: provider.obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline,
            validator: provider.validateConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                provider.obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: provider.toggleObscureConfirmPassword,
            ),
          ),
          SizedBox(height: 24.h),
          AuthPrimaryButton(
            label: 'Sign Up',
            isLoading: provider.isLoading,
            onPressed: () async {
              final error = await provider.signUp();
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
