import 'package:property/feature/report/data/model/report_model.dart';

abstract interface class ReportRepository {
  Future<ReportModel> getReport();
}
