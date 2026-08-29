import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property/core/base/base_client.dart';
import 'package:property/core/constants/my_api_url.dart';
import 'package:property/core/model/selected_upload_file.dart';
import 'package:property/core/service/global_service.dart';
import 'package:property/feature/employee/data/datasource/employee_remote_data_source.dart';
import 'package:property/feature/employee/data/model/create_employee_request.dart';
import 'package:property/feature/properties/data/datasource/property_remote_data_source.dart';
import 'package:property/feature/properties/data/model/create_property_request.dart';
import 'package:property/feature/tenant/data/datasource/tenant_remote_data_source.dart';
import 'package:property/feature/tenant/data/model/create_tenant_request.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('employee create posts multipart fields, arrays, and photo', (
    tester,
  ) async {
    final adapter = _installAdapter({
      'success': true,
      'message': 'Employee added.',
      'data': {
        'id': 12,
        'name': 'Asha Khan',
        'login_enabled': true,
        'roles': 'Manager',
        'permissions': ['properties.view'],
      },
    });
    addTearDown(adapter.restore);
    final context = await _context(tester);

    final employee = await tester.runAsync(
      () => BaseClientEmployeeRemoteDataSource(context).createEmployee(
        CreateEmployeeRequest(
          name: ' Asha Khan ',
          email: ' asha@example.com ',
          password: 'secret',
          loginEnabled: true,
          roles: const [2, 4],
          permissions: const ['properties.view', 'reports.view'],
          photo: SelectedUploadFile(
            name: 'asha.png',
            bytes: Uint8List.fromList([1, 2, 3]),
          ),
        ),
      ),
    );

    expect(employee!.id, 12);
    _expectRequest(adapter.request, MyApiUrl.employees);
    final form = adapter.request.data as FormData;
    expect(_values(form, 'name'), ['Asha Khan']);
    expect(_values(form, 'login_enabled'), ['true']);
    expect(_values(form, 'roles'), ['2', '4']);
    expect(_values(form, 'permissions'), ['properties.view', 'reports.view']);
    expect(form.files.single.key, 'photo');
    expect(form.files.single.value.filename, 'asha.png');
  });

  testWidgets('property create normalizes API values and includes image', (
    tester,
  ) async {
    final adapter = _installAdapter({
      'success': true,
      'message': 'Property created.',
      'data': {
        'id': 31,
        'name': 'Lake House',
        'type': 'house',
        'address_line1': '1 Lake Road',
        'city': 'Dhaka',
        'country_code': 'BD',
        'units': <dynamic>[],
      },
    });
    addTearDown(adapter.restore);
    final context = await _context(tester);

    final property = await tester.runAsync(
      () => BaseClientPropertyRemoteDataSource(context).createProperty(
        CreatePropertyRequest(
          name: 'Lake House',
          type: 'House',
          employeeId: '9',
          addressLine1: '1 Lake Road',
          city: 'Dhaka',
          countryCode: 'bd',
          currentValue: 250000,
          image: SelectedUploadFile(
            name: 'house.jpg',
            bytes: Uint8List.fromList([4, 5, 6]),
          ),
        ),
      ),
    );

    expect(property!.id, 31);
    _expectRequest(adapter.request, MyApiUrl.properties);
    final form = adapter.request.data as FormData;
    expect(_values(form, 'type'), ['house']);
    expect(_values(form, 'employee_id'), ['9']);
    expect(_values(form, 'country_code'), ['BD']);
    expect(_values(form, 'current_value'), ['250000.0']);
    expect(form.files.single.key, 'image');
  });

  testWidgets('tenant create posts both optional binary fields', (
    tester,
  ) async {
    final adapter = _installAdapter({
      'success': true,
      'message': 'Tenant added.',
      'data': {
        'id': 44,
        'name': 'Nadia Rahman',
        'phone': '+8801700000000',
        'family_members_count': 3,
        'leases': <dynamic>[],
      },
    });
    addTearDown(adapter.restore);
    final context = await _context(tester);

    final tenant = await tester.runAsync(
      () => BaseClientTenantRemoteDataSource(context).createTenant(
        CreateTenantRequest(
          name: 'Nadia Rahman',
          phone: '+8801700000000',
          countryCode: 'bd',
          familyMembersCount: 3,
          photo: SelectedUploadFile(
            name: 'nadia.jpg',
            bytes: Uint8List.fromList([7, 8]),
          ),
          idDocument: SelectedUploadFile(
            name: 'nid.pdf',
            bytes: Uint8List.fromList([9, 10]),
          ),
        ),
      ),
    );

    expect(tenant!.id, 44);
    _expectRequest(adapter.request, MyApiUrl.tenants);
    final form = adapter.request.data as FormData;
    expect(_values(form, 'country_code'), ['BD']);
    expect(_values(form, 'family_members_count'), ['3']);
    expect(form.files.map((entry) => entry.key), ['photo', 'id_document']);
  });
}

List<String> _values(FormData form, String key) => form.fields
    .where((entry) => entry.key == key)
    .map((entry) => entry.value)
    .toList(growable: false);

void _expectRequest(RequestOptions request, String endpoint) {
  expect(request.method, 'POST');
  expect(
    request.uri.toString(),
    '${MyApiUrl.baseUrl}/${MyApiUrl.version}/$endpoint',
  );
  expect(request.headers['Authorization'], 'Bearer create-test-token');
  expect(request.headers['Content-Type'], startsWith('multipart/form-data'));
}

Future<BuildContext> _context(WidgetTester tester) async {
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
  return context;
}

_CreateAdapter _installAdapter(Map<String, dynamic> response) {
  final previousToken = GlobalService.instance.idToken;
  final previousAdapter = BaseClient.dio.httpClientAdapter;
  GlobalService.instance.idToken = 'create-test-token';
  final adapter = _CreateAdapter(
    response,
    restore: () {
      GlobalService.instance.idToken = previousToken;
      BaseClient.dio.httpClientAdapter = previousAdapter;
    },
  );
  BaseClient.dio.httpClientAdapter = adapter;
  return adapter;
}

class _CreateAdapter implements HttpClientAdapter {
  _CreateAdapter(this.response, {required this.restore});

  final Map<String, dynamic> response;
  final VoidCallback restore;
  late RequestOptions request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode(response),
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
