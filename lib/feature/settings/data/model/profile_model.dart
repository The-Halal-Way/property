class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.currency,
    required this.currencyLocked,
    required this.countryCode,
    required this.timezone,
    required this.locale,
    required this.hasPassword,
    required this.emailVerified,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String currency;
  final bool currencyLocked;
  final String countryCode;
  final String timezone;
  final String locale;
  final bool hasPassword;
  final bool emailVerified;

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: _asInt(json['id']),
    name: _asString(json['name']),
    email: _asString(json['email']),
    phone: _asString(json['phone']),
    avatarUrl: _asString(json['avatar_url']),
    currency: _asString(json['currency']),
    currencyLocked: _asBool(json['currency_locked']),
    countryCode: _asString(json['country_code']),
    timezone: _asString(json['timezone']),
    locale: _asString(json['locale']),
    hasPassword: _asBool(json['has_password']),
    emailVerified: _asBool(json['email_verified']),
  );
}

Map<String, dynamic> profileJsonMap(Object? value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

String _asString(Object? value) => value?.toString().trim() ?? '';

int _asInt(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(_asString(value)) ?? 0;
}

bool _asBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return _asString(value).toLowerCase() == 'true';
}
