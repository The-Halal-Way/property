import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property/core/base/base_client.dart';
import 'package:property/core/constants/my_api_url.dart';
import 'package:property/core/service/global_service.dart';
import 'package:property/feature/tenant/data/datasource/tenant_remote_data_source.dart';

void main() {
  testWidgets(
    'requests the authorized v1 tenants endpoint without a GET body',
    (tester) async {
      final previousToken = GlobalService.instance.idToken;
      GlobalService.instance.idToken = 'tenant-test-token';
      addTearDown(() => GlobalService.instance.idToken = previousToken);

      final previousAdapter = BaseClient.dio.httpClientAdapter;
      final adapter = _TenantAdapter();
      BaseClient.dio.httpClientAdapter = adapter;
      addTearDown(() => BaseClient.dio.httpClientAdapter = previousAdapter);

      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (builderContext) {
              context = builderContext;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final page = await tester.runAsync(
        () => BaseClientTenantRemoteDataSource(context).fetchTenants(),
      );

      expect(
        adapter.request.uri.toString(),
        '${MyApiUrl.baseUrl}/${MyApiUrl.version}/${MyApiUrl.tenants}',
      );
      expect(adapter.request.method, 'GET');
      expect(adapter.request.data, isNull);
      expect(adapter.request.headers['Content-Type'], isNull);
      expect(
        adapter.request.headers['Authorization'],
        'Bearer tenant-test-token',
      );
      expect(page!.tenants, isEmpty);
    },
  );
}

class _TenantAdapter implements HttpClientAdapter {
  late RequestOptions request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'message': 'OK',
        'data': <dynamic>[],
        'meta': {'current_page': 1, 'per_page': 20, 'total': 0, 'last_page': 1},
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
