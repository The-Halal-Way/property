import 'package:property/feature/employee/data/model/employee_json_parser.dart';
import 'package:property/feature/employee/data/model/employee_model.dart';
import 'package:property/feature/employee/data/model/employee_pagination_meta_model.dart';

class EmployeePageModel {
  const EmployeePageModel({
    required this.employees,
    required this.meta,
    required this.message,
  });

  final List<EmployeeModel> employees;
  final EmployeePaginationMetaModel meta;
  final String message;

  int get loginEnabledCount =>
      employees.where((employee) => employee.loginEnabled).length;

  int get managedPropertiesCount =>
      employees.fold(0, (total, employee) => total + employee.propertiesCount);

  int get uniquePermissionsCount => employees
      .expand((employee) => employee.permissions)
      .map((permission) => permission.toLowerCase())
      .toSet()
      .length;

  factory EmployeePageModel.fromJson(Map<String, dynamic> json) {
    final message = employeeJsonString(json['message']);
    if (json['success'] == false) {
      throw StateError(message.isEmpty ? 'Unable to load employees.' : message);
    }

    final rawEmployees = json['data'];
    if (rawEmployees is! List) {
      throw const FormatException('Expected employee data to be a list.');
    }

    final rawMeta = employeeJsonMap(json['meta']);
    return EmployeePageModel(
      employees: rawEmployees
          .whereType<Map>()
          .map((employee) => EmployeeModel.fromJson(employeeJsonMap(employee)))
          .toList(growable: false),
      meta: EmployeePaginationMetaModel(
        currentPage: employeeJsonInt(rawMeta['current_page']),
        perPage: employeeJsonInt(rawMeta['per_page']),
        total: employeeJsonInt(rawMeta['total']),
        lastPage: employeeJsonInt(rawMeta['last_page']),
      ),
      message: message,
    );
  }
}
