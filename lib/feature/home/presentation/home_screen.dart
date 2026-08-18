import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:property/feature/auth/data/auth_repository.dart';

/// Placeholder landing screen shown by [AuthGate] once signed in.
///
/// This is just enough to prove the auth flow end-to-end and offer a
/// sign-out entry point; the real home feature is built separately.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();
    final user = authRepository.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user?.displayName != null
                  ? 'Welcome, ${user!.displayName}!'
                  : 'Welcome!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8.h),
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 24.h),
            OutlinedButton(
              onPressed: authRepository.signOut,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
