import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:property/feature/properties/data/model/property_model.dart';
import 'package:property/feature/properties/data/model/property_page_model.dart';
import 'package:property/feature/properties/data/model/property_pagination_meta_model.dart';
import 'package:property/feature/properties/data/repository/property_repository.dart';
import 'package:property/feature/properties/presentation/provider/property_provider.dart';

void main() {
  group('PropertyProvider', () {
    test('loads properties and exposes the initial loading state', () async {
      final completer = Completer<PropertyPageModel>();
      final repository = _FakePropertyRepository((_) => completer.future);
      final provider = PropertyProvider(repository);
      addTearDown(provider.dispose);

      final request = provider.load();

      expect(provider.isInitialLoading, isTrue);
      expect(provider.isRefreshing, isFalse);
      expect(provider.errorMessage, isNull);

      completer.complete(_propertyPage);
      await request;

      expect(provider.page, same(_propertyPage));
      expect(provider.isInitialLoading, isFalse);
      expect(provider.isRefreshing, isFalse);
      expect(repository.fetchCount, 1);
    });

    test('retains the last property page if refresh fails', () async {
      final repository = _FakePropertyRepository((call) async {
        if (call == 1) return _propertyPage;
        throw StateError('Refresh unavailable');
      });
      final provider = PropertyProvider(repository);
      addTearDown(provider.dispose);

      await provider.load();
      await provider.refresh();

      expect(provider.page, same(_propertyPage));
      expect(provider.errorMessage, 'Refresh unavailable');
      expect(provider.isRefreshing, isFalse);
      expect(repository.fetchCount, 2);
    });

    test('coalesces simultaneous refresh requests', () async {
      final completer = Completer<PropertyPageModel>();
      final repository = _FakePropertyRepository((_) => completer.future);
      final provider = PropertyProvider(repository);
      addTearDown(provider.dispose);

      final first = provider.load();
      final second = provider.refresh();
      completer.complete(_propertyPage);
      await Future.wait([first, second]);

      expect(repository.fetchCount, 1);
    });
  });
}

class _FakePropertyRepository implements PropertyRepository {
  _FakePropertyRepository(this._fetch);

  final Future<PropertyPageModel> Function(int call) _fetch;
  int fetchCount = 0;

  @override
  Future<PropertyPageModel> getProperties() {
    fetchCount += 1;
    return _fetch(fetchCount);
  }
}

const _propertyPage = PropertyPageModel(
  properties: [
    PropertyModel(
      id: 1,
      name: 'Aurora Heights',
      type: 'apartment',
      employeeId: 12,
      addressLine1: 'Gulshan',
      addressLine2: '',
      city: 'Dhaka',
      state: '',
      postalCode: '',
      countryCode: 'BD',
      currency: 'BDT',
      currentValue: '25000000',
      purchasePrice: '18000000',
      notes: '',
      unitsCount: 0,
      units: [],
    ),
  ],
  meta: PropertyPaginationMetaModel(
    currentPage: 1,
    perPage: 20,
    total: 1,
    lastPage: 1,
  ),
  message: 'OK',
);
