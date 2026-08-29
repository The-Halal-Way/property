import 'package:property/feature/settings/data/model/profile_model.dart';
import 'package:property/feature/settings/data/model/update_profile_request.dart';

abstract interface class ProfileRepository {
  Future<ProfileModel> updateProfile(UpdateProfileRequest request);
}
