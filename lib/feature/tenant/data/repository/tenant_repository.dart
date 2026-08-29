import 'package:property/feature/tenant/data/model/create_tenant_request.dart';
import 'package:property/feature/tenant/data/model/tenant_model.dart';
import 'package:property/feature/tenant/data/model/tenant_page_model.dart';

abstract interface class TenantRepository {
  Future<TenantPageModel> getTenants();
}

abstract interface class TenantCreateRepository {
  Future<TenantModel> createTenant(CreateTenantRequest request);
}
