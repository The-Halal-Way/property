import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:property/feature/auth/data/auth_repository.dart';
import 'package:property/feature/auth/presentation/auth_gate.dart';
import 'package:property/feature/auth/presentation/sign_in/sign_in_provider.dart';
import 'package:property/feature/auth/presentation/sign_in/sign_in_screen.dart';
import 'package:property/feature/auth/presentation/sign_up/sign_up_provider.dart';
import 'package:property/feature/auth/presentation/sign_up/sign_up_screen.dart';

class AppRouteName {
  static const String authGate = '/';
  static const String signIn = '/auth/sign-in';
  static const String signUp = '/auth/sign-up';
  static const String settings = '/settings';
  static const String profileDetails = '/settings/profile-details';
  static const String home = '/home';
  static const String club = '/home/club';
  static const String locker = '/home/locker';
  static const String kurbani = '/home/kurbani';
  static const String tourCostManage = '/home/tour-cost-manage';
  static const String tourManage = '/home/tour-cost-manage/session';
  static const String tourSummary = '/home/tour-cost-manage/summary';
  static const String packCheck = '/home/carry-check';
}

abstract class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouteName.signIn:
        return _materialRoute(
          settings: settings,
          child: ChangeNotifierProvider(
            create: (context) => SignInProvider(context.read<AuthRepository>()),
            child: const AuthScreen(),
          ),
        );

      case AppRouteName.signUp:
        return _materialRoute(
          settings: settings,
          child: ChangeNotifierProvider(
            create: (context) => SignUpProvider(context.read<AuthRepository>()),
            child: const SignUpScreen(),
          ),
        );

      case AppRouteName.authGate:
      default:
        return _materialRoute(settings: settings, child: const AuthGate());
    }
  }

  static MaterialPageRoute<dynamic> _materialRoute({
    required RouteSettings settings,
    required Widget child,
  }) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => child,
    );
  }
}
