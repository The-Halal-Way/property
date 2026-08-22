import 'package:flutter/material.dart';
import 'package:property/core/base/base_client.dart';
import 'package:property/core/constants/my_api_url.dart';
import 'package:property/feature/employee/data/model/employee_json_parser.dart';
import 'package:property/feature/employee/data/model/employee_page_model.dart';

abstract interface class EmployeeRemoteDataSource {
  Future<EmployeePageModel> fetchEmployees();
}

class BaseClientEmployeeRemoteDataSource implements EmployeeRemoteDataSource {
  const BaseClientEmployeeRemoteDataSource(this._context);

  final BuildContext _context;

  @override
  Future<EmployeePageModel> fetchEmployees() async {
    final response = await BaseClient.getData(
      endPoint: MyApiUrl.employees,
      ctx: _context,
    );

    return EmployeePageModel.fromJson(employeeJsonMap({
  "success": true,
  "message": "OK",
  "data": [
    {
      "id": 1,
      "name": "Sarah Johnson",
      "email": "sarah.johnson@propmanager.com",
      "phone": "+1-555-111-2233",
      "designation": "Property Manager",
      "login_enabled": true,
      "notes": "Manages all residential properties in the downtown area. Has 8 years of experience.",
      "photo_url": "https://cdn.example.com/photos/sarah_johnson.jpg",
      "properties_count": 12,
      "roles": "Manager",
      "permissions": [
        "view_properties",
        "create_leases",
        "edit_tenants",
        "view_reports",
        "manage_maintenance",
        "approve_payments"
      ]
    },
    {
      "id": 2,
      "name": "Michael Chen",
      "email": "michael.chen@propmanager.com",
      "phone": "+1-555-222-3344",
      "designation": "Leasing Agent",
      "login_enabled": true,
      "notes": "Specializes in commercial properties. Fluent in Mandarin and English.",
      "photo_url": "https://cdn.example.com/photos/michael_chen.jpg",
      "properties_count": 5,
      "roles": "Agent",
      "permissions": [
        "view_properties",
        "create_leases",
        "schedule_viewings",
        "process_applications"
      ]
    },
    {
      "id": 3,
      "name": "Emily Rodriguez",
      "email": "emily.r@propmanager.com",
      "phone": "+1-555-333-4455",
      "designation": "Accountant",
      "login_enabled": false,
      "notes": "Part-time accountant, handles rent collection and financial reporting. Works remotely.",
      "photo_url": "",
      "properties_count": 0,
      "roles": "Finance",
      "permissions": [
        "view_reports",
        "manage_invoices",
        "process_payments",
        "audit_transactions"
      ]
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 10,
    "total": 3,
    "last_page": 1
  }
}));
    if (response is! Map) {
      throw const FormatException('The employees response is invalid.');
    }
    return EmployeePageModel.fromJson(employeeJsonMap(response));
  }
}
