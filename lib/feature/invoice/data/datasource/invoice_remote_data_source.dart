import 'package:flutter/material.dart';
import 'package:property/core/base/base_client.dart';
import 'package:property/core/constants/my_api_url.dart';
import 'package:property/feature/invoice/data/model/invoice_page_model.dart';

abstract interface class InvoiceRemoteDataSource {
  Future<InvoicePageModel> fetchInvoices();
}

class BaseClientInvoiceRemoteDataSource implements InvoiceRemoteDataSource {
  const BaseClientInvoiceRemoteDataSource(this._context);

  final BuildContext _context;

  @override
  Future<InvoicePageModel> fetchInvoices() async {
    final response = await BaseClient.getData(
      endPoint: MyApiUrl.invoices,
      ctx: _context,
    );
    return InvoicePageModel.fromJson(Map<String, dynamic>.from({
  "success": true,
  "message": "OK",
  "data": [
    {
      "id": 1,
      "invoice_number": "INV-2025-001",
      "lease_id": 101,
      "period_start": "2025-01-01",
      "period_end": "2025-01-31",
      "issue_date": "2025-01-01",
      "due_date": "2025-01-01",
      "currency": "USD",
      "total_amount": "1850.00",
      "amount_paid": "1850.00",
      "balance_due": "0.00",
      "status": "paid",
      "notes": "January rent fully paid",
      "items": [
        {
          "id": 1,
          "type": "rent",
          "description": "Monthly rent - Jan 2025",
          "amount": "1850.00"
        }
      ],
      "payments": [
        {
          "id": 1,
          "amount": "1850.00",
          "currency": "USD",
          "paid_on": "2025-01-01",
          "method": "bank_transfer",
          "reference": "TXN-12345",
          "notes": "Payment received via ACH"
        }
      ],
      "lease": {
        "id": 101,
        "tenant": {
          "id": 1
        },
        "unit": {
          "id": 5,
          "name": "Sunrise Apartment - Unit 5",
          "property": {
            "id": 3
          }
        }
      }
    },
    {
      "id": 2,
      "invoice_number": "INV-2025-002",
      "lease_id": 103,
      "period_start": "2025-02-01",
      "period_end": "2025-02-28",
      "issue_date": "2025-02-01",
      "due_date": "2025-02-15",
      "currency": "USD",
      "total_amount": "2200.00",
      "amount_paid": "0.00",
      "balance_due": "2200.00",
      "status": "overdue",
      "notes": "Payment not received; reminder sent",
      "items": [
        {
          "id": 2,
          "type": "rent",
          "description": "Monthly rent - Feb 2025",
          "amount": "2100.00"
        },
        {
          "id": 3,
          "type": "utility",
          "description": "Water and trash fee",
          "amount": "100.00"
        }
      ],
      "payments": [],
      "lease": {
        "id": 103,
        "tenant": {
          "id": 2
        },
        "unit": {
          "id": 8,
          "name": "Palm Tower - Unit 8A",
          "property": {
            "id": 4
          }
        }
      }
    },
    {
      "id": 3,
      "invoice_number": "INV-2024-011",
      "lease_id": 102,
      "period_start": "2024-11-01",
      "period_end": "2024-11-30",
      "issue_date": "2024-11-01",
      "due_date": "2024-11-01",
      "currency": "USD",
      "total_amount": "1200.00",
      "amount_paid": "1200.00",
      "balance_due": "0.00",
      "status": "paid",
      "notes": "Final invoice for expired lease",
      "items": [
        {
          "id": 4,
          "type": "rent",
          "description": "November rent",
          "amount": "1200.00"
        }
      ],
      "payments": [
        {
          "id": 2,
          "amount": "1200.00",
          "currency": "USD",
          "paid_on": "2024-11-01",
          "method": "check",
          "reference": "CHK-5678",
          "notes": "Check deposited"
        }
      ],
      "lease": {
        "id": 102,
        "tenant": {
          "id": 1
        },
        "unit": {
          "id": 12,
          "name": "Oakwood Studio - Unit 12",
          "property": {
            "id": 7
          }
        }
      }
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
      throw const FormatException('The invoices response is invalid.');
    }
    return InvoicePageModel.fromJson(Map<String, dynamic>.from(response));
  }
}
