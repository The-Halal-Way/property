import 'package:property/core/util/json_reader.dart';

class InvoicePaginationMetaModel {
  const InvoicePaginationMetaModel({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  factory InvoicePaginationMetaModel.fromJson(JsonMap json) =>
      InvoicePaginationMetaModel(
        currentPage: readInt(json, 'current_page'),
        perPage: readInt(json, 'per_page'),
        total: readInt(json, 'total'),
        lastPage: readInt(json, 'last_page'),
      );
}
