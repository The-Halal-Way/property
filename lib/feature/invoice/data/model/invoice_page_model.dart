import 'package:property/core/util/json_reader.dart';
import 'package:property/feature/invoice/data/model/invoice_model.dart';
import 'package:property/feature/invoice/data/model/invoice_pagination_meta_model.dart';

class InvoicePageModel {
  const InvoicePageModel({
    required this.invoices,
    required this.meta,
    required this.message,
  });

  final List<InvoiceModel> invoices;
  final InvoicePaginationMetaModel meta;
  final String message;

  double get totalInvoiced =>
      invoices.fold(0, (sum, item) => sum + item.totalValue);
  double get totalCollected =>
      invoices.fold(0, (sum, item) => sum + item.paidValue);
  double get totalOutstanding =>
      invoices.fold(0, (sum, item) => sum + item.balanceValue);
  int get paidCount => invoices.where((invoice) => invoice.isPaid).length;
  String get currency => invoices
      .map((item) => item.currency)
      .firstWhere((currency) => currency.isNotEmpty, orElse: () => '');

  factory InvoicePageModel.fromJson(JsonMap json) {
    final message = readString(json, 'message').trim();
    if (json['success'] == false) {
      throw StateError(message.isEmpty ? 'Unable to load invoices.' : message);
    }
    final data = json['data'];
    if (data is! List) {
      throw const FormatException('Expected invoice data to be a list.');
    }
    return InvoicePageModel(
      invoices: data
          .whereType<Map>()
          .map((item) => InvoiceModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      meta: InvoicePaginationMetaModel.fromJson(readMap(json, 'meta')),
      message: message,
    );
  }
}
