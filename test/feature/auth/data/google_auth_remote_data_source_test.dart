import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property/core/base/base_client.dart';
import 'package:property/core/constants/my_api_url.dart';
import 'package:property/core/service/global_service.dart';
import 'package:property/feature/auth/data/google_auth_remote_data_source.dart';

void main() {
  test(
    'posts the Google ID token and stores the returned backend session',
    () async {
      GlobalService.instance.token = 'stale-token';
      final adapter = _GoogleAuthAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final dataSource = DioGoogleAuthRemoteDataSource(dio: dio);
      addTearDown(GlobalService.instance.clearAuth);

      final response = await dataSource.signIn(
        googleIdToken: 'google-id-token',
        deviceName: 'Android',
      );
      GlobalService.instance.saveGoogleAuthResponse(response);

      expect(adapter.request.method, 'POST');
      expect(
        adapter.request.uri.toString(),
        '${MyApiUrl.baseUrl}/${MyApiUrl.version}/${MyApiUrl.googleAuth}',
      );
      expect(adapter.request.data, {
        'id_token': 'google-id-token',
        'device_name': 'Android',
      });
      expect(adapter.request.headers['Authorization'], isNull);
      expect(response.data.actorType, 'landlord');
      expect(response.data.user.email, 'owner@example.com');
      expect(GlobalService.instance.googleAuthResponse, same(response));
      expect(GlobalService.instance.token, 'backend-token');
      expect(BaseClient.header['Authorization'], 'Bearer backend-token');
    },
  );

  test('uses the backend error message when the request fails', () async {
    final dio = Dio()..httpClientAdapter = _GoogleAuthAdapter(statusCode: 401);
    final dataSource = DioGoogleAuthRemoteDataSource(dio: dio);

    expect(
      () =>
          dataSource.signIn(googleIdToken: 'bad-token', deviceName: 'Android'),
      throwsA(
        isA<GoogleAuthApiException>().having(
          (error) => error.message,
          'message',
          'The Google token is invalid.',
        ),
      ),
    );
  });
}

class _GoogleAuthAdapter implements HttpClientAdapter {
  _GoogleAuthAdapter({this.statusCode = 200});

  final int statusCode;
  late RequestOptions request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    final body = statusCode == 200
        ? {
            'success': true,
            'message': 'Signed in with Google.',
            'data': {
              'token': 'backend-token',
              'actor_type': 'landlord',
              'user': {
                'id': 7,
                'name': 'Owner',
                'email': 'owner@example.com',
                'phone': '+8801000000000',
                'avatar_url': 'https://example.com/avatar.png',
                'currency': 'BDT',
                'currency_locked': true,
                'country_code': 'BD',
                'timezone': 'Asia/Dhaka',
                'locale': 'en-BD',
                'has_password': true,
                'email_verified': true,
              },
            },
          }
        : {
            'success': false,
            'error': {
              'code': 'auth/invalid-token',
              'message': 'The Google token is invalid.',
            },
          };
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
