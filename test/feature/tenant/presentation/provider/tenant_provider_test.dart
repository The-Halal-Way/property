import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:property/feature/tenant/data/model/pagination_meta_model.dart';
import 'package:property/feature/tenant/data/model/tenant_model.dart';
import 'package:property/feature/tenant/data/model/tenant_page_model.dart';
import 'package:property/feature/tenant/data/repository/tenant_repository.dart';
import 'package:property/feature/tenant/presentation/provider/tenant_provider.dart';

void main() {
  group('TenantProvider', () {
    test('loads tenants and exposes the initial loading state', () async {
      final completer = Completer<TenantPageModel>();
      final repository = _FakeTenantRepository((_) => completer.future);
      final provider = TenantProvider(repository);
      addTearDown(provider.dispose);

      final request = provider.load();

      expect(provider.isInitialLoading, isTrue);
      expect(provider.isRefreshing, isFalse);
      expect(provider.errorMessage, isNull);

      completer.complete(_tenantPage);
      await request;

      expect(provider.page, same(_tenantPage));
      expect(provider.isInitialLoading, isFalse);
      expect(provider.isRefreshing, isFalse);
      expect(repository.fetchCount, 1);
    });

    test('retains the last tenant page if refresh fails', () async {
      final repository = _FakeTenantRepository((call) async {
        if (call == 1) return _tenantPage;
        throw StateError('Refresh unavailable');
      });
      final provider = TenantProvider(repository);
      addTearDown(provider.dispose);

      await provider.load();
      await provider.refresh();

      expect(provider.page, same(_tenantPage));
      expect(provider.errorMessage, 'Refresh unavailable');
      expect(provider.isRefreshing, isFalse);
      expect(repository.fetchCount, 2);
    });

    test('coalesces simultaneous refresh requests', () async {
      final completer = Completer<TenantPageModel>();
      final repository = _FakeTenantRepository((_) => completer.future);
      final provider = TenantProvider(repository);
      addTearDown(provider.dispose);

      final first = provider.load();
      final second = provider.refresh();
      completer.complete(_tenantPage);
      await Future.wait([first, second]);

      expect(repository.fetchCount, 1);
    });
  });
}

class _FakeTenantRepository implements TenantRepository {
  _FakeTenantRepository(this._fetch);

  final Future<TenantPageModel> Function(int call) _fetch;
  int fetchCount = 0;

  @override
  Future<TenantPageModel> getTenants() {
    fetchCount += 1;
    return _fetch(fetchCount);
  }
}

const _tenantPage = TenantPageModel(
  tenants: [
    TenantModel(
      id: 1,
      name: 'Nadia Islam',
      phone: '01700000000',
      email: 'nadia@example.com',
      idDocumentType: 'NID',
      idDocumentNumber: '1001',
      addressLine1: 'Dhanmondi',
      addressLine2: '',
      city: 'Dhaka',
      state: '',
      postalCode: '',
      countryCode: 'BD',
      emergencyContactName: '',
      emergencyContactPhone: '',
      emergencyContactRelation: '',
      familyMembersCount: 2,
      guardianName: '',
      guardianPhone: '',
      notes: '',
      activeLeasesCount: 0,
      leases: [],
    ),
  ],
  meta: PaginationMetaModel(currentPage: 1, perPage: 20, total: 1, lastPage: 1),
  message: 'OK',
);
