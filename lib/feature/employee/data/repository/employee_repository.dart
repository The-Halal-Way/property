import 'package:property/feature/employee/data/model/create_employee_request.dart';
import 'package:property/feature/employee/data/model/employee_model.dart';
import 'package:property/feature/employee/data/model/employee_page_model.dart';

abstract interface class EmployeeRepository {
  Future<EmployeePageModel> getEmployees();
}

abstract interface class EmployeeCreateRepository {
  Future<EmployeeModel> createEmployee(CreateEmployeeRequest request);
}
