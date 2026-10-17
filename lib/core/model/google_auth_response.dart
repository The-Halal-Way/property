class GoogleAuthResponse {
  const GoogleAuthResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final GoogleAuthData data;

  factory GoogleAuthResponse.fromJson(Map<String, dynamic> json) {
    return GoogleAuthResponse(
      success: _asBool(json['success']),
      message: _asString(json['message']),
      data: GoogleAuthData.fromJson(_asMap(json['data'])),
    );
  }
}

class GoogleAuthData {
  const GoogleAuthData({
    required this.token,
    required this.actorType,
    required this.user,
  });

  final String token;
  final String actorType;
  final GoogleAuthUser user;

  factory GoogleAuthData.fromJson(Map<String, dynamic> json) {
    return GoogleAuthData(
      token: _asString(json['token']),
      actorType: _asString(json['actor_type']),
      user: GoogleAuthUser.fromJson(_asMap(json['user'])),
    );
  }
}

class GoogleAuthUser {
  const GoogleAuthUser({
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

  factory GoogleAuthUser.fromJson(Map<String, dynamic> json) {
    return GoogleAuthUser(
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
}

Map<String, dynamic> _asMap(Object? value) {
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
