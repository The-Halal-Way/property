import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property/feature/employee/presentation/screen/add_employee_screen.dart';
import 'package:property/feature/properties/presentation/screen/add_property_screen.dart';
import 'package:property/feature/tenant/presentation/screen/add_tenant_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Add entity screens', () {
    testWidgets('property form renders dynamic fields and an inert submit', (
      tester,
    ) async {
      await _setSize(tester, const Size(375, 812));
      await tester.pumpWidget(_app(const AddPropertyScreen()));

      expect(find.byKey(const ValueKey('add-property-page')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('form-field-property-name')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('form-field-current-value')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('add-property-submit-button')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('tenant form includes contact, address, and household fields', (
      tester,
    ) async {
      await _setSize(tester, const Size(375, 812));
      await tester.pumpWidget(_app(const AddTenantScreen()));

      expect(find.byKey(const ValueKey('add-tenant-page')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('form-field-full-name')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('form-field-emergency-contact-name')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('form-field-household-size')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('employee login fields are revealed dynamically', (
      tester,
    ) async {
      await _setSize(tester, const Size(375, 812));
      await tester.pumpWidget(_app(const AddEmployeeScreen()));

      expect(find.byKey(const ValueKey('form-field-email')), findsNothing);

      final loginSwitch = find.byKey(
        const ValueKey('employee-login-access-switch'),
      );
      tester.widget<Switch>(loginSwitch).onChanged?.call(true);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('form-field-email')), findsOneWidget);
      expect(find.byKey(const ValueKey('form-field-password')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dynamic grid uses two columns when width allows', (
      tester,
    ) async {
      await _setSize(tester, const Size(900, 1000));
      await tester.pumpWidget(_app(const AddPropertyScreen()));

      final name = find.byKey(const ValueKey('form-field-property-name'));
      final type = find.byKey(const ValueKey('form-field-property-type'));
      expect(tester.getTopLeft(name).dy, tester.getTopLeft(type).dy);
      expect(
        tester.getTopLeft(type).dx,
        greaterThan(tester.getTopLeft(name).dx),
      );
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Widget _app(Widget home) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA855F7)),
      ),
      home: home,
    ),
  );
}
