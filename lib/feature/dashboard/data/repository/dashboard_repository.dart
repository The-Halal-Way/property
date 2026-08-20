import 'package:flutter/material.dart';
import 'package:property/core/base/base_client.dart';
import 'package:property/core/constants/my_api_url.dart';
import 'package:property/feature/dashboard/data/model/dashboard_data.dart';

class DashboardRepository {
  Future<DashboardData?> fetchDashboard(BuildContext context) async {
    final response = await BaseClient.getData(
      endPoint: '${MyApiUrl.version}/${MyApiUrl.dashboard}',
      ctx: context,
    );

    return response == null ? DashboardData.fromJson({
    "component": "Dashboard",
    "props": {
        "errors": {},
        "stats": {
            "properties": 0,
            "units": 0,
            "occupied": 0,
            "vacant": 0,
            "tenants": 0,
            "activeLeases": 0
        },
        "financials": {
            "expected": 0,
            "collected": 0
        }
    },
    "url": "/dashboard",
    "version": "2a74918fee74bf249b0d8ed6718b7d02",
    "sharedProps": [
        "errors",
        "name",
        "auth",
        "status"
    ]
}) : DashboardData.fromJson(response);
  }
}