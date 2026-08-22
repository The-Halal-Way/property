import 'package:property/feature/report/data/datasource/report_remote_data_source.dart';
import 'package:property/feature/report/data/model/report_model.dart';
import 'package:property/feature/report/data/repository/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  const ReportRepositoryImpl(this._remoteDataSource);

  final ReportRemoteDataSource _remoteDataSource;

  @override
  Future<ReportModel> getReport() => _remoteDataSource.fetchReport();
}
