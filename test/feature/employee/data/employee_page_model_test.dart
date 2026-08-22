import 'package:flutter_test/flutter_test.dart';
import 'package:property/feature/employee/data/model/employee_page_model.dart';

void main() {
  group('EmployeePageModel.fromJson', () {
    test('parses employees, access, roles, permissions, and pagination', () {
      final page = EmployeePageModel.fromJson({
        'success': true,
        'message': 'OK',
        'data': [
          {
            'id': 8,
            'name': 'Farhan Ahmed',
            'email': 'farhan@example.com',
            'phone': '+8801700000000',
            'designation': 'property_manager',
            'login_enabled': true,
            'notes': 'Oversees the central portfolio',
            'photo_url': 'https://example.com/farhan.jpg',
            'properties_count': '4',
            'roles': 'Manager, Auditor',
            'permissions': ['properties.view', null, 'leases.manage'],
          },
        ],
        'meta': {'current_page': 1, 'per_page': 20, 'total': 1, 'last_page': 1},
      });

      expect(page.message, 'OK');
      expect(page.meta.total, 1);
      expect(page.employees, hasLength(1));
      expect(page.employees.single.initials, 'FA');
      expect(page.employees.single.displayDesignation, 'Property Manager');
      expect(page.employees.single.roleLabels, ['Manager', 'Auditor']);
      expect(page.employees.single.permissions, [
        'properties.view',
        'leases.manage',
      ]);
      expect(page.loginEnabledCount, 1);
      expect(page.managedPropertiesCount, 4);
      expect(page.uniquePermissionsCount, 2);
    });

    test('defaults optional leaves and permissions safely', () {
      final page = EmployeePageModel.fromJson({
        'success': true,
        'data': [
          {'id': '9', 'name': null, 'permissions': null},
        ],
        'meta': <String, dynamic>{},
      });

      expect(page.employees.single.id, 9);
      expect(page.employees.single.displayName, 'Unnamed employee');
      expect(page.employees.single.permissions, isEmpty);
      expect(page.employees.single.loginEnabled, isFalse);
      expect(page.meta.total, 0);
    });

    test('rejects a failed API envelope with its server message', () {
      expect(
        () => EmployeePageModel.fromJson({
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
