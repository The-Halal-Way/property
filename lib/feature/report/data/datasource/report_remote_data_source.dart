import 'package:flutter/material.dart';
import 'package:property/core/base/base_client.dart';
import 'package:property/core/constants/my_api_url.dart';
import 'package:property/feature/report/data/model/report_model.dart';

abstract interface class ReportRemoteDataSource {
  Future<ReportModel> fetchReport();
}

class BaseClientReportRemoteDataSource implements ReportRemoteDataSource {
  const BaseClientReportRemoteDataSource(this._context);

  final BuildContext _context;

  @override
  Future<ReportModel> fetchReport() async {
    final response = await BaseClient.getData(
      endPoint: MyApiUrl.reports,
      ctx: _context,
    );
    return ReportModel.fromJson(Map<String, dynamic>.from({
  "success": true,
  "message": "OK",
  "data": {
    "currency": "USD",
    "collections": {
      "invoiced": 5250.00,
      "collected": 3050.00,
      "outstanding": 2200.00
    },
    "aging": {
      "not_due": 0.00,
      "d1_30": 2200.00,
      "d31_60": 0.00,
      "d61_90": 0.00,
      "d90_plus": 0.00,
      "total": 2200.00
    }
  }
}));
    if (response is! Map) {
      throw const FormatException('The report response is invalid.');
    }
    return ReportModel.fromJson(Map<String, dynamic>.from(response));
  }
}
