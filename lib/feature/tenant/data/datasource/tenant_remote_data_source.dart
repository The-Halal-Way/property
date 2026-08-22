import 'package:flutter/material.dart';
import 'package:property/core/base/base_client.dart';
import 'package:property/core/constants/my_api_url.dart';
import 'package:property/feature/tenant/data/model/json_value_parser.dart';
import 'package:property/feature/tenant/data/model/tenant_page_model.dart';

abstract interface class TenantRemoteDataSource {
  Future<TenantPageModel> fetchTenants();
}

class BaseClientTenantRemoteDataSource implements TenantRemoteDataSource {
  const BaseClientTenantRemoteDataSource(this._context);

  final BuildContext _context;

  @override
  Future<TenantPageModel> fetchTenants() async {
    final response = await BaseClient.getData(
      endPoint: MyApiUrl.tenants,
      ctx: _context,
    );
    
     return TenantPageModel.fromJson(jsonMap(  {
  "success": true,
  "message": "OK",
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "phone": "+1-555-123-4567",
      "email": "john.doe@example.com",
      "id_document_type": "Passport",
      "id_document_number": "AB1234567",
      "address_line1": "123 Main Street",
      "address_line2": "Apt 4B",
      "city": "New York",
      "state": "NY",
      "postal_code": "10001",
      "country_code": "US",
      "emergency_contact_name": "Jane Doe",
      "emergency_contact_phone": "+1-555-987-6543",
      "emergency_contact_relation": "Spouse",
      "family_members_count": 3,
      "guardian_name": "Robert Doe",
      "guardian_phone": "+1-555-456-7890",
      "notes": "Prefers ground floor units. Has a small dog.",
      "active_leases_count": 1,
      "leases": [
        {
          "id": 101,
          "unit_id": 5,
          "tenant_id": 1,
          "rent_amount": "1850.00",
          "currency": "USD",
          "billing_frequency": "monthly",
          "start_date": "2025-01-01",
          "end_date": "2025-12-31",
          "due_day": 1,
          "deposit_amount": "1850.00",
          "status": "active",
          "notes": "Includes parking spot #12. Utilities not included.",
          "unit": {
            "id": 5,
            "name": "Sunrise Apartment - Unit 5",
            "property": {
              "id": 3
            }
          },
          "tenant": {
            "id": 1
          }
        },
        {
          "id": 102,
          "unit_id": 12,
          "tenant_id": 1,
          "rent_amount": "1200.00",
          "currency": "USD",
          "billing_frequency": "monthly",
          "start_date": "2024-06-01",
          "end_date": "2024-11-30",
          "due_day": 5,
          "deposit_amount": "1200.00",
          "status": "expired",
          "notes": "Previous lease. Unit was renovated after move-out.",
          "unit": {
            "id": 12,
            "name": "Oakwood Studio - Unit 12",
            "property": {
              "id": 7
            }
          },
          "tenant": {
            "id": 1
          }
        }
      ]
    },
    {
      "id": 2,
      "name": "Maria Garcia",
      "phone": "+1-555-234-5678",
      "email": "maria.garcia@email.com",
      "id_document_type": "Driver's License",
      "id_document_number": "DL9876543",
      "address_line1": "456 Oak Avenue",
      "address_line2": "",
      "city": "Los Angeles",
      "state": "CA",
      "postal_code": "90001",
      "country_code": "US",
      "emergency_contact_name": "Carlos Garcia",
      "emergency_contact_phone": "+1-555-876-5432",
      "emergency_contact_relation": "Brother",
      "family_members_count": 1,
      "guardian_name": "",
      "guardian_phone": "",
      "notes": "Works night shift. Prefers quiet building.",
      "active_leases_count": 1,
      "leases": [
        {
          "id": 103,
          "unit_id": 8,
          "tenant_id": 2,
          "rent_amount": "2200.00",
          "currency": "USD",
          "billing_frequency": "monthly",
          "start_date": "2025-02-15",
          "end_date": "2026-02-14",
          "due_day": 15,
          "deposit_amount": "2200.00",
          "status": "active",
          "notes": "Lease includes access to gym and pool.",
          "unit": {
            "id": 8,
            "name": "Palm Tower - Unit 8A",
            "property": {
              "id": 4
            }
          },
          "tenant": {
            "id": 2
          }
        }
      ]
    },
    {
      "id": 3,
      "name": "David Chen",
      "phone": "+1-555-345-6789",
      "email": "david.chen@work.com",
      "id_document_type": "National ID",
      "id_document_number": "NID5678901",
      "address_line1": "789 Pine Street",
      "address_line2": "Suite 200",
      "city": "Chicago",
      "state": "IL",
      "postal_code": "60601",
      "country_code": "US",
      "emergency_contact_name": "Lisa Chen",
      "emergency_contact_phone": "+1-555-765-4321",
      "emergency_contact_relation": "Sister",
      "family_members_count": 2,
      "guardian_name": "Michael Chen",
      "guardian_phone": "+1-555-654-3210",
      "notes": "Allergic to cats. Requested extra cleaning service.",
      "active_leases_count": 0,
      "leases": []
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 10,
    "total": 3,
    "last_page": 1
  }
} ));
    if (response is! Map) {
      throw const FormatException('The tenants response is invalid.');
    }
    return TenantPageModel.fromJson(jsonMap(response));
  }
}
