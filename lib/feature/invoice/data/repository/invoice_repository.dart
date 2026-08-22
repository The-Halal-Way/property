import 'package:property/feature/invoice/data/model/invoice_page_model.dart';

abstract interface class InvoiceRepository {
  Future<InvoicePageModel> getInvoices();
}
