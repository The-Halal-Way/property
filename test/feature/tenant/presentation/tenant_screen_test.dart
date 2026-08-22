import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:property/feature/tenant/data/model/pagination_meta_model.dart';
import 'package:property/feature/tenant/data/model/tenant_lease_model.dart';
import 'package:property/feature/tenant/data/model/tenant_model.dart';
import 'package:property/feature/tenant/data/model/tenant_page_model.dart';
import 'package:property/feature/tenant/data/repository/tenant_repository.dart';
import 'package:property/feature/tenant/presentation/provider/tenant_provider.dart';
import 'package:property/feature/tenant/presentation/screen/tenant_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TenantScreen', () {
    testWidgets('renders tenant overview, profile, and add affordance', (
      tester,
    ) async {
      await _setPhoneSize(tester);
      final repository = _FakeTenantRepository();
      await tester.pumpWidget(_tenantApp(repository));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('tenant-overview-card')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('tenant-card-7')), findsOneWidget);
      expect(find.byKey(const ValueKey('tenant-add-button')), findsOneWidget);
      expect(find.text('Ayesha Rahman'), findsOneWidget);
      expect(find.text('+8801700000000'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows lease details in a draggable modal sheet', (
      tester,
    ) async {
      await _setPhoneSize(tester);
      await tester.pumpWidget(_tenantApp(_FakeTenantRepository()));
      await tester.pumpAndSettle();

      final detailsButton = find.byKey(const ValueKey('tenant-details-7'));
      await tester.scrollUntilVisible(
        detailsButton,
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(detailsButton);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('tenant-details-sheet-7')),
        findsOneWidget,
      );
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.text('Lease timeline'), findsOneWidget);
      expect(find.text('Lake View 4B'), findsOneWidget);
      expect(find.text('BDT 25000'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('tenant-details-close-7')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('tenant-details-sheet-7')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('pulling down refreshes the tenant endpoint', (tester) async {
      await _setPhoneSize(tester);
      final repository = _FakeTenantRepository();
      await tester.pumpWidget(_tenantApp(repository));
      await tester.pumpAndSettle();

      expect(repository.fetchCount, 1);
      await tester.drag(
        find.byKey(const ValueKey('tenant-scroll-view')),
        const Offset(0, 340),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(repository.fetchCount, 2);
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

Widget _tenantApp(_FakeTenantRepository repository) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA855F7)),
      ),
      home: ChangeNotifierProvider(
        create: (_) => TenantProvider(repository),
        child: const TenantScreen(),
      ),
    ),
  );
}

class _FakeTenantRepository implements TenantRepository {
  int fetchCount = 0;

  @override
  Future<TenantPageModel> getTenants() async {
    fetchCount += 1;
    return _page;
  }
}

final _page = TenantPageModel(
  tenants: [
    TenantModel(
      id: 7,
      name: 'Ayesha Rahman',
      phone: '+8801700000000',
      email: 'ayesha@example.com',
      idDocumentType: 'NID',
      idDocumentNumber: '123456',
      addressLine1: '12 Lake Road',
      addressLine2: 'Flat 4B',
      city: 'Dhaka',
      state: 'Dhaka',
      postalCode: '1205',
      countryCode: 'BD',
      emergencyContactName: 'Karim Rahman',
      emergencyContactPhone: '+8801800000000',
      emergencyContactRelation: 'Brother',
      familyMembersCount: 3,
      guardianName: '',
      guardianPhone: '',
      notes: 'Long-term resident',
      activeLeasesCount: 1,
      leases: [
        TenantLeaseModel(
          id: 31,
          unitId: 11,
          tenantId: 7,
          rentAmount: '25000',
          currency: 'BDT',
          billingFrequency: 'monthly',
          startDate: DateTime(2026),
          endDate: DateTime(2026, 12, 31),
          dueDay: 5,
          depositAmount: '50000',
          status: 'active',
          notes: '',
          unitName: 'Lake View 4B',
          propertyId: 3,
        ),
      ],
    ),
  ],
  meta: const PaginationMetaModel(
    currentPage: 1,
    perPage: 20,
    total: 1,
    lastPage: 1,
  ),
  message: 'OK',
);
