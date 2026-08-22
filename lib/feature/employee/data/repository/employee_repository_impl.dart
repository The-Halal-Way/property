import 'package:property/feature/employee/data/datasource/employee_remote_data_source.dart';
import 'package:property/feature/employee/data/model/employee_page_model.dart';
import 'package:property/feature/employee/data/repository/employee_repository.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  const EmployeeRepositoryImpl(this._remoteDataSource);

  final EmployeeRemoteDataSource _remoteDataSource;

  @override
  Future<EmployeePageModel> getEmployees() =>
      _remoteDataSource.fetchEmployees();
}
