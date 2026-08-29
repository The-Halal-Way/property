import 'package:flutter/material.dart';
import 'package:property/core/base/base_client.dart';
import 'package:property/core/constants/my_api_url.dart';
import 'package:property/feature/settings/data/model/profile_model.dart';
import 'package:property/feature/settings/data/model/update_profile_request.dart';

abstract interface class ProfileRemoteDataSource {
  Future<ProfileModel> updateProfile(UpdateProfileRequest request);
}

class BaseClientProfileRemoteDataSource implements ProfileRemoteDataSource {
  const BaseClientProfileRemoteDataSource(this._context);

  final BuildContext _context;

  @override
  Future<ProfileModel> updateProfile(UpdateProfileRequest request) async {
    final response = await BaseClient.putData(
      endPoint: MyApiUrl.profile,
      body: request.toJson(),
      ctx: _context,
    );
    final responseMap = profileJsonMap(response);
    final data = profileJsonMap(responseMap['data']);
    if (response is! Map || responseMap['success'] != true || data.isEmpty) {
      throw const FormatException('The updated profile response is invalid.');
    }
    return ProfileModel.fromJson(data);
  }
}
