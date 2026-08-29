import 'package:property/feature/properties/data/datasource/property_remote_data_source.dart';
import 'package:property/feature/properties/data/model/create_property_request.dart';
import 'package:property/feature/properties/data/model/property_model.dart';
import 'package:property/feature/properties/data/model/property_page_model.dart';
import 'package:property/feature/properties/data/repository/property_repository.dart';

class PropertyRepositoryImpl
    implements PropertyRepository, PropertyCreateRepository {
  const PropertyRepositoryImpl(this._remoteDataSource);

  final PropertyRemoteDataSource _remoteDataSource;

  @override
  Future<PropertyPageModel> getProperties() =>
      _remoteDataSource.fetchProperties();

  @override
  Future<PropertyModel> createProperty(CreatePropertyRequest request) =>
      _remoteDataSource.createProperty(request);
}
