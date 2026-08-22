import 'package:flutter_test/flutter_test.dart';
import 'package:property/feature/report/data/model/report_model.dart';

void main() {
  test('parses collections and aging values from the response envelope', () {
    final report = ReportModel.fromJson({
      'success': true,
      'message': 'OK',
      'data': {
        'currency': 'BDT',
        'collections': {
          'invoiced': 100000,
          'collected': '65000',
          'outstanding': 35000.0,
        },
        'aging': {
          'not_due': 10000,
          'd1_30': 8000,
          'd31_60': 7000,
          'd61_90': 5000,
          'd90_plus': 5000,
          'total': 35000,
        },
      },
    });

    expect(report.currency, 'BDT');
    expect(report.collections.collected, 65000);
    expect(report.aging.d90Plus, 5000);
    expect(report.aging.total, 35000);
    expect(report.collectionRate, 0.65);
  });

  test('rejects a non-object data payload', () {
    expect(
      () => ReportModel.fromJson({'success': true, 'data': []}),
      throwsA(isA<FormatException>()),
    );
  });
}
