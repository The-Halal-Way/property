Map<String, dynamic> jsonMap(Object? value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

String jsonString(Object? value) {
  if (value == null) return '';
  return value.toString().trim();
}

int jsonInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(jsonString(value)) ?? 0;
}

DateTime? jsonDate(Object? value) {
  final raw = jsonString(value);
  return raw.isEmpty ? null : DateTime.tryParse(raw);
}
