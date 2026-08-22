import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:property/feature/report/data/model/report_model.dart';
import 'package:property/feature/report/data/repository/report_repository.dart';
import 'package:property/feature/report/presentation/provider/report_provider.dart';
import 'package:property/feature/report/presentation/screen/report_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders collection overview and every aging bucket', (
    tester,
  ) async {
    await _setPhoneSize(tester);
    await tester.pumpWidget(_reportApp(_FakeReportRepository()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('report-overview-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('report-aging-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('report-health-card')), findsOneWidget);
    expect(find.text('Receivables aging'), findsOneWidget);
    expect(find.text('90+ days'), findsOneWidget);
    expect(find.text('BDT 100,000'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pulling down refreshes the report', (tester) async {
    await _setPhoneSize(tester);
    final repository = _FakeReportRepository();
    await tester.pumpWidget(_reportApp(repository));
    await tester.pumpAndSettle();

    expect(repository.fetchCount, 1);
    await tester.drag(
      find.byKey(const ValueKey('report-scroll-view')),
      const Offset(0, 340),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(repository.fetchCount, 2);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _setPhoneSize(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(375, 812);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Widget _reportApp(_FakeReportRepository repository) => ScreenUtilInit(
  designSize: const Size(375, 812),
  minTextAdapt: true,
  builder: (context, _) => MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA855F7)),
    ),
    home: ChangeNotifierProvider(
      create: (_) => ReportProvider(repository),
      child: const ReportScreen(),
    ),
  ),
);

class _FakeReportRepository implements ReportRepository {
  int fetchCount = 0;

  @override
  Future<ReportModel> getReport() async {
    fetchCount += 1;
    return _report;
  }
}

final _report = ReportModel.fromJson({
  'success': true,
  'message': 'OK',
  'data': {
    'currency': 'BDT',
    'collections': {
      'invoiced': 100000,
      'collected': 65000,
      'outstanding': 35000,
    },
    'aging': {
      'not_due': 10000,
      'd1_30': 8000,
      'd31_60': 7000,
      'd61_90': 5000,
      'd90_plus': 5000,
      'total': 35000,
    },
  },
});
