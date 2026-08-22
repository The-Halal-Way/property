import 'package:flutter/material.dart';
import 'package:property/core/base/base_client.dart';
import 'package:property/core/constants/my_api_url.dart';
import 'package:property/feature/properties/data/model/property_json_parser.dart';
import 'package:property/feature/properties/data/model/property_page_model.dart';

abstract interface class PropertyRemoteDataSource {
  Future<PropertyPageModel> fetchProperties();
}

class BaseClientPropertyRemoteDataSource implements PropertyRemoteDataSource {
  const BaseClientPropertyRemoteDataSource(this._context);

  final BuildContext _context;

  @override
  Future<PropertyPageModel> fetchProperties() async {
    final response = await BaseClient.getData(
      endPoint: MyApiUrl.properties,
      ctx: _context,
    );

    return PropertyPageModel.fromJson(
      propertyJsonMap({
        "success": true,
        "message": "OK",
        "data": [
          {
            "id": 1,
            "name": "Sunset Towers",
            "type": "Residential",
            "employee_id": 101,
            "address_line1": "123 Sunset Boulevard",
            "address_line2": "",
            "city": "Los Angeles",
            "state": "CA",
            "postal_code": "90028",
            "country_code": "US",
            "currency": "USD",
            "current_value": "2450000.00",
            "purchase_price": "1800000.00",
            "notes": "Corner lot with ocean views. Recently renovated lobby.",
            "units_count": 12,
            "employee": {"id": 101},
            "units": [
              {
                "id": 1,
                "property_id": 1,
                "name": "Unit 101",
                "bedrooms": 2,
                "bathrooms": 2,
                "kitchens": 1,
                "parking_spaces": 1,
                "size": "950",
                "size_unit": "sqft",
                "condition": "Good",
                "amenities": ["Balcony", "Central AC", "Hardwood Floors"],
                "default_rent_amount": "2250.00",
                "notes": "Great natural light. Tenant moved in 02/2025.",
                "occupied": true,
                "current_tenant": {"id": 5},
                "property": {"id": 1},
              },
              {
                "id": 2,
                "property_id": 1,
                "name": "Unit 102",
                "bedrooms": 1,
                "bathrooms": 1,
                "kitchens": 1,
                "parking_spaces": 0,
                "size": "650",
                "size_unit": "sqft",
                "condition": "Excellent",
                "amenities": ["Patio", "Dishwasher", "Walk-in Closet"],
                "default_rent_amount": "1850.00",
                "notes": "Recently painted. Available for showing.",
                "occupied": false,
                "current_tenant": null,
                "property": {"id": 1},
              },
              {
                "id": 3,
                "property_id": 1,
                "name": "Unit 201",
                "bedrooms": 3,
                "bathrooms": 2.5,
                "kitchens": 1,
                "parking_spaces": 2,
                "size": "1350",
                "size_unit": "sqft",
                "condition": "Fair",
                "amenities": ["Fireplace", "In-unit Laundry", "Roof Access"],
                "default_rent_amount": "3200.00",
                "notes":
                    "Needs minor repairs in bathroom. Tenant moving out end of month.",
                "occupied": true,
                "current_tenant": {"id": 8},
                "property": {"id": 1},
              },
            ],
          },
          {
            "id": 2,
            "name": "Oakwood Business Center",
            "type": "Commercial",
            "employee_id": 102,
            "address_line1": "456 Oak Avenue",
            "address_line2": "Suite 200",
            "city": "Chicago",
            "state": "IL",
            "postal_code": "60607",
            "country_code": "US",
            "currency": "USD",
            "current_value": "3900000.00",
            "purchase_price": "3200000.00",
            "notes":
                "Mixed-use building with retail and office spaces. High foot traffic.",
            "units_count": 8,
            "employee": {"id": 102},
            "units": [
              {
                "id": 4,
                "property_id": 2,
                "name": "Retail Space A",
                "bedrooms": 0,
                "bathrooms": 1,
                "kitchens": 0,
                "parking_spaces": 4,
                "size": "2400",
                "size_unit": "sqft",
                "condition": "Excellent",
                "amenities": [
                  "Glass Front",
                  "High Ceilings",
                  "Security System",
                ],
                "default_rent_amount": "4500.00",
                "notes": "Ideal for restaurant or boutique. Previously a cafe.",
                "occupied": true,
                "current_tenant": {"id": 12},
                "property": {"id": 2},
              },
              {
                "id": 5,
                "property_id": 2,
                "name": "Office Suite 210",
                "bedrooms": 0,
                "bathrooms": 1,
                "kitchens": 1,
                "parking_spaces": 2,
                "size": "1800",
                "size_unit": "sqft",
                "condition": "Good",
                "amenities": ["Conference Room", "Break Area", "Carpeted"],
                "default_rent_amount": "3200.00",
                "notes": "Available August 1st. Includes cleaning service.",
                "occupied": false,
                "current_tenant": null,
                "property": {"id": 2},
              },
            ],
          },
          {
            "id": 3,
            "name": "Palm Grove Residences",
            "type": "Residential",
            "employee_id": 103,
            "address_line1": "789 Palm Drive",
            "address_line2": "Building B",
            "city": "Miami",
            "state": "FL",
            "postal_code": "33101",
            "country_code": "US",
            "currency": "USD",
            "current_value": "1850000.00",
            "purchase_price": "1500000.00",
            "notes":
                "Beachfront property with pool and gym. HOA fees included in rent.",
            "units_count": 6,
            "employee": {"id": 103},
            "units": [
              {
                "id": 6,
                "property_id": 3,
                "name": "Unit 1B",
                "bedrooms": 2,
                "bathrooms": 2,
                "kitchens": 1,
                "parking_spaces": 1,
                "size": "1100",
                "size_unit": "sqft",
                "condition": "Excellent",
                "amenities": ["Ocean View", "Balcony", "Pool Access"],
                "default_rent_amount": "2800.00",
                "notes": "Fully furnished. Short-term lease available.",
                "occupied": true,
                "current_tenant": {"id": 15},
                "property": {"id": 3},
              },
              {
                "id": 7,
                "property_id": 3,
                "name": "Unit 2A",
                "bedrooms": 3,
                "bathrooms": 2,
                "kitchens": 1,
                "parking_spaces": 2,
                "size": "1450",
                "size_unit": "sqft",
                "condition": "Fair",
                "amenities": ["Jacuzzi", "Smart Home", "Walk-in Closet"],
                "default_rent_amount": "3500.00",
                "notes": "Under renovation until September. Currently vacant.",
                "occupied": false,
                "current_tenant": null,
                "property": {"id": 3},
              },
            ],
          },
        ],
        "meta": {"current_page": 1, "per_page": 10, "total": 3, "last_page": 1},
      }),
    );

    if (response is! Map) {
      throw const FormatException('The properties response is invalid.');
    }
    return PropertyPageModel.fromJson(propertyJsonMap(response));
  }
}
