import 'package:property/core/util/json_reader.dart';

class InvoicePaymentModel {
  const InvoicePaymentModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.paidOn,
    required this.method,
    required this.reference,
    required this.notes,
  });

  final int id;
  final String amount;
  final String currency;
  final DateTime? paidOn;
  final String method;
  final String reference;
  final String notes;

  factory InvoicePaymentModel.fromJson(JsonMap json) => InvoicePaymentModel(
    id: readInt(json, 'id'),
    amount: readString(json, 'amount').trim(),
    currency: readString(json, 'currency').trim(),
    paidOn: readDateTime(json, 'paid_on'),
    method: readString(json, 'method').trim(),
    reference: readString(json, 'reference').trim(),
    notes: readString(json, 'notes').trim(),
  );
}
