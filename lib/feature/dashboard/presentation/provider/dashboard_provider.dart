import 'package:flutter/material.dart';
import 'package:property/feature/dashboard/data/repository/dashboard_repository.dart';
import 'package:property/feature/dashboard/data/model/dashboard_data.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider(this._repository);

  final DashboardRepository _repository;

  DashboardData? _data;
  DashboardData? get data => _data;

  bool _isInitialLoading = false;
  bool get isInitialLoading => _isInitialLoading;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _requestInProgress = false;
  bool _isDisposed = false;

  Future<void> load(BuildContext context) => _fetch(context);

  Future<void> refresh(BuildContext context) => _fetch(context);

  Future<void> _fetch(BuildContext context) async {
    if (_requestInProgress) return;

    _requestInProgress = true;
    _isInitialLoading = _data == null;
    _isRefreshing = _data != null;
    _errorMessage = null;
    _notifyListeners();

    try {
      final data = await _repository.fetchDashboard(context);
      if (data == null) {
        _errorMessage = 'Unable to load the dashboard.';
      } else {
        _data = data;
      }
    } catch (_) {
      _errorMessage = 'Unable to load the dashboard.';
    } finally {
      _requestInProgress = false;
      _isInitialLoading = false;
      _isRefreshing = false;
      _notifyListeners();
    }
  }

  void _notifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
