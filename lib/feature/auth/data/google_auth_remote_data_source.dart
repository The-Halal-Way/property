import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:property/core/base/base_client.dart';
import 'package:property/core/constants/my_api_url.dart';
import 'package:property/core/model/google_auth_response.dart';

abstract interface class GoogleAuthRemoteDataSource {
  Future<GoogleAuthResponse> signIn({
    required String googleIdToken,
    required String deviceName,
  });
}

class DioGoogleAuthRemoteDataSource implements GoogleAuthRemoteDataSource {
  DioGoogleAuthRemoteDataSource({Dio? dio}) : _dio = dio ?? BaseClient.dio;

  final Dio _dio;

  @override
  Future<GoogleAuthResponse> signIn({
    required String googleIdToken,
    required String deviceName,
  }) async {
    final url =
        '${MyApiUrl.baseUrl}/${MyApiUrl.version}/${MyApiUrl.googleAuth}';
    final requestData = {'id_token': googleIdToken, 'device_name': deviceName};
    _logRequest(url: url, data: requestData);

    try {
      final response = await _dio.post<dynamic>(
        url,
        data: requestData,
        options: Options(
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      _logResponse(response);
      final responseJson = _jsonMap(response.data);
      final authResponse = GoogleAuthResponse.fromJson(responseJson);
      if (!authResponse.success || authResponse.data.token.isEmpty) {
        throw GoogleAuthApiException(
          authResponse.message.isEmpty
              ? 'Google sign-in failed. Please try again.'
              : authResponse.message,
        );
      }
      return authResponse;
    } on DioException catch (error) {
      _logDioError(error);
      final responseJson = _jsonMap(error.response?.data);
      final errorJson = _jsonMap(responseJson['error']);
      final message =
          errorJson['message']?.toString().trim() ??
          responseJson['message']?.toString().trim();
      throw GoogleAuthApiException(
        message == null || message.isEmpty
            ? 'Could not connect to the server. Please try again.'
            : message,
      );
    } on GoogleAuthApiException {
      rethrow;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[GoogleAuthApi] Unexpected error: $error');
      }
      throw const GoogleAuthApiException(
        'Google sign-in failed. Please try again.',
      );
    }
  }
}

void _logRequest({required String url, required Map<String, dynamic> data}) {
  if (!kDebugMode) return;
  debugPrint('[GoogleAuthApi] POST $url');
  debugPrint('[GoogleAuthApi] Request: ${_redactSensitiveValues(data)}');
}

void _logResponse(Response<dynamic> response) {
  if (!kDebugMode) return;
  debugPrint(
    '[GoogleAuthApi] Response ${response.statusCode}: '
    '${_redactSensitiveValues(response.data)}',
  );
}

void _logDioError(DioException error) {
  if (!kDebugMode) return;
  debugPrint(
    '[GoogleAuthApi] Error ${error.response?.statusCode} '
    '(${error.type.name})',
  );
  debugPrint(
    '[GoogleAuthApi] Error response: '
    '${_redactSensitiveValues(error.response?.data)}',
  );
}

Object? _redactSensitiveValues(Object? value) {
  if (value is Map) {
    return value.map((key, nestedValue) {
      final normalizedKey = key.toString().toLowerCase();
      final isSensitive =
          normalizedKey == 'token' ||
          normalizedKey == 'id_token' ||
          normalizedKey == 'authorization';
      return MapEntry(
        key,
        isSensitive ? '[REDACTED]' : _redactSensitiveValues(nestedValue),
      );
    });
  }
  if (value is List) return value.map(_redactSensitiveValues).toList();
  return value;
}

class GoogleAuthApiException implements Exception {
  const GoogleAuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

Map<String, dynamic> _jsonMap(Object? value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, value) => MapEntry(key.toString(), value));
}
