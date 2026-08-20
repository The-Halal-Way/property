import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:property/feature/dashboard/data/model/dashboard_data.dart';
import 'package:property/feature/dashboard/data/repository/dashboard_repository.dart';
import 'package:property/feature/dashboard/presentation/provider/dashboard_provider.dart';
import 'package:property/feature/dashboard/presentation/screen/dashboard_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DashboardScreen', () {
    testWidgets('shows every requested quick action without layout errors', (
      tester,
    ) async {
      await _setPhoneSize(tester);
      await tester.pumpWidget(_dashboardApp());
      await tester.pumpAndSettle();

      for (final label in const [
        'Properties',
        'Tenants',
        'Invoices',
        'Reports',
        'Employees',
        'Roles & Permissions',
      ]) {
        expect(
          find.byKey(ValueKey('dashboard-quick-action-$label')),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('forwards quick action selections to its callback', (
      tester,
    ) async {
      await _setPhoneSize(tester);
      String? selectedAction;
      await tester.pumpWidget(
        _dashboardApp(onQuickActionSelected: (value) => selectedAction = value),
      );
      await tester.pumpAndSettle();

      final propertiesAction = find.byKey(
        const ValueKey('dashboard-quick-action-Properties'),
      );
      await tester.scrollUntilVisible(
        propertiesAction,
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(propertiesAction);
      await tester.pump();

      expect(selectedAction, 'Properties');
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _setPhoneSize(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(375, 812);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Widget _dashboardApp({ValueChanged<String>? onQuickActionSelected}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider(
          create: (_) => DashboardProvider(_FakeDashboardRepository()),
          child: DashboardScreen(onQuickActionSelected: onQuickActionSelected),
        ),
      ),
    ),
  );
}

class _FakeDashboardRepository extends DashboardRepository {
  @override
  Future<DashboardData?> fetchDashboard(BuildContext context) async =>
      const DashboardData(
        stats: DashboardStats(
          properties: 12,
          units: 48,
          occupied: 40,
          vacant: 8,
          tenants: 37,
          activeLeases: 35,
        ),
        financials: DashboardFinancials(expected: 125000, collected: 100000),
      );
}
