import 'package:property/core/util/json_reader.dart';

class InvoiceLeaseModel {
  const InvoiceLeaseModel({
    required this.id,
    required this.tenantId,
    required this.unitId,
    required this.unitName,
    required this.propertyId,
  });

  final int id;
  final int tenantId;
  final int unitId;
  final String unitName;
  final int propertyId;

  factory InvoiceLeaseModel.fromJson(JsonMap json) {
    final tenant = readMap(json, 'tenant');
    final unit = readMap(json, 'unit');
    final property = readMap(unit, 'property');
    return InvoiceLeaseModel(
      id: readInt(json, 'id'),
      tenantId: readInt(tenant, 'id'),
      unitId: readInt(unit, 'id'),
      unitName: readString(unit, 'name').trim(),
      propertyId: readInt(property, 'id'),
    );
  }
}
