import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:property/feature/employee/data/model/employee_model.dart';
import 'package:property/feature/employee/data/model/employee_page_model.dart';
import 'package:property/feature/employee/data/model/employee_pagination_meta_model.dart';
import 'package:property/feature/employee/data/repository/employee_repository.dart';
import 'package:property/feature/employee/presentation/provider/employee_provider.dart';

void main() {
  group('EmployeeProvider', () {
    test('loads employees and exposes the initial loading state', () async {
      final completer = Completer<EmployeePageModel>();
      final repository = _FakeEmployeeRepository((_) => completer.future);
      final provider = EmployeeProvider(repository);
      addTearDown(provider.dispose);

      final request = provider.load();

      expect(provider.isInitialLoading, isTrue);
      expect(provider.isRefreshing, isFalse);
      expect(provider.errorMessage, isNull);

      completer.complete(_employeePage);
      await request;

      expect(provider.page, same(_employeePage));
      expect(provider.isInitialLoading, isFalse);
      expect(provider.isRefreshing, isFalse);
      expect(repository.fetchCount, 1);
    });

    test('retains the last employee page if refresh fails', () async {
      final repository = _FakeEmployeeRepository((call) async {
        if (call == 1) return _employeePage;
        throw StateError('Refresh unavailable');
      });
      final provider = EmployeeProvider(repository);
      addTearDown(provider.dispose);

      await provider.load();
      await provider.refresh();

      expect(provider.page, same(_employeePage));
      expect(provider.errorMessage, 'Refresh unavailable');
      expect(provider.isRefreshing, isFalse);
      expect(repository.fetchCount, 2);
    });

    test('coalesces simultaneous refresh requests', () async {
      final completer = Completer<EmployeePageModel>();
      final repository = _FakeEmployeeRepository((_) => completer.future);
      final provider = EmployeeProvider(repository);
      addTearDown(provider.dispose);

      final first = provider.load();
      final second = provider.refresh();
      completer.complete(_employeePage);
      await Future.wait([first, second]);

      expect(repository.fetchCount, 1);
    });
  });
}

class _FakeEmployeeRepository implements EmployeeRepository {
  _FakeEmployeeRepository(this._fetch);

  final Future<EmployeePageModel> Function(int call) _fetch;
  int fetchCount = 0;

  @override
  Future<EmployeePageModel> getEmployees() {
    fetchCount += 1;
    return _fetch(fetchCount);
  }
}

const _employeePage = EmployeePageModel(
  employees: [
    EmployeeModel(
      id: 8,
      name: 'Farhan Ahmed',
      email: 'farhan@example.com',
      phone: '01700000000',
      designation: 'Property Manager',
      loginEnabled: true,
      notes: '',
      photoUrl: '',
      propertiesCount: 4,
      roles: 'Manager',
      permissions: ['properties.view'],
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
