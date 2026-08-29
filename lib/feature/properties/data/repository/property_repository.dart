import 'package:property/feature/properties/data/model/create_property_request.dart';
import 'package:property/feature/properties/data/model/property_model.dart';
import 'package:property/feature/properties/data/model/property_page_model.dart';

abstract interface class PropertyRepository {
  Future<PropertyPageModel> getProperties();
}

abstract interface class PropertyCreateRepository {
  Future<PropertyModel> createProperty(CreatePropertyRequest request);
}
