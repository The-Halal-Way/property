Map<String, dynamic> employeeJsonMap(Object? value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

String employeeJsonString(Object? value) {
  if (value == null) return '';
  return value.toString().trim();
}

int employeeJsonInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(employeeJsonString(value)) ?? 0;
}

bool employeeJsonBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return employeeJsonString(value).toLowerCase() == 'true';
}
