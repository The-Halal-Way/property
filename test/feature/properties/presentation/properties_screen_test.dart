import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:property/feature/properties/data/model/property_model.dart';
import 'package:property/feature/properties/data/model/property_page_model.dart';
import 'package:property/feature/properties/data/model/property_pagination_meta_model.dart';
import 'package:property/feature/properties/data/model/property_unit_model.dart';
import 'package:property/feature/properties/data/repository/property_repository.dart';
import 'package:property/feature/properties/presentation/provider/property_provider.dart';
import 'package:property/feature/properties/presentation/screen/properties_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PropertiesScreen', () {
    testWidgets('renders property overview, card, and add affordance', (
      tester,
    ) async {
      await _setPhoneSize(tester);
      final repository = _FakePropertyRepository();
      await tester.pumpWidget(_propertyApp(repository));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('property-overview-card')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('property-card-3')), findsOneWidget);
      expect(find.byKey(const ValueKey('property-add-button')), findsOneWidget);
      expect(find.text('Aurora Heights'), findsOneWidget);
      expect(find.text('BDT 25000000'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows units in a dismissible draggable modal sheet', (
      tester,
    ) async {
      await _setPhoneSize(tester);
      await tester.pumpWidget(_propertyApp(_FakePropertyRepository()));
      await tester.pumpAndSettle();

      final detailsButton = find.byKey(const ValueKey('property-details-3'));
      await tester.scrollUntilVisible(
        detailsButton,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(detailsButton);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('property-units-sheet-3')),
        findsOneWidget,
      );
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.text('Unit directory'), findsOneWidget);
      expect(find.text('Sky Suite 5A'), findsOneWidget);
      expect(find.text('BDT 65000'), findsOneWidget);
      expect(find.text('Balcony'), findsOneWidget);

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('property-units-sheet-3')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('pulling down refreshes the properties endpoint', (
      tester,
    ) async {
      await _setPhoneSize(tester);
      final repository = _FakePropertyRepository();
      await tester.pumpWidget(_propertyApp(repository));
      await tester.pumpAndSettle();

      expect(repository.fetchCount, 1);
      await tester.drag(
        find.byKey(const ValueKey('property-scroll-view')),
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

Widget _propertyApp(_FakePropertyRepository repository) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA855F7)),
      ),
      home: ChangeNotifierProvider(
        create: (_) => PropertyProvider(repository),
        child: const PropertiesScreen(),
      ),
    ),
  );
}

class _FakePropertyRepository implements PropertyRepository {
  int fetchCount = 0;

  @override
  Future<PropertyPageModel> getProperties() async {
    fetchCount += 1;
    return _page;
  }
}

final _page = PropertyPageModel(
  properties: [
    PropertyModel(
      id: 3,
      name: 'Aurora Heights',
      type: 'apartment_building',
      employeeId: 12,
      addressLine1: '42 Lake Avenue',
      addressLine2: 'Gulshan 2',
      city: 'Dhaka',
      state: 'Dhaka',
      postalCode: '1212',
      countryCode: 'BD',
      currency: 'BDT',
      currentValue: '25000000',
      purchasePrice: '18000000',
      notes: 'Premium residential tower',
      unitsCount: 1,
      units: [
        const PropertyUnitModel(
          id: 5,
          propertyId: 3,
          name: 'Sky Suite 5A',
          bedrooms: 3,
          bathrooms: 2,
          kitchens: 1,
          parkingSpaces: 1,
          size: '1650',
          sizeUnit: 'sq ft',
          condition: 'excellent',
          amenities: ['Balcony', 'Gym'],
          defaultRentAmount: '65000',
          notes: 'Lake-facing unit',
          occupied: true,
          currentTenantId: 7,
        ),
      ],
    ),
  ],
  meta: const PropertyPaginationMetaModel(
    currentPage: 1,
    perPage: 20,
    total: 1,
    lastPage: 1,
  ),
  message: 'OK',
);
