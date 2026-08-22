import 'package:property/core/util/json_reader.dart';

class InvoiceItemModel {
  const InvoiceItemModel({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
  });

  final int id;
  final String type;
  final String description;
  final String amount;

  factory InvoiceItemModel.fromJson(JsonMap json) => InvoiceItemModel(
    id: readInt(json, 'id'),
    type: readString(json, 'type').trim(),
    description: readString(json, 'description').trim(),
    amount: readString(json, 'amount').trim(),
  );
}
