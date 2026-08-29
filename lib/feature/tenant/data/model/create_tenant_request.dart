import 'package:property/core/model/selected_upload_file.dart';

class CreateTenantRequest {
  const CreateTenantRequest({
    required this.name,
    required this.phone,
    this.email,
    this.idDocumentType,
    this.idDocumentNumber,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.countryCode,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.familyMembersCount,
    this.guardianName,
    this.guardianPhone,
    this.notes,
    this.photo,
    this.idDocument,
  });

  final String name;
  final String phone;
  final String? email;
  final String? idDocumentType;
  final String? idDocumentNumber;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? countryCode;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;
  final int? familyMembersCount;
  final String? guardianName;
  final String? guardianPhone;
  final String? notes;
  final SelectedUploadFile? photo;
  final SelectedUploadFile? idDocument;

  Map<String, dynamic> toFields() => {
    'name': name.trim(),
    'phone': phone.trim(),
    'email': ?_notBlank(email),
    'id_document_type': ?_notBlank(idDocumentType),
    'id_document_number': ?_notBlank(idDocumentNumber),
    'address_line1': ?_notBlank(addressLine1),
    'address_line2': ?_notBlank(addressLine2),
    'city': ?_notBlank(city),
    'state': ?_notBlank(state),
    'postal_code': ?_notBlank(postalCode),
    'country_code': ?_notBlank(countryCode)?.toUpperCase(),
    'emergency_contact_name': ?_notBlank(emergencyContactName),
    'emergency_contact_phone': ?_notBlank(emergencyContactPhone),
    'emergency_contact_relation': ?_notBlank(emergencyContactRelation),
    if (familyMembersCount != null) 'family_members_count': familyMembersCount,
    'guardian_name': ?_notBlank(guardianName),
    'guardian_phone': ?_notBlank(guardianPhone),
    'notes': ?_notBlank(notes),
  };
}

String? _notBlank(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
