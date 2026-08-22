import 'package:property/feature/properties/data/model/property_json_parser.dart';

class PropertyUnitModel {
  const PropertyUnitModel({
    required this.id,
    required this.propertyId,
    required this.name,
    required this.bedrooms,
    required this.bathrooms,
    required this.kitchens,
    required this.parkingSpaces,
    required this.size,
    required this.sizeUnit,
    required this.condition,
    required this.amenities,
    required this.defaultRentAmount,
    required this.notes,
    required this.occupied,
    required this.currentTenantId,
  });

  final int id;
  final int propertyId;
  final String name;
  final int bedrooms;
  final int bathrooms;
  final int kitchens;
  final int parkingSpaces;
  final String size;
  final String sizeUnit;
  final String condition;
  final List<String> amenities;
  final String defaultRentAmount;
  final String notes;
  final bool occupied;
  final int currentTenantId;

  String get displayName => name.isEmpty ? 'Unit #$id' : name;

  String get sizeLabel {
    if (size.isEmpty) return '';
    return sizeUnit.isEmpty ? size : '$size $sizeUnit';
  }

  factory PropertyUnitModel.fromJson(Map<String, dynamic> json) {
    final rawAmenities = json['amenities'];
    final currentTenant = propertyJsonMap(json['current_tenant']);
    final property = propertyJsonMap(json['property']);
    final directPropertyId = propertyJsonInt(json['property_id']);

    return PropertyUnitModel(
      id: propertyJsonInt(json['id']),
      propertyId: directPropertyId > 0
          ? directPropertyId
          : propertyJsonInt(property['id']),
      name: propertyJsonString(json['name']),
      bedrooms: propertyJsonInt(json['bedrooms']),
      bathrooms: propertyJsonInt(json['bathrooms']),
      kitchens: propertyJsonInt(json['kitchens']),
      parkingSpaces: propertyJsonInt(json['parking_spaces']),
      size: propertyJsonString(json['size']),
      sizeUnit: propertyJsonString(json['size_unit']),
      condition: propertyJsonString(json['condition']),
      amenities: rawAmenities is List
          ? rawAmenities
                .map(propertyJsonString)
                .where((amenity) => amenity.isNotEmpty)
                .toList(growable: false)
          : const <String>[],
      defaultRentAmount: propertyJsonString(json['default_rent_amount']),
      notes: propertyJsonString(json['notes']),
      occupied: propertyJsonBool(json['occupied']),
      currentTenantId: propertyJsonInt(currentTenant['id']),
    );
  }
}
