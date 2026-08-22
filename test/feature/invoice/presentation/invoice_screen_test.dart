import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:property/feature/invoice/data/model/invoice_page_model.dart';
import 'package:property/feature/invoice/data/repository/invoice_repository.dart';
import 'package:property/feature/invoice/presentation/provider/invoice_provider.dart';
import 'package:property/feature/invoice/presentation/screen/invoice_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders invoice summary and opens invoice details', (
    tester,
  ) async {
    await _setPhoneSize(tester);
    await tester.pumpWidget(_invoiceApp(_FakeInvoiceRepository()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('invoice-overview-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('invoice-card-8')), findsOneWidget);
    expect(find.byKey(const ValueKey('invoice-add-button')), findsOneWidget);
    expect(find.text('INV-008'), findsOneWidget);
    expect(find.text('Lake View 4B'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final details = find.byKey(const ValueKey('invoice-details-8'));
    await tester.scrollUntilVisible(
      details,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(details);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('invoice-details-sheet-8')),
      findsOneWidget,
    );
    expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    expect(find.text('Line items'), findsOneWidget);
    expect(find.text('Monthly rent'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pulling down refreshes invoices', (tester) async {
    await _setPhoneSize(tester);
    final repository = _FakeInvoiceRepository();
    await tester.pumpWidget(_invoiceApp(repository));
    await tester.pumpAndSettle();

    expect(repository.fetchCount, 1);
    await tester.drag(
      find.byKey(const ValueKey('invoice-scroll-view')),
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

Widget _invoiceApp(_FakeInvoiceRepository repository) => ScreenUtilInit(
  designSize: const Size(375, 812),
  minTextAdapt: true,
  builder: (context, _) => MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA855F7)),
    ),
    home: ChangeNotifierProvider(
      create: (_) => InvoiceProvider(repository),
      child: const InvoiceScreen(),
    ),
  ),
);

class _FakeInvoiceRepository implements InvoiceRepository {
  int fetchCount = 0;

  @override
  Future<InvoicePageModel> getInvoices() async {
    fetchCount += 1;
    return _page;
  }
}

final _page = InvoicePageModel.fromJson({
  'success': true,
  'message': 'OK',
  'data': [
    {
      'id': 8,
      'invoice_number': 'INV-008',
      'lease_id': 4,
      'period_start': '2026-07-01',
      'period_end': '2026-07-31',
      'issue_date': '2026-07-01',
      'due_date': '2026-07-05',
      'currency': 'BDT',
      'total_amount': '25000',
      'amount_paid': '10000',
      'balance_due': '15000',
      'status': 'partial',
      'notes': 'July rent',
      'items': [
        {
          'id': 1,
          'type': 'rent',
          'description': 'Monthly rent',
          'amount': '25000',
        },
      ],
      'payments': [
        {
          'id': 2,
          'amount': '10000',
          'currency': 'BDT',
          'paid_on': '2026-07-03',
          'method': 'bank',
          'reference': 'TX-1',
          'notes': '',
        },
      ],
      'lease': {
        'id': 4,
        'tenant': {'id': 12},
        'unit': {
          'id': 6,
          'name': 'Lake View 4B',
          'property': {'id': 3},
        },
      },
    },
  ],
  'meta': {'current_page': 1, 'per_page': 20, 'total': 1, 'last_page': 1},
});
