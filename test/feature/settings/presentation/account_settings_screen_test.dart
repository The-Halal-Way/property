import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property/feature/settings/data/model/profile_model.dart';
import 'package:property/feature/settings/data/model/update_profile_request.dart';
import 'package:property/feature/settings/data/repository/profile_repository.dart';
import 'package:property/feature/settings/presentation/screen/account_settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows profile, preferences, and password sections', (
    tester,
  ) async {
    await _setPhoneSize(tester);
    await tester.pumpWidget(_app(_FakeProfileRepository()));

    expect(
      find.byKey(const ValueKey('account-profile-section')),
      findsOneWidget,
    );
    expect(
      tester.takeException(),
      isNull,
      reason: 'profile section overflowed',
    );
    await tester.tap(find.byKey(const ValueKey('account-tab-preferences')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('preference-currency-field')),
      findsOneWidget,
    );
    expect(
      tester.takeException(),
      isNull,
      reason: 'preferences section overflowed',
    );

    await tester.tap(find.byKey(const ValueKey('account-tab-password')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('new-password-field')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('confirm-password-field')),
      findsOneWidget,
    );
    expect(
      tester.takeException(),
      isNull,
      reason: 'password section overflowed',
    );
  });

  testWidgets('validates and submits the profile form', (tester) async {
    await _setPhoneSize(tester);
    final repository = _FakeProfileRepository();
    await tester.pumpWidget(_app(repository));

    final saveButton = find.byKey(const ValueKey('profile-save-button'));
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(repository.request?.name, 'Jb Jason');
    expect(repository.request?.email, 'jb@example.com');
    expect(repository.request?.countryCode, 'BD');
    expect(tester.takeException(), isNull);
  });
}

Future<void> _setPhoneSize(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(375, 812);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Widget _app(ProfileRepository repository) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA855F7)),
      ),
      home: AccountSettingsScreen(
        profileRepository: repository,
        initialName: 'Jb Jason',
        initialEmail: 'jb@example.com',
        initialPhone: '+880123456789',
        initialCountryCode: 'BD',
        initialTimezone: 'Asia/Dhaka',
        initialLocale: 'en-BD',
      ),
    ),
  );
}

class _FakeProfileRepository implements ProfileRepository {
  UpdateProfileRequest? request;

  @override
  Future<ProfileModel> updateProfile(UpdateProfileRequest request) async {
    this.request = request;
    return const ProfileModel(
      id: 7,
      name: 'Jb Jason',
      email: 'jb@example.com',
      phone: '+880123456789',
      avatarUrl: '',
      currency: 'BDT',
      currencyLocked: false,
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      locale: 'en-BD',
      hasPassword: true,
      emailVerified: true,
    );
  }
}
