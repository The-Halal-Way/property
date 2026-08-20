import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property/core/base/base_client.dart';
import 'package:property/core/constants/my_api_url.dart';
import 'package:property/core/service/global_service.dart';
import 'package:property/feature/dashboard/data/repository/dashboard_repository.dart';

void main() {
  testWidgets('requests the authorized dashboard endpoint without a GET body', (
    tester,
  ) async {
    final previousToken = GlobalService.instance.idToken;
    GlobalService.instance.idToken = 'test-token';
    addTearDown(() => GlobalService.instance.idToken = previousToken);

    final previousAdapter = BaseClient.dio.httpClientAdapter;
    final adapter = _DashboardAdapter();
    BaseClient.dio.httpClientAdapter = adapter;
    addTearDown(() {
      BaseClient.dio.httpClientAdapter = previousAdapter;
    });

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

    final data = await tester.runAsync(
      () => DashboardRepository().fetchDashboard(context),
    );

    expect(
      adapter.request.uri.toString(),
      '${MyApiUrl.baseUrl}/${MyApiUrl.version}/${MyApiUrl.dashboard}',
    );
    expect(adapter.request.method, 'GET');
    expect(adapter.request.data, isNull);
    expect(adapter.request.headers['Content-Type'], isNull);
    expect(adapter.request.headers['Authorization'], 'Bearer test-token');
    expect(data!.stats.properties, 0);
    expect(data.financials.expected, 0);
  });
}

class _DashboardAdapter implements HttpClientAdapter {
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
        'props': {
          'stats': <String, dynamic>{},
          'financials': <String, dynamic>{},
        },
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
