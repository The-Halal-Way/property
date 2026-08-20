import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property/feature/dashboard/data/repository/dashboard_repository.dart';
import 'package:property/feature/dashboard/data/model/dashboard_data.dart';
import 'package:property/feature/dashboard/presentation/provider/dashboard_provider.dart';

void main() {
  group('DashboardProvider', () {
    testWidgets('loads data and exposes initial loading state', (tester) async {
      final context = await _pumpContext(tester);
      final completer = Completer<DashboardData>();
      final repository = _FakeDashboardRepository((_) => completer.future);
      final provider = DashboardProvider(repository);
      addTearDown(provider.dispose);

      final request = provider.load(context);

      expect(provider.isInitialLoading, isTrue);
      expect(provider.isRefreshing, isFalse);
      expect(provider.errorMessage, isNull);

      completer.complete(_firstDashboard);
      await request;

      expect(provider.data, same(_firstDashboard));
      expect(provider.isInitialLoading, isFalse);
      expect(provider.isRefreshing, isFalse);
      expect(provider.errorMessage, isNull);
      expect(repository.fetchCount, 1);
    });

    testWidgets('exposes an error when the first load returns no data', (
      tester,
    ) async {
      final context = await _pumpContext(tester);
      final repository = _FakeDashboardRepository((_) async => null);
      final provider = DashboardProvider(repository);
      addTearDown(provider.dispose);

      await provider.load(context);

      expect(provider.data, isNull);
      expect(provider.isInitialLoading, isFalse);
      expect(provider.isRefreshing, isFalse);
      expect(provider.errorMessage, 'Unable to load the dashboard.');
    });

    testWidgets('retains stale data when refresh returns no data', (
      tester,
    ) async {
      final context = await _pumpContext(tester);
      final refreshCompleter = Completer<DashboardData?>();
      final repository = _FakeDashboardRepository((call) {
        if (call == 1) return Future.value(_firstDashboard);
        return refreshCompleter.future;
      });
      final provider = DashboardProvider(repository);
      addTearDown(provider.dispose);

      await provider.load(context);
      final refresh = provider.refresh(context);

      expect(provider.data, same(_firstDashboard));
      expect(provider.isInitialLoading, isFalse);
      expect(provider.isRefreshing, isTrue);

      refreshCompleter.complete();
      await refresh;

      expect(provider.data, same(_firstDashboard));
      expect(provider.isRefreshing, isFalse);
      expect(provider.errorMessage, 'Unable to load the dashboard.');
      expect(repository.fetchCount, 2);
    });
  });
}

class _FakeDashboardRepository extends DashboardRepository {
  _FakeDashboardRepository(this._fetch);

  final Future<DashboardData?> Function(int call) _fetch;
  int fetchCount = 0;

  @override
  Future<DashboardData?> fetchDashboard(BuildContext context) {
    fetchCount += 1;
    return _fetch(fetchCount);
  }
}

Future<BuildContext> _pumpContext(WidgetTester tester) async {
  late BuildContext context;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (builderContext) {
          context = builderContext;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return context;
}

const _firstDashboard = DashboardData(
  stats: DashboardStats(
    properties: 2,
    units: 8,
    occupied: 6,
    vacant: 2,
    tenants: 6,
    activeLeases: 5,
  ),
  financials: DashboardFinancials(expected: 1000, collected: 750),
);
