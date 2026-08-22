import 'package:property/feature/properties/data/model/property_json_parser.dart';
import 'package:property/feature/properties/data/model/property_unit_model.dart';

class PropertyModel {
  const PropertyModel({
    required this.id,
    required this.name,
    required this.type,
    required this.employeeId,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.countryCode,
    required this.currency,
    required this.currentValue,
    required this.purchasePrice,
    required this.notes,
    required this.unitsCount,
    required this.units,
  });

  final int id;
  final String name;
  final String type;
  final int employeeId;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String countryCode;
  final String currency;
  final String currentValue;
  final String purchasePrice;
  final String notes;
  final int unitsCount;
  final List<PropertyUnitModel> units;

  String get displayName => name.isEmpty ? 'Unnamed property' : name;

  String get displayType => type.isEmpty ? 'Property' : _titleCase(type);

  String get fullAddress => [
    addressLine1,
    addressLine2,
    city,
    state,
    postalCode,
    countryCode,
  ].map((part) => part.trim()).where((part) => part.isNotEmpty).join(', ');

  int get resolvedUnitsCount =>
      unitsCount > units.length ? unitsCount : units.length;

  int get occupiedUnitsCount => units.where((unit) => unit.occupied).length;

  int get vacantUnitsCount =>
      (resolvedUnitsCount - occupiedUnitsCount).clamp(0, resolvedUnitsCount);

  double get occupancyRate {
    if (resolvedUnitsCount == 0) return 0;
    return occupiedUnitsCount / resolvedUnitsCount;
  }

  String moneyLabel(String amount) {
    if (amount.isEmpty) return 'Not set';
    return currency.isEmpty ? amount : '$currency $amount';
  }

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    final rawUnits = json['units'];
    final employee = propertyJsonMap(json['employee']);
    final directEmployeeId = propertyJsonInt(json['employee_id']);

    return PropertyModel(
      id: propertyJsonInt(json['id']),
      name: propertyJsonString(json['name']),
      type: propertyJsonString(json['type']),
      employeeId: directEmployeeId > 0
          ? directEmployeeId
          : propertyJsonInt(employee['id']),
      addressLine1: propertyJsonString(json['address_line1']),
      addressLine2: propertyJsonString(json['address_line2']),
      city: propertyJsonString(json['city']),
      state: propertyJsonString(json['state']),
      postalCode: propertyJsonString(json['postal_code']),
      countryCode: propertyJsonString(json['country_code']),
      currency: propertyJsonString(json['currency']),
      currentValue: propertyJsonString(json['current_value']),
      purchasePrice: propertyJsonString(json['purchase_price']),
      notes: propertyJsonString(json['notes']),
      unitsCount: propertyJsonInt(json['units_count']),
      units: rawUnits is List
          ? rawUnits
                .whereType<Map>()
                .map(
                  (unit) => PropertyUnitModel.fromJson(propertyJsonMap(unit)),
                )
                .toList(growable: false)
          : const <PropertyUnitModel>[],
    );
  }

  static String _titleCase(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
