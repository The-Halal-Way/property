import 'package:property/feature/employee/data/model/employee_json_parser.dart';

class EmployeeModel {
  const EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.designation,
    required this.loginEnabled,
    required this.notes,
    required this.photoUrl,
    required this.propertiesCount,
    required this.roles,
    required this.permissions,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String designation;
  final bool loginEnabled;
  final String notes;
  final String photoUrl;
  final int propertiesCount;
  final String roles;
  final List<String> permissions;

  String get displayName => name.isEmpty ? 'Unnamed employee' : name;

  String get displayDesignation =>
      designation.isEmpty ? 'Team member' : _titleCase(designation);

  List<String> get roleLabels => roles
      .split(RegExp(r'[,;|]'))
      .map((role) => role.trim())
      .where((role) => role.isNotEmpty)
      .toList(growable: false);

  String get primaryRole => roleLabels.isEmpty ? 'No role' : roleLabels.first;

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2);
    return parts.map((part) => part[0].toUpperCase()).join();
  }

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final rawPermissions = json['permissions'];

    return EmployeeModel(
      id: employeeJsonInt(json['id']),
      name: employeeJsonString(json['name']),
      email: employeeJsonString(json['email']),
      phone: employeeJsonString(json['phone']),
      designation: employeeJsonString(json['designation']),
      loginEnabled: employeeJsonBool(json['login_enabled']),
      notes: employeeJsonString(json['notes']),
      photoUrl: employeeJsonString(json['photo_url']),
      propertiesCount: employeeJsonInt(json['properties_count']),
      roles: employeeJsonString(json['roles']),
      permissions: rawPermissions is List
          ? rawPermissions
                .map(employeeJsonString)
                .where((permission) => permission.isNotEmpty)
                .toList(growable: false)
          : const <String>[],
    );
  }

  static String _titleCase(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
