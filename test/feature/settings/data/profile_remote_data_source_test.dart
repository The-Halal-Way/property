import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property/core/base/base_client.dart';
import 'package:property/core/constants/my_api_url.dart';
import 'package:property/core/service/global_service.dart';
import 'package:property/feature/settings/data/datasource/profile_remote_data_source.dart';
import 'package:property/feature/settings/data/model/update_profile_request.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'updates the authorized profile endpoint with the documented body',
    (tester) async {
      final previousToken = GlobalService.instance.idToken;
      final previousAdapter = BaseClient.dio.httpClientAdapter;
      GlobalService.instance.idToken = 'profile-test-token';
      final adapter = _ProfileAdapter();
      BaseClient.dio.httpClientAdapter = adapter;
      addTearDown(() {
        GlobalService.instance.idToken = previousToken;
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

      final profile = await tester.runAsync(
        () => BaseClientProfileRemoteDataSource(context).updateProfile(
          const UpdateProfileRequest(
            name: ' Jb Jason ',
            email: 'jb@example.com',
            phone: '',
            addressLine1: '12 Lake Road',
            city: 'Dhaka',
            countryCode: 'bd',
            timezone: 'Asia/Dhaka',
            locale: 'en-BD',
          ),
        ),
      );

      expect(profile!.id, 7);
      expect(profile.currency, 'BDT');
      expect(adapter.request.method, 'PUT');
      expect(
        adapter.request.uri.toString(),
        '${MyApiUrl.baseUrl}/${MyApiUrl.version}/${MyApiUrl.profile}',
      );
      expect(
        adapter.request.headers['Authorization'],
        'Bearer profile-test-token',
      );
      expect(adapter.request.data, {
        'name': 'Jb Jason',
        'email': 'jb@example.com',
        'phone': null,
        'address_line1': '12 Lake Road',
        'address_line2': null,
        'city': 'Dhaka',
        'state': null,
        'postal_code': null,
        'country_code': 'BD',
        'timezone': 'Asia/Dhaka',
        'locale': 'en-BD',
      });
    },
  );
}

class _ProfileAdapter implements HttpClientAdapter {
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
        'message': 'Profile updated.',
        'data': {
          'id': 7,
          'name': 'Jb Jason',
          'email': 'jb@example.com',
          'phone': '',
          'avatar_url': '',
          'currency': 'BDT',
          'currency_locked': false,
          'country_code': 'BD',
          'timezone': 'Asia/Dhaka',
          'locale': 'en-BD',
          'has_password': true,
          'email_verified': true,
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
