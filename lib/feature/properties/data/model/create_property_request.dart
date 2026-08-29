import 'package:property/core/model/selected_upload_file.dart';

class CreatePropertyRequest {
  const CreatePropertyRequest({
    required this.name,
    required this.type,
    required this.addressLine1,
    required this.city,
    required this.countryCode,
    this.employeeId,
    this.addressLine2,
    this.state,
    this.postalCode,
    this.currentValue,
    this.purchasePrice,
    this.notes,
    this.image,
  });

  final String name;
  final String type;
  final String? employeeId;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? state;
  final String? postalCode;
  final String countryCode;
  final double? currentValue;
  final double? purchasePrice;
  final String? notes;
  final SelectedUploadFile? image;

  Map<String, dynamic> toFields() => {
    'name': name.trim(),
    'type': type.trim().toLowerCase(),
    'address_line1': addressLine1.trim(),
    'city': city.trim(),
    'country_code': countryCode.trim().toUpperCase(),
    'employee_id': ?_notBlank(employeeId),
    'address_line2': ?_notBlank(addressLine2),
    'state': ?_notBlank(state),
    'postal_code': ?_notBlank(postalCode),
    if (currentValue != null) 'current_value': currentValue,
    if (purchasePrice != null) 'purchase_price': purchasePrice,
    'notes': ?_notBlank(notes),
  };
}

String? _notBlank(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
