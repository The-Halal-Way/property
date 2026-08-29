import 'package:property/core/model/selected_upload_file.dart';

class CreateEmployeeRequest {
  const CreateEmployeeRequest({
    required this.name,
    required this.loginEnabled,
    this.email,
    this.password,
    this.phone,
    this.designation,
    this.notes,
    this.photo,
    this.roles = const <int>[],
    this.permissions = const <String>[],
  });

  final String name;
  final String? email;
  final String? password;
  final bool loginEnabled;
  final String? phone;
  final String? designation;
  final String? notes;
  final SelectedUploadFile? photo;
  final List<int> roles;
  final List<String> permissions;

  Map<String, dynamic> toFields() => {
    'name': name.trim(),
    'login_enabled': loginEnabled,
    'email': ?_notBlank(email),
    'password': ?_notEmpty(password),
    'phone': ?_notBlank(phone),
    'designation': ?_notBlank(designation),
    'notes': ?_notBlank(notes),
    if (roles.isNotEmpty) 'roles': roles,
    if (permissions.isNotEmpty) 'permissions': permissions,
  };
}

String? _notBlank(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

String? _notEmpty(String? value) {
  return value == null || value.trim().isEmpty ? null : value;
}
