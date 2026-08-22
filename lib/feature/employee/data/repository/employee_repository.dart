import 'package:property/feature/employee/data/model/employee_page_model.dart';

abstract interface class EmployeeRepository {
  Future<EmployeePageModel> getEmployees();
}
