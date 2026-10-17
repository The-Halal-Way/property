// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:property/core/constants/my_api_url.dart';
import 'package:property/core/constants/my_string.dart';
import 'package:property/core/error/api_exception.dart';
import 'package:property/core/service/global_service.dart';
import 'package:property/core/util/my_dialog.dart';

class BaseClient {
  static final dio = Dio(BaseOptions(connectTimeout: Duration(seconds: 3)));
  static final Logger _logger = Logger();

  static Map<String, String> get header => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (GlobalService.instance.token != null &&
        GlobalService.instance.token!.isNotEmpty)
      'Authorization': 'Bearer ${GlobalService.instance.token}',
  };

  static Map<String, String> get _bodylessHeader =>
      Map<String, String>.from(header)..remove('Content-Type');

  static void _logResponse(String method, Response<dynamic> response) {
    _logger.t(
      '$method ${response.requestOptions.uri}\n'
      'Status: ${response.statusCode}\n'
      'Response: ${response.data}',
    );
  }

  static void _logDioError(String method, DioException e) {
    _logger.e(
      '$method ${e.requestOptions.uri}\n'
      'Error: ${e.message}\n'
      'Status: ${e.response?.statusCode}\n'
      'Error response: ${e.response?.data}',
    );
  }

  static Future<dynamic> getData({
    required String endPoint,
    Object? body,
    Map<String, dynamic>? parameters,
    Options? options,
    required BuildContext ctx,
  }) async {
    try {
      final url = "${MyApiUrl.baseUrl}/${MyApiUrl.version}/$endPoint";
      _logger.i("$url/$parameters");
      final response = await dio.get(
        url,
        queryParameters: parameters,
        data: body,
        options:
            options ??
            Options(headers: body == null ? _bodylessHeader : header),
      );
      _logResponse('GET', response);
      if (response.statusCode == 200) return response.data;
      MyDialog().showFailedToast(msg: MyString.errorMsg, context: ctx);
    } on DioException catch (e) {
      _logDioError('GET', e);
      ApiException.handleException(e, ctx);
    } catch (e) {
      _logger.e(e);
      MyDialog().showFailedToast(
        title: "Unexpected Error!",
        msg: e.toString(),
        context: ctx,
      );
    }
  }

  static Future<dynamic> postData({
    required String endPoint,
    Object? body,
    Map<String, dynamic>? parameters,
    Options? options,
    required BuildContext ctx,
    bool showError = true,
  }) async {
    try {
      final url = "${MyApiUrl.baseUrl}/${MyApiUrl.version}/$endPoint";
      _logger.i("$url/$parameters");
      final response = await dio.post(
        url,
        queryParameters: parameters,
        data: body ?? jsonEncode({}),
        options: options ?? Options(headers: header),
      );
      _logResponse('POST', response);
      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) {
        return response.data;
      }
      if (showError) {
        MyDialog().showFailedToast(msg: MyString.errorMsg, context: ctx);
      }
    } on DioException catch (e) {
      _logDioError('POST', e);
      if (showError) {
        ApiException.handleException(e, ctx);
      }
    } catch (e) {
      _logger.e(e);
      if (showError) {
        MyDialog().showFailedToast(
          title: "Unexpected Error!",
          msg: e.toString(),
          context: ctx,
        );
      }
    }
  }

  static Future<dynamic> postMultipartFile({
    required String endPoint,
    required String filePath,
    String fileField = 'file',
    Map<String, dynamic>? fields,
    Map<String, dynamic>? parameters,
    Options? options,
    required BuildContext ctx,
    bool showError = true,
  }) async {
    return postMultipartData(
      endPoint: endPoint,
      fields: fields,
      files: {
        fileField: await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      },
      parameters: parameters,
      options: options,
      ctx: ctx,
      showError: showError,
    );
  }

  static Future<dynamic> postMultipartData({
    required String endPoint,
    Map<String, dynamic>? fields,
    Map<String, MultipartFile>? files,
    Map<String, dynamic>? parameters,
    Options? options,
    required BuildContext ctx,
    bool showError = true,
  }) async {
    try {
      final url = "${MyApiUrl.baseUrl}/${MyApiUrl.version}/$endPoint";
      _logger.i("$url/$parameters");

      final formData = FormData.fromMap({...?fields, ...?files});

      final resolvedHeaders = <String, dynamic>{
        ...((options?.headers) ?? header),
        'Content-Type': 'multipart/form-data',
      };

      final resolvedOptions = (options ?? Options()).copyWith(
        headers: resolvedHeaders,
      );

      final response = await dio.post(
        url,
        queryParameters: parameters,
        data: formData,
        options: resolvedOptions,
      );
      _logResponse('POST-MULTIPART', response);

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) {
        return response.data;
      }

      if (showError) {
        MyDialog().showFailedToast(msg: MyString.errorMsg, context: ctx);
      }
      throw ApiRequestException(reported: showError);
    } on DioException catch (e) {
      _logDioError('POST-MULTIPART', e);
      if (showError) {
        ApiException.handleException(e, ctx);
      }
      throw ApiRequestException(reported: showError);
    } catch (e) {
      if (e is ApiRequestException) rethrow;
      _logger.e(e);
      if (showError) {
        MyDialog().showFailedToast(
          title: "Unexpected Error!",
          msg: e.toString(),
          context: ctx,
        );
      }
      throw ApiRequestException(reported: showError);
    }
  }

  static Future<dynamic> patchData({
    required String endPoint,
    Object? body,
    Map<String, dynamic>? parameters,
    Options? options,
    required BuildContext ctx,
  }) async {
    try {
      final url = "${MyApiUrl.baseUrl}/${MyApiUrl.version}/$endPoint";
      _logger.i("$url/$parameters");
      final response = await dio.patch(
        url,
        queryParameters: parameters,
        data: body ?? jsonEncode({}),
        options: options ?? Options(headers: header),
      );
      _logResponse('PATCH', response);
      if (response.statusCode == 200) return response.data;
      MyDialog().showFailedToast(msg: MyString.errorMsg, context: ctx);
    } on DioException catch (e) {
      _logDioError('PATCH', e);
      ApiException.handleException(e, ctx);
    } catch (e) {
      _logger.e(e);
      MyDialog().showFailedToast(
        title: "Unexpected Error!",
        msg: e.toString(),
        context: ctx,
      );
    }
  }

  static Future<dynamic> putData({
    required String endPoint,
    Object? body,
    Map<String, dynamic>? parameters,
    Options? options,
    required BuildContext ctx,
    bool showError = true,
  }) async {
    try {
      final url = "${MyApiUrl.baseUrl}/${MyApiUrl.version}/$endPoint";
      _logger.i("$url/$parameters");
      final response = await dio.put(
        url,
        queryParameters: parameters,
        data: body ?? jsonEncode({}),
        options: options ?? Options(headers: header),
      );
      _logResponse('PUT', response);
      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) return response.data;
      if (showError) {
        MyDialog().showFailedToast(msg: MyString.errorMsg, context: ctx);
      }
      throw ApiRequestException(reported: showError);
    } on DioException catch (e) {
      _logDioError('PUT', e);
      if (showError) ApiException.handleException(e, ctx);
      throw ApiRequestException(reported: showError);
    } catch (e) {
      if (e is ApiRequestException) rethrow;
      _logger.e(e);
      if (showError) {
        MyDialog().showFailedToast(
          title: "Unexpected Error!",
          msg: e.toString(),
          context: ctx,
        );
      }
      throw ApiRequestException(reported: showError);
    }
  }

  static Future<dynamic> deleteData({
    required String endPoint,
    Object? body,
    Map<String, dynamic>? parameters,
    Options? options,
    required BuildContext ctx,
  }) async {
    try {
      final url = "${MyApiUrl.baseUrl}/${MyApiUrl.version}/$endPoint";
      _logger.i("$url/$parameters");
      final response = await dio.delete(
        url,
        queryParameters: parameters,
        data: body ?? jsonEncode({}),
        options: options ?? Options(headers: header),
      );
      _logResponse('DELETE', response);
      if (response.statusCode == 200) return response.data;
      MyDialog().showFailedToast(msg: MyString.errorMsg, context: ctx);
    } on DioException catch (e) {
      _logDioError('DELETE', e);
      ApiException.handleException(e, ctx);
    } catch (e) {
      _logger.e(e);
      MyDialog().showFailedToast(
        title: "Unexpected Error!",
        msg: e.toString(),
        context: ctx,
      );
    }
  }
}

class ApiRequestException implements Exception {
  const ApiRequestException({required this.reported});

  final bool reported;
}
