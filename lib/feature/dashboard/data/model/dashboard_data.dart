import 'dart:math' as math;

class DashboardData {
  const DashboardData({required this.stats, required this.financials});

  final DashboardStats stats;
  final DashboardFinancials financials;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final props = _requireMap(json['props'], 'props');

    return DashboardData(
      stats: DashboardStats.fromJson(_requireMap(props['stats'], 'stats')),
      financials: DashboardFinancials.fromJson(
        _requireMap(props['financials'], 'financials'),
      ),
    );
  }
}

class DashboardStats {
  const DashboardStats({
    required this.properties,
    required this.units,
    required this.occupied,
    required this.vacant,
    required this.tenants,
    required this.activeLeases,
  });

  final int properties;
  final int units;
  final int occupied;
  final int vacant;
  final int tenants;
  final int activeLeases;

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      properties: _nonNegativeInt(json['properties']),
      units: _nonNegativeInt(json['units']),
      occupied: _nonNegativeInt(json['occupied']),
      vacant: _nonNegativeInt(json['vacant']),
      tenants: _nonNegativeInt(json['tenants']),
      activeLeases: _nonNegativeInt(json['activeLeases']),
    );
  }
}

class DashboardFinancials {
  const DashboardFinancials({required this.expected, required this.collected});

  final double expected;
  final double collected;

  double get outstanding => math.max(0, expected - collected).toDouble();

  double get collectionRate {
    if (expected <= 0) return 0;
    return (collected / expected).clamp(0.0, 1.0).toDouble();
  }

  factory DashboardFinancials.fromJson(Map<String, dynamic> json) {
    return DashboardFinancials(
      expected: _nonNegativeDouble(json['expected']),
      collected: _nonNegativeDouble(json['collected']),
    );
  }
}

Map<String, dynamic> _requireMap(Object? value, String fieldName) {
  if (value is! Map) {
    throw FormatException('Expected "$fieldName" to be a JSON object.');
  }

  return value.map((key, value) => MapEntry(key.toString(), value));
}

int _nonNegativeInt(Object? value) {
  final number = _parseNumber(value);
  if (number == null || !number.isFinite || number < 0) return 0;
  return number.toInt();
}

double _nonNegativeDouble(Object? value) {
  final number = _parseNumber(value);
  if (number == null || !number.isFinite || number < 0) return 0;
  return number.toDouble();
}

num? _parseNumber(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value.trim());
  return null;
}
