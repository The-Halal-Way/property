import 'package:property/feature/settings/data/datasource/profile_remote_data_source.dart';
import 'package:property/feature/settings/data/model/profile_model.dart';
import 'package:property/feature/settings/data/model/update_profile_request.dart';
import 'package:property/feature/settings/data/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<ProfileModel> updateProfile(UpdateProfileRequest request) =>
      _remoteDataSource.updateProfile(request);
}
