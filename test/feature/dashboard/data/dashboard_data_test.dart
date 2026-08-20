import 'package:flutter_test/flutter_test.dart';
import 'package:property/feature/dashboard/data/model/dashboard_data.dart';

void main() {
  group('DashboardData.fromJson', () {
    test('parses the supplied all-zero Inertia envelope', () {
      final data = DashboardData.fromJson({
        'component': 'Dashboard',
        'props': {
          'errors': <String, dynamic>{},
          'stats': {
            'properties': 0,
            'units': 0,
            'occupied': 0,
            'vacant': 0,
            'tenants': 0,
            'activeLeases': 0,
          },
          'financials': {'expected': 0, 'collected': 0},
        },
        'url': '/dashboard',
        'version': '2a74918fee74bf249b0d8ed6718b7d02',
        'sharedProps': ['errors', 'name', 'auth', 'status'],
      });

      expect(data.stats.properties, 0);
      expect(data.stats.units, 0);
      expect(data.stats.occupied, 0);
      expect(data.stats.vacant, 0);
      expect(data.stats.tenants, 0);
      expect(data.stats.activeLeases, 0);
      expect(data.financials.expected, 0);
      expect(data.financials.collected, 0);
      expect(data.financials.outstanding, 0);
      expect(data.financials.collectionRate, 0);
    });

    test('accepts numeric strings and defaults invalid leaves to zero', () {
      final data = DashboardData.fromJson({
        'props': {
          'stats': {
            'properties': '12',
            'units': -4,
            'occupied': null,
            'tenants': 'not-a-number',
            'activeLeases': ' 5 ',
          },
          'financials': {'expected': '100.50', 'collected': '125.75'},
        },
      });

      expect(data.stats.properties, 12);
      expect(data.stats.units, 0);
      expect(data.stats.occupied, 0);
      expect(data.stats.vacant, 0);
      expect(data.stats.tenants, 0);
      expect(data.stats.activeLeases, 5);
      expect(data.financials.expected, 100.5);
      expect(data.financials.collected, 125.75);
      expect(data.financials.outstanding, 0);
      expect(data.financials.collectionRate, 1);
    });

    test('clamps negative financial values to zero', () {
      final data = DashboardData.fromJson({
        'props': {
          'stats': <String, dynamic>{},
          'financials': {'expected': '-10', 'collected': -2},
        },
      });

      expect(data.financials.expected, 0);
      expect(data.financials.collected, 0);
      expect(data.financials.outstanding, 0);
      expect(data.financials.collectionRate, 0);
    });

    test('rejects malformed props', () {
      expect(
        () => DashboardData.fromJson({'props': 'invalid'}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
