import 'package:property/feature/tenant/data/model/json_value_parser.dart';

class TenantLeaseModel {
  const TenantLeaseModel({
    required this.id,
    required this.unitId,
    required this.tenantId,
    required this.rentAmount,
    required this.currency,
    required this.billingFrequency,
    required this.startDate,
    required this.endDate,
    required this.dueDay,
    required this.depositAmount,
    required this.status,
    required this.notes,
    required this.unitName,
    required this.propertyId,
  });

  final int id;
  final int unitId;
  final int tenantId;
  final String rentAmount;
  final String currency;
  final String billingFrequency;
  final DateTime? startDate;
  final DateTime? endDate;
  final int dueDay;
  final String depositAmount;
  final String status;
  final String notes;
  final String unitName;
  final int propertyId;

  bool get isActive => status.trim().toLowerCase() == 'active';

  factory TenantLeaseModel.fromJson(Map<String, dynamic> json) {
    final unit = jsonMap(json['unit']);
    final property = jsonMap(unit['property']);

    return TenantLeaseModel(
      id: jsonInt(json['id']),
      unitId: jsonInt(json['unit_id']),
      tenantId: jsonInt(json['tenant_id']),
      rentAmount: jsonString(json['rent_amount']),
      currency: jsonString(json['currency']),
      billingFrequency: jsonString(json['billing_frequency']),
      startDate: jsonDate(json['start_date']),
      endDate: jsonDate(json['end_date']),
      dueDay: jsonInt(json['due_day']),
      depositAmount: jsonString(json['deposit_amount']),
      status: jsonString(json['status']),
      notes: jsonString(json['notes']),
      unitName: jsonString(unit['name']),
      propertyId: jsonInt(property['id']),
    );
  }
}
