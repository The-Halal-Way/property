import 'package:flutter/foundation.dart';
import 'package:property/feature/report/data/model/report_model.dart';
import 'package:property/feature/report/data/repository/report_repository.dart';

class ReportProvider extends ChangeNotifier {
  ReportProvider(this._repository);

  final ReportRepository _repository;

  ReportModel? _data;
  ReportModel? get data => _data;
  ReportModel? get report => _data;

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
    _isInitialLoading = _data == null;
    _isRefreshing = _data != null;
    _errorMessage = null;
    _notifySafely();
    try {
      _data = await _repository.getReport();
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
      'We could not load your report. Pull down to try again.';
}
