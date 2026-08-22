import 'package:property/feature/properties/data/model/property_page_model.dart';

abstract interface class PropertyRepository {
  Future<PropertyPageModel> getProperties();
}
