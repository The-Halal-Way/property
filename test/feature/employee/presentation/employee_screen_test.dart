import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:property/config/router/app_router.dart';
import 'package:property/feature/employee/data/model/employee_model.dart';
import 'package:property/feature/employee/data/model/employee_page_model.dart';
import 'package:property/feature/employee/data/model/employee_pagination_meta_model.dart';
import 'package:property/feature/employee/data/repository/employee_repository.dart';
import 'package:property/feature/employee/presentation/provider/employee_provider.dart';
import 'package:property/feature/employee/presentation/screen/employee_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmployeeScreen', () {
    testWidgets('renders team overview, compact card, and add affordance', (
      tester,
    ) async {
      await _setPhoneSize(tester);
      final repository = _FakeEmployeeRepository();
      await tester.pumpWidget(_employeeApp(repository));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('employee-overview-card')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('employee-card-8')), findsOneWidget);
      expect(find.byKey(const ValueKey('employee-add-button')), findsOneWidget);
      expect(find.text('Farhan Ahmed'), findsOneWidget);
      expect(find.text('Property Manager'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('employee-add-button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('add-employee-page')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows permissions in a draggable profile sheet', (
      tester,
    ) async {
      await _setPhoneSize(tester);
      await tester.pumpWidget(_employeeApp(_FakeEmployeeRepository()));
      await tester.pumpAndSettle();

      final detailsButton = find.byKey(const ValueKey('employee-details-8'));
      await tester.scrollUntilVisible(
        detailsButton,
        130,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(detailsButton);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('employee-details-sheet-8')),
        findsOneWidget,
      );
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      final sheet = find.byKey(const ValueKey('employee-details-sheet-8'));
      expect(
        find.descendant(of: sheet, matching: find.text('Permissions')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheet, matching: find.text('properties.view')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sheet,
          matching: find.text('Oversees the central portfolio'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('employee-details-close-8')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('employee-details-sheet-8')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('pulling down refreshes the employees endpoint', (
      tester,
    ) async {
      await _setPhoneSize(tester);
      final repository = _FakeEmployeeRepository();
      await tester.pumpWidget(_employeeApp(repository));
      await tester.pumpAndSettle();

      expect(repository.fetchCount, 1);
      await tester.drag(
        find.byKey(const ValueKey('employee-scroll-view')),
        const Offset(0, 340),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(repository.fetchCount, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps employee cards compact on a narrow phone', (
      tester,
    ) async {
      await _setPhoneSize(tester, size: const Size(320, 700));
      await tester.pumpWidget(_employeeApp(_FakeEmployeeRepository()));
      await tester.pumpAndSettle();

      final card = find.byKey(const ValueKey('employee-card-8'));
      expect(tester.getSize(card).height, lessThan(230));
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _setPhoneSize(
  WidgetTester tester, {
  Size size = const Size(375, 812),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Widget _employeeApp(_FakeEmployeeRepository repository) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA855F7)),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: ChangeNotifierProvider(
        create: (_) => EmployeeProvider(repository),
        child: const EmployeeScreen(),
      ),
    ),
  );
}

class _FakeEmployeeRepository implements EmployeeRepository {
  int fetchCount = 0;

  @override
  Future<EmployeePageModel> getEmployees() async {
    fetchCount += 1;
    return _page;
  }
}

const _page = EmployeePageModel(
  employees: [
    EmployeeModel(
      id: 8,
      name: 'Farhan Ahmed',
      email: 'farhan@example.com',
      phone: '+8801700000000',
      designation: 'Property Manager',
      loginEnabled: true,
      notes: 'Oversees the central portfolio',
      photoUrl: '',
      propertiesCount: 4,
      roles: 'Manager, Auditor',
      permissions: ['properties.view', 'leases.manage'],
    ),
  ],
  meta: EmployeePaginationMetaModel(
    currentPage: 1,
    perPage: 20,
    total: 1,
    lastPage: 1,
  ),
  message: 'OK',
);
