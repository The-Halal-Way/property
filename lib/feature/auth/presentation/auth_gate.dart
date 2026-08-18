import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:property/feature/auth/data/auth_repository.dart';
import 'package:property/feature/auth/presentation/sign_in/sign_in_provider.dart';
import 'package:property/feature/auth/presentation/sign_in/sign_in_screen.dart';
import 'package:property/feature/home/presentation/home_screen.dart';

/// Root screen of the app (see [AppRouteName.authGate]).
///
/// Listens to [AuthRepository.authStateChanges] and shows [HomeScreen] when
/// a session is active or [AuthScreen] otherwise. Because Firebase persists
/// the session on-device by default, this alone gives "stay signed in until
/// sign-out" — no manual token storage needed.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();
    return StreamBuilder<User?>(
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) return const HomeScreen();

        // Provided here (rather than higher up) so a fresh SignInProvider,
        // with its own controllers, is created each time the gate falls
        // back to the sign-in screen — e.g. right after a sign-out.
        return ChangeNotifierProvider(
          create: (_) => SignInProvider(authRepository),
          child: const AuthScreen(),
        );
      },
    );
  }
}
