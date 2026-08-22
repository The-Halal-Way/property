Map<String, dynamic> propertyJsonMap(Object? value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

String propertyJsonString(Object? value) {
  if (value == null) return '';
  return value.toString().trim();
}

int propertyJsonInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(propertyJsonString(value)) ?? 0;
}

bool propertyJsonBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return propertyJsonString(value).toLowerCase() == 'true';
}
