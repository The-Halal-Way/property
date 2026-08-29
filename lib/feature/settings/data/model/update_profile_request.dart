class UpdateProfileRequest {
  const UpdateProfileRequest({
    required this.name,
    required this.email,
    this.phone,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.countryCode,
    this.timezone,
    this.locale,
  });

  final String name;
  final String email;
  final String? phone;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? countryCode;
  final String? timezone;
  final String? locale;

  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    'email': email.trim(),
    'phone': _nullable(phone),
    'address_line1': _nullable(addressLine1),
    'address_line2': _nullable(addressLine2),
    'city': _nullable(city),
    'state': _nullable(state),
    'postal_code': _nullable(postalCode),
    'country_code': _nullable(countryCode)?.toUpperCase(),
    'timezone': _nullable(timezone),
    'locale': _nullable(locale),
  };
}

String? _nullable(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
