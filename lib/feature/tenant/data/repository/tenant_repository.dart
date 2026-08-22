import 'package:property/feature/tenant/data/model/tenant_page_model.dart';

abstract interface class TenantRepository {
  Future<TenantPageModel> getTenants();
}
