import 'package:property/feature/properties/data/model/property_json_parser.dart';
import 'package:property/feature/properties/data/model/property_model.dart';
import 'package:property/feature/properties/data/model/property_pagination_meta_model.dart';

class PropertyPageModel {
  const PropertyPageModel({
    required this.properties,
    required this.meta,
    required this.message,
  });

  final List<PropertyModel> properties;
  final PropertyPaginationMetaModel meta;
  final String message;

  int get totalUnits => properties.fold(
    0,
    (total, property) => total + property.resolvedUnitsCount,
  );

  int get occupiedUnits => properties.fold(
    0,
    (total, property) => total + property.occupiedUnitsCount,
  );

  int get vacantUnits => (totalUnits - occupiedUnits).clamp(0, totalUnits);

  factory PropertyPageModel.fromJson(Map<String, dynamic> json) {
    final message = propertyJsonString(json['message']);
    if (json['success'] == false) {
      throw StateError(
        message.isEmpty ? 'Unable to load properties.' : message,
      );
    }

    final rawProperties = json['data'];
    if (rawProperties is! List) {
      throw const FormatException('Expected property data to be a list.');
    }

    final rawMeta = propertyJsonMap(json['meta']);
    return PropertyPageModel(
      properties: rawProperties
          .whereType<Map>()
          .map((property) => PropertyModel.fromJson(propertyJsonMap(property)))
          .toList(growable: false),
      meta: PropertyPaginationMetaModel(
        currentPage: propertyJsonInt(rawMeta['current_page']),
        perPage: propertyJsonInt(rawMeta['per_page']),
        total: propertyJsonInt(rawMeta['total']),
        lastPage: propertyJsonInt(rawMeta['last_page']),
      ),
      message: message,
    );
  }
}
