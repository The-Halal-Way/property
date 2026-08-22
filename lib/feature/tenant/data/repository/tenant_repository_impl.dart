import 'package:property/feature/tenant/data/datasource/tenant_remote_data_source.dart';
import 'package:property/feature/tenant/data/model/tenant_page_model.dart';
import 'package:property/feature/tenant/data/repository/tenant_repository.dart';

class TenantRepositoryImpl implements TenantRepository {
  const TenantRepositoryImpl(this._remoteDataSource);

  final TenantRemoteDataSource _remoteDataSource;

  @override
  Future<TenantPageModel> getTenants() => _remoteDataSource.fetchTenants();
}
