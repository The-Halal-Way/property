import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:property/config/router/app_router.dart';
import 'package:property/config/theme/theme_provider.dart';
import 'package:property/feature/settings/presentation/provider/settings_provider.dart';
import 'package:property/feature/settings/presentation/screen/settings_screen.dart';

void main() {
  testWidgets('renders compact account and services options', (tester) async {
    await _setPhoneSize(tester);
    await tester.pumpWidget(_app());

    expect(
      find.byKey(const ValueKey('settings-profile-option')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('settings-preferences-option')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('settings-password-option')),
      findsOneWidget,
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey('settings-profile-option')))
          .height,
      lessThan(70),
    );

    final deleteOption = find.byKey(
      const ValueKey('settings-delete-account-option'),
    );
    await tester.ensureVisible(deleteOption);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('settings-help-option')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('settings-privacy-option')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('settings-terms-option')), findsOneWidget);
    expect(deleteOption, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile option opens the linked profile route', (tester) async {
    await _setPhoneSize(tester);
    await tester.pumpWidget(_app());

    await tester.tap(find.byKey(const ValueKey('settings-profile-option')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('profile-route-placeholder')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _setPhoneSize(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(375, 812);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Widget _app() {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider.withSignOut(() async {}),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA855F7)),
        ),
        onGenerateRoute: (settings) {
          if (settings.name == AppRouteName.profileDetails) {
            return MaterialPageRoute<void>(
              builder: (_) =>
                  const Scaffold(key: ValueKey('profile-route-placeholder')),
            );
          }
          return null;
        },
        home: const Scaffold(
          body: SettingsScreen(
            initialName: 'Jb Jason',
            initialEmail: 'jb@example.com',
            initialAvatarUrl: '',
          ),
        ),
      ),
    ),
  );
}
