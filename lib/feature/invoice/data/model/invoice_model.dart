import 'package:property/core/util/json_reader.dart';
import 'package:property/feature/invoice/data/model/invoice_item_model.dart';
import 'package:property/feature/invoice/data/model/invoice_lease_model.dart';
import 'package:property/feature/invoice/data/model/invoice_payment_model.dart';

class InvoiceModel {
  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.leaseId,
    required this.periodStart,
    required this.periodEnd,
    required this.issueDate,
    required this.dueDate,
    required this.currency,
    required this.totalAmount,
    required this.amountPaid,
    required this.balanceDue,
    required this.status,
    required this.notes,
    required this.items,
    required this.payments,
    required this.lease,
  });

  final int id;
  final String invoiceNumber;
  final int leaseId;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime? issueDate;
  final DateTime? dueDate;
  final String currency;
  final String totalAmount;
  final String amountPaid;
  final String balanceDue;
  final String status;
  final String notes;
  final List<InvoiceItemModel> items;
  final List<InvoicePaymentModel> payments;
  final InvoiceLeaseModel lease;

  String get displayNumber =>
      invoiceNumber.isEmpty ? 'Invoice #$id' : invoiceNumber;
  double get totalValue => double.tryParse(totalAmount) ?? 0;
  double get paidValue => double.tryParse(amountPaid) ?? 0;
  double get balanceValue => double.tryParse(balanceDue) ?? 0;
  double get paidProgress =>
      totalValue <= 0 ? 0 : (paidValue / totalValue).clamp(0.0, 1.0);
  bool get isPaid => status.toLowerCase() == 'paid' || balanceValue <= 0;

  factory InvoiceModel.fromJson(JsonMap json) => InvoiceModel(
    id: readInt(json, 'id'),
    invoiceNumber: readString(json, 'invoice_number').trim(),
    leaseId: readInt(json, 'lease_id'),
    periodStart: readDateTime(json, 'period_start'),
    periodEnd: readDateTime(json, 'period_end'),
    issueDate: readDateTime(json, 'issue_date'),
    dueDate: readDateTime(json, 'due_date'),
    currency: readString(json, 'currency').trim(),
    totalAmount: readString(json, 'total_amount').trim(),
    amountPaid: readString(json, 'amount_paid').trim(),
    balanceDue: readString(json, 'balance_due').trim(),
    status: readString(json, 'status').trim(),
    notes: readString(json, 'notes').trim(),
    items: readMapList(
      json,
      'items',
    ).map(InvoiceItemModel.fromJson).toList(growable: false),
    payments: readMapList(
      json,
      'payments',
    ).map(InvoicePaymentModel.fromJson).toList(growable: false),
    lease: InvoiceLeaseModel.fromJson(readMap(json, 'lease')),
  );
}
