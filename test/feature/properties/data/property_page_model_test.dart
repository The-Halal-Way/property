import 'package:flutter_test/flutter_test.dart';
import 'package:property/feature/properties/data/model/property_page_model.dart';

void main() {
  group('PropertyPageModel.fromJson', () {
    test('parses property, pagination, and nested unit data', () {
      final page = PropertyPageModel.fromJson({
        'success': true,
        'message': 'OK',
        'data': [
          {
            'id': 3,
            'name': 'Aurora Heights',
            'type': 'apartment_building',
            'employee_id': 12,
            'address_line1': '42 Lake Avenue',
            'address_line2': 'Gulshan 2',
            'city': 'Dhaka',
            'state': 'Dhaka',
            'postal_code': '1212',
            'country_code': 'BD',
            'currency': 'BDT',
            'current_value': '25000000',
            'purchase_price': '18000000',
            'notes': 'Premium residential tower',
            'units_count': 1,
            'employee': {'id': 12},
            'units': [
              {
                'id': 5,
                'property_id': 3,
                'name': 'Sky Suite 5A',
                'bedrooms': 3,
                'bathrooms': 2,
                'kitchens': 1,
                'parking_spaces': 1,
                'size': '1650',
                'size_unit': 'sq ft',
                'condition': 'excellent',
                'amenities': ['Balcony', null, 'Gym'],
                'default_rent_amount': '65000',
                'notes': 'Lake-facing unit',
                'occupied': true,
                'current_tenant': {'id': 7},
                'property': {'id': 3},
              },
            ],
          },
        ],
        'meta': {'current_page': 1, 'per_page': 20, 'total': 1, 'last_page': 1},
      });

      expect(page.message, 'OK');
      expect(page.meta.total, 1);
      expect(page.properties, hasLength(1));
      expect(page.properties.single.displayType, 'Apartment Building');
      expect(
        page.properties.single.fullAddress,
        '42 Lake Avenue, Gulshan 2, Dhaka, Dhaka, 1212, BD',
      );
      expect(page.properties.single.employeeId, 12);
      expect(page.properties.single.units.single.amenities, ['Balcony', 'Gym']);
      expect(page.properties.single.units.single.currentTenantId, 7);
      expect(page.totalUnits, 1);
      expect(page.occupiedUnits, 1);
      expect(page.vacantUnits, 0);
    });

    test('defaults optional leaves and nested collections safely', () {
      final page = PropertyPageModel.fromJson({
        'success': true,
        'data': [
          {'id': '9', 'name': null, 'units': null},
        ],
        'meta': <String, dynamic>{},
      });

      expect(page.properties.single.id, 9);
      expect(page.properties.single.displayName, 'Unnamed property');
      expect(page.properties.single.units, isEmpty);
      expect(page.meta.total, 0);
    });

    test('rejects a failed API envelope with its server message', () {
      expect(
        () => PropertyPageModel.fromJson({
          'success': false,
          'message': 'Not authorized',
          'data': <dynamic>[],
        }),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Not authorized',
          ),
        ),
      );
    });
  });
}
