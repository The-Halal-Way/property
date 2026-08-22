import 'package:flutter_test/flutter_test.dart';
import 'package:property/feature/tenant/data/model/tenant_page_model.dart';

void main() {
  group('TenantPageModel.fromJson', () {
    test('parses tenant, pagination, address, and nested lease data', () {
      final page = TenantPageModel.fromJson({
        'success': true,
        'message': 'OK',
        'data': [
          {
            'id': 7,
            'name': 'Ayesha Rahman',
            'phone': '+8801700000000',
            'email': 'ayesha@example.com',
            'id_document_type': 'NID',
            'id_document_number': '123456',
            'address_line1': '12 Lake Road',
            'address_line2': 'Flat 4B',
            'city': 'Dhaka',
            'state': 'Dhaka',
            'postal_code': '1205',
            'country_code': 'BD',
            'emergency_contact_name': 'Karim Rahman',
            'emergency_contact_phone': '+8801800000000',
            'emergency_contact_relation': 'Brother',
            'family_members_count': '3',
            'guardian_name': '',
            'guardian_phone': '',
            'notes': 'Long-term resident',
            'active_leases_count': 1,
            'leases': [
              {
                'id': 31,
                'unit_id': 11,
                'tenant_id': 7,
                'rent_amount': '25000.00',
                'currency': 'BDT',
                'billing_frequency': 'monthly',
                'start_date': '2026-01-01',
                'end_date': '2026-12-31',
                'due_day': 5,
                'deposit_amount': '50000.00',
                'status': 'active',
                'notes': '',
                'unit': {
                  'id': 11,
                  'name': 'Lake View 4B',
                  'property': {'id': 3},
                },
                'tenant': {'id': 7},
              },
            ],
          },
        ],
        'meta': {'current_page': 1, 'per_page': 20, 'total': 1, 'last_page': 1},
      });

      expect(page.message, 'OK');
      expect(page.meta.total, 1);
      expect(page.tenants, hasLength(1));
      expect(page.tenants.single.initials, 'AR');
      expect(
        page.tenants.single.fullAddress,
        '12 Lake Road, Flat 4B, Dhaka, Dhaka, 1205, BD',
      );
      expect(page.tenants.single.familyMembersCount, 3);
      expect(page.tenants.single.leases.single.unitName, 'Lake View 4B');
      expect(page.tenants.single.leases.single.propertyId, 3);
      expect(page.tenants.single.leases.single.startDate, DateTime(2026));
      expect(page.activeTenantCount, 1);
      expect(page.activeLeaseCount, 1);
      expect(page.propertyCount, 1);
    });

    test('defaults optional leaves and nested collections safely', () {
      final page = TenantPageModel.fromJson({
        'success': true,
        'data': [
          {'id': '9', 'name': null, 'leases': null},
        ],
        'meta': <String, dynamic>{},
      });

      expect(page.tenants.single.id, 9);
      expect(page.tenants.single.displayName, 'Unnamed tenant');
      expect(page.tenants.single.leases, isEmpty);
      expect(page.meta.total, 0);
    });

    test('rejects a failed API envelope with its server message', () {
      expect(
        () => TenantPageModel.fromJson({
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
