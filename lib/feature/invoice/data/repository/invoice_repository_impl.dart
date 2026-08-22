import 'package:property/feature/invoice/data/datasource/invoice_remote_data_source.dart';
import 'package:property/feature/invoice/data/model/invoice_page_model.dart';
import 'package:property/feature/invoice/data/repository/invoice_repository.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  const InvoiceRepositoryImpl(this._remoteDataSource);

  final InvoiceRemoteDataSource _remoteDataSource;

  @override
  Future<InvoicePageModel> getInvoices() => _remoteDataSource.fetchInvoices();
}
