import 'package:flutter/foundation.dart';
import 'package:property/feature/invoice/data/model/invoice_page_model.dart';
import 'package:property/feature/invoice/data/repository/invoice_repository.dart';

class InvoiceProvider extends ChangeNotifier {
  InvoiceProvider(this._repository);

  final InvoiceRepository _repository;

  InvoicePageModel? _page;
  InvoicePageModel? get page => _page;

  bool _isInitialLoading = false;
  bool get isInitialLoading => _isInitialLoading;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void>? _ongoingRequest;
  bool _isDisposed = false;

  Future<void> load() => _request();
  Future<void> refresh() => _request();

  Future<void> _request() {
    final active = _ongoingRequest;
    if (active != null) return active;
    final request = _fetch();
    _ongoingRequest = request;
    request.whenComplete(() {
      if (identical(_ongoingRequest, request)) _ongoingRequest = null;
    });
    return request;
  }

  Future<void> _fetch() async {
    _isInitialLoading = _page == null;
    _isRefreshing = _page != null;
    _errorMessage = null;
    _notifySafely();
    try {
      _page = await _repository.getInvoices();
    } on StateError catch (error) {
      final message = error.message.toString().trim();
      _errorMessage = message.isEmpty ? _fallbackError : message;
    } catch (_) {
      _errorMessage = _fallbackError;
    } finally {
      _isInitialLoading = false;
      _isRefreshing = false;
      _notifySafely();
    }
  }

  void _notifySafely() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  static const _fallbackError =
      'We could not load your invoices. Pull down to try again.';
}
