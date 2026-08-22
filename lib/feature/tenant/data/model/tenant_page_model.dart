import 'package:property/feature/tenant/data/model/json_value_parser.dart';
import 'package:property/feature/tenant/data/model/pagination_meta_model.dart';
import 'package:property/feature/tenant/data/model/tenant_model.dart';

class TenantPageModel {
  const TenantPageModel({
    required this.tenants,
    required this.meta,
    required this.message,
  });

  final List<TenantModel> tenants;
  final PaginationMetaModel meta;
  final String message;

  int get activeTenantCount =>
      tenants.where((tenant) => tenant.hasActiveLease).length;

  int get activeLeaseCount =>
      tenants.fold(0, (total, tenant) => total + tenant.activeLeasesCount);

  int get propertyCount => tenants
      .expand((tenant) => tenant.leases)
      .map((lease) => lease.propertyId)
      .where((id) => id > 0)
      .toSet()
      .length;

  factory TenantPageModel.fromJson(Map<String, dynamic> json) {
    final message = jsonString(json['message']);
    if (json['success'] == false) {
      throw StateError(message.isEmpty ? 'Unable to load tenants.' : message);
    }

    final rawTenants = json['data'];
    if (rawTenants is! List) {
      throw const FormatException('Expected tenant data to be a list.');
    }

    final rawMeta = jsonMap(json['meta']);
    return TenantPageModel(
      tenants: rawTenants
          .whereType<Map>()
          .map((tenant) => TenantModel.fromJson(jsonMap(tenant)))
          .toList(growable: false),
      meta: PaginationMetaModel(
        currentPage: jsonInt(rawMeta['current_page']),
        perPage: jsonInt(rawMeta['per_page']),
        total: jsonInt(rawMeta['total']),
        lastPage: jsonInt(rawMeta['last_page']),
      ),
      message: message,
    );
  }
}
