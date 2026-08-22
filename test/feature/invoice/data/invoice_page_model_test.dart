import 'package:flutter_test/flutter_test.dart';
import 'package:property/feature/invoice/data/model/invoice_page_model.dart';

void main() {
  test('parses invoices, nested billing data, and summary totals', () {
    final page = InvoicePageModel.fromJson({
      'success': true,
      'message': 'OK',
      'data': [
        {
          'id': 8,
          'invoice_number': 'INV-008',
          'lease_id': 4,
          'period_start': '2026-07-01',
          'period_end': '2026-07-31',
          'issue_date': '2026-07-01',
          'due_date': '2026-07-05',
          'currency': 'BDT',
          'total_amount': '25000',
          'amount_paid': '10000',
          'balance_due': '15000',
          'status': 'partial',
          'notes': 'July rent',
          'items': [
            {
              'id': 1,
              'type': 'rent',
              'description': 'Monthly rent',
              'amount': '25000',
            },
          ],
          'payments': [
            {
              'id': 2,
              'amount': '10000',
              'currency': 'BDT',
              'paid_on': '2026-07-03',
              'method': 'bank',
              'reference': 'TX-1',
              'notes': '',
            },
          ],
          'lease': {
            'id': 4,
            'tenant': {'id': 12},
            'unit': {
              'id': 6,
              'name': 'Lake View 4B',
              'property': {'id': 3},
            },
          },
        },
      ],
      'meta': {'current_page': 1, 'per_page': 20, 'total': 1, 'last_page': 1},
    });

    expect(page.invoices.single.invoiceNumber, 'INV-008');
    expect(page.invoices.single.items.single.description, 'Monthly rent');
    expect(page.invoices.single.payments.single.reference, 'TX-1');
    expect(page.invoices.single.lease.tenantId, 12);
    expect(page.invoices.single.lease.unitName, 'Lake View 4B');
    expect(page.totalInvoiced, 25000);
    expect(page.totalCollected, 10000);
    expect(page.totalOutstanding, 15000);
    expect(page.meta.total, 1);
  });

  test('rejects an unsuccessful response', () {
    expect(
      () => InvoicePageModel.fromJson({
        'success': false,
        'message': 'Not authorized',
      }),
      throwsA(isA<StateError>()),
    );
  });
}
