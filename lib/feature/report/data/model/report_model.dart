import 'package:property/core/util/json_reader.dart';

class ReportModel {
  const ReportModel({
    required this.currency,
    required this.collections,
    required this.aging,
    this.message = '',
  });

  final String currency;
  final ReportCollectionsModel collections;
  final ReportAgingModel aging;
  final String message;

  double get collectionRate => collections.invoiced <= 0
      ? 0
      : (collections.collected / collections.invoiced).clamp(0.0, 1.0);

  factory ReportModel.fromJson(JsonMap json) {
    final message = readString(json, 'message').trim();
    if (json['success'] == false) {
      throw StateError(message.isEmpty ? 'Unable to load report.' : message);
    }
    if (json.containsKey('data') && json['data'] is! Map) {
      throw const FormatException('Expected report data to be an object.');
    }
    final payload = json.containsKey('data') ? readMap(json, 'data') : json;
    return ReportModel(
      currency: readString(payload, 'currency').trim(),
      collections: ReportCollectionsModel.fromJson(
        readMap(payload, 'collections'),
      ),
      aging: ReportAgingModel.fromJson(readMap(payload, 'aging')),
      message: message,
    );
  }
}

class ReportCollectionsModel {
  const ReportCollectionsModel({
    required this.invoiced,
    required this.collected,
    required this.outstanding,
  });

  final double invoiced;
  final double collected;
  final double outstanding;

  factory ReportCollectionsModel.fromJson(JsonMap json) =>
      ReportCollectionsModel(
        invoiced: _readNumber(json['invoiced']),
        collected: _readNumber(json['collected']),
        outstanding: _readNumber(json['outstanding']),
      );
}

class ReportAgingModel {
  const ReportAgingModel({
    required this.notDue,
    required this.d1To30,
    required this.d31To60,
    required this.d61To90,
    required this.d90Plus,
    required this.total,
  });

  final double notDue;
  final double d1To30;
  final double d31To60;
  final double d61To90;
  final double d90Plus;
  final double total;

  factory ReportAgingModel.fromJson(JsonMap json) => ReportAgingModel(
    notDue: _readNumber(json['not_due']),
    d1To30: _readNumber(json['d1_30']),
    d31To60: _readNumber(json['d31_60']),
    d61To90: _readNumber(json['d61_90']),
    d90Plus: _readNumber(json['d90_plus']),
    total: _readNumber(json['total']),
  );
}

double _readNumber(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
