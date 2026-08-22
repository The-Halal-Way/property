import 'package:property/feature/tenant/data/model/json_value_parser.dart';
import 'package:property/feature/tenant/data/model/tenant_lease_model.dart';

class TenantModel {
  const TenantModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.idDocumentType,
    required this.idDocumentNumber,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.countryCode,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.emergencyContactRelation,
    required this.familyMembersCount,
    required this.guardianName,
    required this.guardianPhone,
    required this.notes,
    required this.activeLeasesCount,
    required this.leases,
  });

  final int id;
  final String name;
  final String phone;
  final String email;
  final String idDocumentType;
  final String idDocumentNumber;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String countryCode;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String emergencyContactRelation;
  final int familyMembersCount;
  final String guardianName;
  final String guardianPhone;
  final String notes;
  final int activeLeasesCount;
  final List<TenantLeaseModel> leases;

  bool get hasActiveLease =>
      activeLeasesCount > 0 || leases.any((lease) => lease.isActive);

  String get displayName =>
      name.trim().isEmpty ? 'Unnamed tenant' : name.trim();

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2);
    return parts.map((part) => part[0].toUpperCase()).join();
  }

  String get fullAddress => [
    addressLine1,
    addressLine2,
    city,
    state,
    postalCode,
    countryCode,
  ].map((part) => part.trim()).where((part) => part.isNotEmpty).join(', ');

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    final rawLeases = json['leases'];
    final leases = rawLeases is List
        ? rawLeases
              .whereType<Map>()
              .map((lease) => TenantLeaseModel.fromJson(jsonMap(lease)))
              .toList(growable: false)
        : const <TenantLeaseModel>[];

    return TenantModel(
      id: jsonInt(json['id']),
      name: jsonString(json['name']),
      phone: jsonString(json['phone']),
      email: jsonString(json['email']),
      idDocumentType: jsonString(json['id_document_type']),
      idDocumentNumber: jsonString(json['id_document_number']),
      addressLine1: jsonString(json['address_line1']),
      addressLine2: jsonString(json['address_line2']),
      city: jsonString(json['city']),
      state: jsonString(json['state']),
      postalCode: jsonString(json['postal_code']),
      countryCode: jsonString(json['country_code']),
      emergencyContactName: jsonString(json['emergency_contact_name']),
      emergencyContactPhone: jsonString(json['emergency_contact_phone']),
      emergencyContactRelation: jsonString(json['emergency_contact_relation']),
      familyMembersCount: jsonInt(json['family_members_count']),
      guardianName: jsonString(json['guardian_name']),
      guardianPhone: jsonString(json['guardian_phone']),
      notes: jsonString(json['notes']),
      activeLeasesCount: jsonInt(json['active_leases_count']),
      leases: leases,
    );
  }
}
